import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking } from '@/models';
import { auth } from '@/lib/firebase-admin';

export async function POST(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Unauthorized: No token provided' }, { status: 401 });
    }

    const token = authHeader.split('Bearer ')[1];
    let decodedToken;
    try {
      if (!auth) {
        throw new Error('Firebase Admin not configured');
      }
      decodedToken = await auth.verifyIdToken(token);
    } catch (error) {
      console.error('Token verification failed:', error);
      return NextResponse.json({ success: false, error: 'Unauthorized: Invalid token' }, { status: 401 });
    }

    await connectToDatabase();
    const BookingModel = Booking();
    const body = await request.json();

    // Force the customer info from the verified token
    const customer_name = decodedToken.name || body.customer_name;
    const customer_email = decodedToken.email;
    const user_id = decodedToken.uid;

    // Generate booking ID
    const count = await BookingModel.countDocuments();
    const booking_id = `BK-${String(100001 + count).padStart(6, '0')}`;

    const booking = new BookingModel({
      ...body,
      customer_name,
      customer_email,
      user_id,
      booking_id,
      status_id: 'STAT-01',
      created_at: new Date().toISOString(),
    });

    await booking.save();
    return NextResponse.json({ success: true, data: booking, booking_id }, { status: 201 });
  } catch (error) {
    console.error('Bookings API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to create booking' }, { status: 500 });
  }
}

export async function GET() {
  try {
    await connectToDatabase();
    const BookingModel = Booking();
    const bookings = await BookingModel.find({}).sort({ createdAt: -1 }).lean();
    return NextResponse.json({ success: true, data: bookings });
  } catch (error) {
    return NextResponse.json({ success: false, error: 'Failed to fetch bookings' }, { status: 500 });
  }
}
