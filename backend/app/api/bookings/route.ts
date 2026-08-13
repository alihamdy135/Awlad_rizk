import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking } from '@/models';
import { verifyOrDecodeToken } from '@/lib/firebase-auth-helper';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders });
}

export async function POST(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    let user_id = '';
    let customer_email = '';
    let customer_name = '';

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split('Bearer ')[1];
      try {
        const decoded = await verifyOrDecodeToken(token);
        user_id = decoded.uid || '';
        customer_email = decoded.email || '';
        customer_name = decoded.name || '';
      } catch (err) {
        console.warn('Booking Auth token warning:', err);
      }
    }

    await connectToDatabase();
    const BookingModel = Booking();
    const body = await request.json();

    const final_name = customer_name || body.customer_name || 'عميل';
    const final_email = customer_email || body.customer_email || '';

    // Generate booking ID
    const count = await BookingModel.countDocuments();
    const booking_id = `BK-${String(100001 + count).padStart(6, '0')}`;

    const booking = new BookingModel({
      ...body,
      customer_name: final_name,
      customer_email: final_email,
      user_id: user_id || body.user_id || '',
      booking_id,
      status_id: 'STAT-01',
      status_code: 'STAT-01',
      created_at: new Date().toISOString(),
    });

    await booking.save();
    return NextResponse.json({ success: true, data: booking, booking_id }, { status: 201, headers: corsHeaders });
  } catch (error) {
    console.error('Bookings API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to create booking' }, { status: 500, headers: corsHeaders });
  }
}

export async function GET() {
  try {
    await connectToDatabase();
    const BookingModel = Booking();
    const bookings = await BookingModel.find({}).sort({ createdAt: -1 }).lean();
    return NextResponse.json({ success: true, data: bookings }, { headers: corsHeaders });
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch bookings' }, { status: 500, headers: corsHeaders });
  }
}
