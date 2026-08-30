import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Service } from '@/models';


export const dynamic = 'force-dynamic';
export const revalidate = 0;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS(request: NextRequest) {
  return new NextResponse(null, { status: 200, headers: corsHeaders });
}

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

    let services = [];
    if (featured === 'true') {
      services = await ServiceModel.aggregate([
        { $match: query },
        {
          $lookup: {
            from: 'bookings',
            localField: 'service_id',
            foreignField: 'service_id',
            as: 'bookings'
          }
        },
        { $addFields: { bookingsCount: { $size: "$bookings" } } },
        { $sort: { bookingsCount: -1, name_ar: 1 } },
        { $project: { bookings: 0 } }
      ]);
    } else {
      services = await ServiceModel.find(query).sort({ display_order: 1 }).lean();
    }
    
    return NextResponse.json({ success: true, data: services }, { headers: corsHeaders });
  } catch (error) {
    console.error('Services API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch services' }, { status: 500, headers: corsHeaders });
  }
}
