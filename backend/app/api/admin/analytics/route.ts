import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking } from '@/models';
import { verifyAdminToken } from '@/lib/admin-auth-helper';

export const dynamic = 'force-dynamic';
export const revalidate = 0;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders });
}

function parseBookingDate(b: any): Date | null {
  const raw = b.preferred_date || b.created_at || b.createdAt || '';
  if (!raw) {
    // try _id timestamp
    if (b._id && b._id.getTimestamp) {
      try { return b._id.getTimestamp(); } catch { return null; }
    }
    return null;
  }
  // preferred_date is YYYY-MM-DD
  if (/^\d{4}-\d{2}-\d{2}/.test(raw)) {
    const d = new Date(raw);
    if (!isNaN(d.getTime())) return d;
  }
  const d2 = new Date(raw);
  if (!isNaN(d2.getTime())) return d2;
  return null;
}

function isCompleted(b: any): boolean {
  const s = (b.status_id || b.status_code || b.status || '').toString().toUpperCase();
  return s === 'STAT-03' || s.includes('COMPLETED') || s.includes('مكتمل');
}

export async function GET(request: NextRequest) {
  try {
    const auth = await verifyAdminToken(request);
    if (auth && (auth as any).isAdmin === false && (auth as any).email !== '') {
      return NextResponse.json({ success: false, error: 'Forbidden: admin only' }, { status: 403, headers: corsHeaders });
    }

    await connectToDatabase();
    const BookingModel = Booking();
    const allBookings: any[] = await BookingModel.find().lean();

    const { searchParams } = new URL(request.url);
    const yearParam = searchParams.get('year');
    const monthParam = searchParams.get('month'); // 1-12
    const now = new Date();
    const selectedYear = yearParam ? parseInt(yearParam) : now.getFullYear();
    const selectedMonth = monthParam ? parseInt(monthParam) : now.getMonth() + 1;

    // Group by year-month
    const byYearMonth: Record<string, { count: number; revenue: number; completed: number }> = {};
    const byYear: Record<string, { count: number; revenue: number }> = {};

    for (const b of allBookings) {
      const d = parseBookingDate(b);
      if (!d) continue;
      const y = d.getFullYear();
      const m = d.getMonth() + 1;
      const ym = `${y}-${String(m).padStart(2, '0')}`;
      const yk = `${y}`;
      if (!byYearMonth[ym]) byYearMonth[ym] = { count: 0, revenue: 0, completed: 0 };
      if (!byYear[yk]) byYear[yk] = { count: 0, revenue: 0 };
      byYearMonth[ym].count += 1;
      byYear[yk].count += 1;
      // revenue only for completed with final_price or estimated
      if (isCompleted(b)) {
        const price = Number(b.final_price_sar != null ? b.final_price_sar : (b.estimated_price_sar || 0)) || 0;
        byYearMonth[ym].revenue += price;
        byYear[yk].revenue += price;
        byYearMonth[ym].completed += 1;
      }
    }

    // Build monthly data for selected year
    const monthly: any[] = [];
    for (let m = 1; m <= 12; m++) {
      const key = `${selectedYear}-${String(m).padStart(2, '0')}`;
      const cur = byYearMonth[key] || { count: 0, revenue: 0, completed: 0 };
      const prevKey = m === 1 ? `${selectedYear - 1}-12` : `${selectedYear}-${String(m - 1).padStart(2, '0')}`;
      const prev = byYearMonth[prevKey] || { count: 0, revenue: 0 };
      const growthCount = prev.count === 0 ? (cur.count > 0 ? 100 : 0) : ((cur.count - prev.count) / prev.count) * 100;
      const growthRevenue = prev.revenue === 0 ? (cur.revenue > 0 ? 100 : 0) : ((cur.revenue - prev.revenue) / prev.revenue) * 100;
      monthly.push({
        month: m,
        month_name_ar: ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'][m-1],
        count: cur.count,
        revenue: cur.revenue,
        completed: cur.completed,
        growth_count_percent: Number(growthCount.toFixed(1)),
        growth_revenue_percent: Number(growthRevenue.toFixed(1)),
      });
    }

    const selectedKey = `${selectedYear}-${String(selectedMonth).padStart(2,'0')}`;
    const selectedData = byYearMonth[selectedKey] || { count: 0, revenue: 0, completed: 0 };
    // prev month for growth
    const prevMonth = selectedMonth === 1 ? 12 : selectedMonth - 1;
    const prevYear = selectedMonth === 1 ? selectedYear - 1 : selectedYear;
    const prevKeySel = `${prevYear}-${String(prevMonth).padStart(2,'0')}`;
    const prevData = byYearMonth[prevKeySel] || { count: 0, revenue: 0 };
    const growthCountSel = prevData.count === 0 ? (selectedData.count > 0 ? 100 : 0) : ((selectedData.count - prevData.count)/prevData.count)*100;
    const growthRevenueSel = prevData.revenue === 0 ? (selectedData.revenue > 0 ? 100 : 0) : ((selectedData.revenue - prevData.revenue)/prevData.revenue)*100;

    // YoY for same month last year
    const lastYearKey = `${selectedYear - 1}-${String(selectedMonth).padStart(2,'0')}`;
    const lastYearData = byYearMonth[lastYearKey] || { count: 0, revenue: 0 };
    const yoyCount = lastYearData.count === 0 ? (selectedData.count > 0 ? 100 : 0) : ((selectedData.count - lastYearData.count)/lastYearData.count)*100;
    const yoyRevenue = lastYearData.revenue === 0 ? (selectedData.revenue > 0 ? 100 : 0) : ((selectedData.revenue - lastYearData.revenue)/lastYearData.revenue)*100;

    // Year totals + YoY year
    const yearData = byYear[`${selectedYear}`] || { count: 0, revenue: 0 };
    const prevYearData = byYear[`${selectedYear - 1}`] || { count: 0, revenue: 0 };
    const yearGrowthCount = prevYearData.count === 0 ? (yearData.count > 0 ? 100 : 0) : ((yearData.count - prevYearData.count)/prevYearData.count)*100;
    const yearGrowthRevenue = prevYearData.revenue === 0 ? (yearData.revenue > 0 ? 100 : 0) : ((yearData.revenue - prevYearData.revenue)/prevYearData.revenue)*100;

    // Overall totals
    let totalCompletedRevenue = 0;
    let totalCount = allBookings.length;
    for (const b of allBookings) if (isCompleted(b)) totalCompletedRevenue += Number(b.final_price_sar != null ? b.final_price_sar : (b.estimated_price_sar || 0)) || 0;

    return NextResponse.json({
      success: true,
      data: {
        selected_year: selectedYear,
        selected_month: selectedMonth,
        monthly,
        selected: {
          key: selectedKey,
          count: selectedData.count,
          revenue: selectedData.revenue,
          completed: selectedData.completed,
          growth_count_percent: Number(growthCountSel.toFixed(1)),
          growth_revenue_percent: Number(growthRevenueSel.toFixed(1)),
          yoy_count_percent: Number(yoyCount.toFixed(1)),
          yoy_revenue_percent: Number(yoyRevenue.toFixed(1)),
          prev_month_key: prevKeySel,
          prev_month_count: prevData.count,
          prev_month_revenue: prevData.revenue,
        },
        year: {
          count: yearData.count,
          revenue: yearData.revenue,
          growth_count_percent: Number(yearGrowthCount.toFixed(1)),
          growth_revenue_percent: Number(yearGrowthRevenue.toFixed(1)),
        },
        totals: {
          total_bookings: totalCount,
          total_completed_revenue: totalCompletedRevenue,
        },
        all_years: Object.keys(byYear).sort().map(y => ({ year: parseInt(y), count: byYear[y].count, revenue: byYear[y].revenue })),
      }
    }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Analytics Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500, headers: corsHeaders });
  }
}
