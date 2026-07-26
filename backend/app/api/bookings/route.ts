import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking } from '@/models';

export async function POST(request: Request) {
  try {
    await connectToDatabase();
    const BookingModel = Booking();
    const body = await request.json();

    // Generate booking ID
    const count = await BookingModel.countDocuments();
    const booking_id = `BK-${String(100001 + count).padStart(6, '0')}`;

    const booking = new BookingModel({
      ...body,
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
