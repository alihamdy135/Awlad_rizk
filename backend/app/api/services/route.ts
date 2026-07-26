import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Service } from '@/models';

export async function GET(request: Request) {
  try {
    await connectToDatabase();
    const ServiceModel = Service();
    const { searchParams } = new URL(request.url);
    const featured = searchParams.get('featured');
    const category = searchParams.get('category');

    const query: Record<string, unknown> = { is_active: true };
    if (featured === 'true') query.is_featured = true;
    if (category) query.category_id = category;

    const services = await ServiceModel.find(query).sort({ display_order: 1 }).lean();
    return NextResponse.json({ success: true, data: services });
  } catch (error) {
    console.error('Services API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch services' }, { status: 500 });
  }
}
