import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking, Testimonial } from '@/models';
import { verifyOrDecodeToken } from '@/lib/firebase-auth-helper';

export async function GET(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.split('Bearer ')[1];
    const decoded = await verifyOrDecodeToken(token);
    const userId = decoded.uid;
    const userEmail = decoded.email;

    await connectToDatabase();
    const BookingModel = Booking();

    // Query bookings matching either user_id or customer_email
    const userBookings = await BookingModel.find({
      $or: [{ user_id: userId }, { customer_email: userEmail }]
    }).sort({ createdAt: -1 }).lean();

    return NextResponse.json({ success: true, data: userBookings });
  } catch (error) {
    console.error('Get User Bookings Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch bookings' }, { status: 500 });
  }
}

export async function POST(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.split('Bearer ')[1];
    const decoded = await verifyOrDecodeToken(token);
    const userId = decoded.uid;

    await connectToDatabase();
    const BookingModel = Booking();
    const TestimonialModel = Testimonial();

    const { booking_id, rating, review_text } = await request.json();

    if (!booking_id || !rating) {
      return NextResponse.json({ success: false, error: 'booking_id and rating are required' }, { status: 400 });
    }

    // Update booking rating
    const updatedBooking = await BookingModel.findOneAndUpdate(
      { booking_id, $or: [{ user_id: userId }, { customer_email: decoded.email }] },
      { rating, review_text },
      { new: true }
    ).lean();

    if (!updatedBooking) {
      return NextResponse.json({ success: false, error: 'Booking not found or unauthorized' }, { status: 404 });
    }

    // Also add to Testimonials if review_text is provided
    if (review_text) {
      const count = await TestimonialModel.countDocuments();
      const testimonial_id = `TST-${String(1001 + count).padStart(4, '0')}`;
      await TestimonialModel.create({
        testimonial_id,
        customer_name: updatedBooking.customer_name || decoded.name || 'عميل محترم',
        district: updatedBooking.address_detail || 'جدة',
        rating,
        review_text_ar: review_text,
        service_name_ar: 'خدمات التكييف والتبريد',
        avatar_url: decoded.picture || '',
        is_active: true,
        display_order: count + 1,
      });
    }

    return NextResponse.json({ success: true, data: updatedBooking });
  } catch (error) {
    console.error('Rate Booking Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to rate booking' }, { status: 500 });
  }
}

