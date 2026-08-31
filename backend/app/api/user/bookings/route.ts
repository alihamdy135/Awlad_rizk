import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking, Testimonial } from '@/models';
import { verifyOrDecodeToken } from '@/lib/firebase-auth-helper';

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
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401, headers: corsHeaders });
    }

    const token = authHeader.split('Bearer ')[1];
    const decoded = await verifyOrDecodeToken(token);
    const userId = decoded.uid;
    const userEmail = decoded.email;

    await connectToDatabase();
    const BookingModel = Booking();

    // Fix: use correct sort field _id / created_at; ensure private per account strict
    const cleanEmail = (userEmail || '').toLowerCase().trim();
    const cleanUid = (userId || '').trim();
    const orConditions: any[] = [];
    if (cleanUid) orConditions.push({ user_id: cleanUid });
    if (cleanEmail) orConditions.push({ customer_email: cleanEmail });
    if (orConditions.length === 0) {
      return NextResponse.json({ success: true, data: [] }, { headers: corsHeaders });
    }
    const userBookings = await BookingModel.find({
      $or: orConditions
    }).sort({ _id: -1 }).lean();

    return NextResponse.json({ success: true, data: userBookings }, { headers: corsHeaders });
  } catch (error) {
    console.error('Get User Bookings Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch bookings' }, { status: 500, headers: corsHeaders });
  }
}

export async function POST(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401, headers: corsHeaders });
    }

    const token = authHeader.split('Bearer ')[1];
    const decoded = await verifyOrDecodeToken(token);
    const userId = decoded.uid;

    await connectToDatabase();
    const BookingModel = Booking();
    const TestimonialModel = Testimonial();

    const { booking_id, rating, review_text } = await request.json();

    if (!booking_id || !rating) {
      return NextResponse.json({ success: false, error: 'booking_id and rating are required' }, { status: 400, headers: corsHeaders });
    }

    const cleanUpdEmail = (decoded.email || '').toLowerCase().trim();
    const orUpd: any[] = [{ user_id: userId }];
    if (cleanUpdEmail) orUpd.push({ customer_email: cleanUpdEmail });
    const updatedBooking = await BookingModel.findOneAndUpdate(
      { booking_id, $or: orUpd },
      { rating, review_text },
      { new: true }
    ).lean();

    if (!updatedBooking) {
      return NextResponse.json({ success: false, error: 'Booking not found or unauthorized' }, { status: 404, headers: corsHeaders });
    }

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

    return NextResponse.json({ success: true, data: updatedBooking }, { headers: corsHeaders });
  } catch (error) {
    console.error('Rate Booking Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to rate booking' }, { status: 500, headers: corsHeaders });
  }
}
