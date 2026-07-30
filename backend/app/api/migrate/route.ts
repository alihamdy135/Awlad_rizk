import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Service, Testimonial } from '@/models';

export async function GET() {
  try {
    await connectToDatabase();
    
    const ServiceModel = Service();
    await ServiceModel.updateMany({}, { $set: { warranty_days: 30 } });

    const TestimonialModel = Testimonial();
    await TestimonialModel.deleteMany({});
    
    return NextResponse.json({ success: true, message: 'Migration done' });
  } catch (error) {
    console.error('Migration API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed' }, { status: 500 });
  }
}
