import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { ServiceArea } from '@/models';

export async function GET() {
  try {
    await connectToDatabase();
    const ServiceAreaModel = ServiceArea();
    const areas = await ServiceAreaModel.find({ is_covered: true }).sort({ display_order: 1 }).lean();
    return NextResponse.json({ success: true, data: areas });
  } catch (error) {
    console.error('ServiceAreas API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch service areas' }, { status: 500 });
  }
}
