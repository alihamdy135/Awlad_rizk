import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking, Testimonial } from '@/models';

export async function GET() {
  try {
    await connectToDatabase();
    
    // 1. Get total bookings count (for satisfied customers)
    const BookingModel = Booking();
    const totalBookings = await BookingModel.countDocuments({ status: { $ne: 'cancelled' } });

    // 2. Get average rating from testimonials
    const TestimonialModel = Testimonial();
    const testimonials = await TestimonialModel.find({ is_active: true }).lean();
    
    let averageRating = 5.0; // Default if no reviews
    if (testimonials.length > 0) {
      const totalRating = testimonials.reduce((acc, curr) => acc + curr.rating, 0);
      averageRating = parseFloat((totalRating / testimonials.length).toFixed(1));
    }

    // Default to at least 0 bookings, though we can add a base offset if desired.
    return NextResponse.json({ 
      success: true, 
      data: {
        total_satisfied_customers: totalBookings,
        average_rating: averageRating,
      } 
    });
  } catch (error) {
    console.error('Stats API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch stats' }, { status: 500 });
  }
}
