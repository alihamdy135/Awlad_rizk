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
    const { booking_id, status_code, status_id } = body;
    const targetStatus = status_code || status_id;

    if (!booking_id || !targetStatus) {
      return NextResponse.json({ success: false, error: 'booking_id and status_code are required' }, { status: 400, headers: corsHeaders });
    }

    const updated = await BookingModel.findOneAndUpdate(
      { booking_id },
      { $set: { status_code: targetStatus, status_id: targetStatus, status: targetStatus } },
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
