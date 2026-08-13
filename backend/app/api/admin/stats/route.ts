import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking, Service, UserProfile } from '@/models';
import { verifyAdminToken } from '@/lib/admin-auth-helper';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders });
}

export async function GET(request: Request) {
  try {
    await verifyAdminToken(request);

    await connectToDatabase();
    const BookingModel = Booking();
    const ServiceModel = Service();
    const UserProfileModel = UserProfile();

    const [allBookings, totalServices, totalUsers] = await Promise.all([
      BookingModel.find().lean(),
      ServiceModel.countDocuments(),
      UserProfileModel.countDocuments(),
    ]);

    let totalRevenue = 0;
    let pendingCount = 0;
    let inProgressCount = 0;
    let completedCount = 0;
    let cancelledCount = 0;

    allBookings.forEach((b: any) => {
      const price = Number(b.estimated_price_sar || b.total_amount_sar || b.total_price_sar || 0);
      totalRevenue += price;

      const status = (b.status_id || b.status_code || b.status || '').toUpperCase();
      if (status === 'STAT-01' || status.includes('انتظار') || status.includes('PENDING')) {
        pendingCount++;
      } else if (status === 'STAT-02' || status.includes('عمل') || status.includes('PROGRESS')) {
        inProgressCount++;
      } else if (status === 'STAT-03' || status.includes('مكتمل') || status.includes('COMPLETED')) {
        completedCount++;
      } else if (status === 'STAT-04' || status.includes('ملغي') || status.includes('CANCEL')) {
        cancelledCount++;
      } else {
        pendingCount++;
      }
    });

    return NextResponse.json({
      success: true,
      data: {
        total_bookings: allBookings.length,
        total_revenue_sar: totalRevenue,
        pending_count: pendingCount,
        in_progress_count: inProgressCount,
        completed_count: completedCount,
        cancelled_count: cancelledCount,
        total_services: totalServices,
        total_users: totalUsers,
      },
    }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Admin Stats Error:', error);
    return NextResponse.json({ success: false, error: error.message || 'Failed to fetch admin stats' }, { status: 401, headers: corsHeaders });
  }
}
