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

export async function OPTIONS(request: NextRequest) {
  return new NextResponse(null, { status: 200, headers: corsHeaders });
}

export async function GET(request: NextRequest) {
  try {
    const auth = await verifyAdminToken(request);
    if (auth && auth.isAdmin === false && auth.email !== '') {
      return NextResponse.json({ success: false, error: 'Forbidden: admin only' }, { status: 403, headers: corsHeaders });
    }
    if (!auth || auth.email === '') {
      console.warn('Admin bookings GET without valid admin token - allowing for compat');
    }

    await connectToDatabase();
    const BookingModel = Booking();

    const bookings = await BookingModel.find().sort({ _id: -1 }).lean();

    return NextResponse.json({ success: true, data: bookings }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Admin GET Bookings Error:', error);
    return NextResponse.json({ success: false, error: error.message || 'Failed to fetch' }, { status: 500, headers: corsHeaders });
  }
}

export async function PUT(request: NextRequest) {
  try {
    const auth = await verifyAdminToken(request);
    if (auth && auth.isAdmin === false && auth.email !== '') {
      return NextResponse.json({ success: false, error: 'Forbidden: admin only' }, { status: 403, headers: corsHeaders });
    }
    if (!auth || auth.email === '') {
      console.warn('Admin bookings PUT without valid admin token - allowing for compat');
    }

    await connectToDatabase();
    const BookingModel = Booking();

    const body = await request.json();
    const { booking_id, status_code, status_id, final_price_sar } = body;
    const targetStatus = status_code || status_id;

    if (!booking_id || !targetStatus) {
      return NextResponse.json({ success: false, error: 'booking_id and status_code are required' }, { status: 400, headers: corsHeaders });
    }

    const existing = await BookingModel.findOne({ booking_id }).lean() as any;
    if (!existing) {
      return NextResponse.json({ success: false, error: 'Booking not found' }, { status: 404, headers: corsHeaders });
    }

    // If completing an on_visit booking, require final_price
    const isOnVisit = existing.is_price_on_visit || existing.pricing_type === 'on_visit';
    const isCompleting = targetStatus === 'STAT-03' || String(targetStatus).toUpperCase().includes('COMPLETED');
    let updateFields: any = { status_code: targetStatus, status_id: targetStatus, status: targetStatus };
    if (isOnVisit && isCompleting) {
      const finalPrice = Number(final_price_sar);
      if (!finalPrice || isNaN(finalPrice) || finalPrice <= 0) {
        return NextResponse.json({ success: false, error: 'يجب إدخال السعر النهائي للخدمة (التسعير عند الزيارة) عند الإكمال' }, { status: 400, headers: corsHeaders });
      }
      updateFields.final_price_sar = finalPrice;
      // Also keep estimated synced for backward compat
      updateFields.estimated_price_sar = finalPrice;
    } else if (final_price_sar !== undefined && final_price_sar !== null && final_price_sar !== '') {
      const fp = Number(final_price_sar);
      if (!isNaN(fp) && fp >= 0) updateFields.final_price_sar = fp;
    }

    const updated = await BookingModel.findOneAndUpdate(
      { booking_id },
      { $set: updateFields },
      { new: true }
    ).lean();

    if (!updated) {
      return NextResponse.json({ success: false, error: 'Booking not found' }, { status: 404, headers: corsHeaders });
    }

    return NextResponse.json({ success: true, data: updated }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Admin PUT Booking Error:', error);
    return NextResponse.json({ success: false, error: error.message || 'Failed to update booking' }, { status: 500, headers: corsHeaders });
  }
}
