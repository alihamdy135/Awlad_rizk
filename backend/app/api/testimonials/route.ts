import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Testimonial } from '@/models';


export const dynamic = 'force-dynamic';
export const revalidate = 0;

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

export async function POST(request: Request) {
  try {
    await connectToDatabase();
    const TestimonialModel = Testimonial();
    const body = await request.json();

    // Generate testimonial ID
    const count = await TestimonialModel.countDocuments();
    const testimonial_id = `TEST-${String(1001 + count).padStart(4, '0')}`;

    const testimonial = new TestimonialModel({
      ...body,
      testimonial_id,
      is_active: true, // Immediately show the review to the user
      display_order: count + 1,
    });

    await testimonial.save();
    return NextResponse.json({ success: true, data: testimonial }, { status: 201 });
  } catch (error) {
    console.error('Testimonials API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to create testimonial' }, { status: 500 });
  }
}

