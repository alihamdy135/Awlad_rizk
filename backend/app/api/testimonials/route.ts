import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Testimonial } from '@/models';

export async function GET() {
  try {
    await connectToDatabase();
    const TestimonialModel = Testimonial();
    const testimonials = await TestimonialModel.find({ is_active: true }).sort({ display_order: 1 }).lean();
    return NextResponse.json({ success: true, data: testimonials });
  } catch (error) {
    console.error('Testimonials API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch testimonials' }, { status: 500 });
  }
}
