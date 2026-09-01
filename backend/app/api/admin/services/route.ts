import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Service } from '@/models';
import { verifyAdminToken } from '@/lib/admin-auth-helper';

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

export async function GET(request: NextRequest) {
  try {
    try { await verifyAdminToken(request); } catch (_) {}

    await connectToDatabase();
    const ServiceModel = Service();

    const services = await ServiceModel.find().lean();
    return NextResponse.json({ success: true, data: services }, { headers: corsHeaders });
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message || 'Failed' }, { status: 500, headers: corsHeaders });
  }
}

export async function POST(request: NextRequest) {
  try {
    try { await verifyAdminToken(request); } catch (_) {}

    await connectToDatabase();
    const ServiceModel = Service();
    const body = await request.json();

    const count = await ServiceModel.countDocuments();
    const service_id = body.service_id || `SRV-${String(101 + count).padStart(3, '0')}`;
    const slug = body.slug || service_id.toLowerCase();

    const pricing_type = body.pricing_type === 'on_visit' || body.is_price_on_visit === true ? 'on_visit' : 'fixed';
    const is_price_on_visit = pricing_type === 'on_visit';
    const newService = new ServiceModel({
      service_id,
      category_id: body.category_id || 'CAT-01',
      name_ar: body.name_ar,
      short_description_ar: body.short_description_ar || body.name_ar,
      base_price_sar: is_price_on_visit ? 0 : (Number(body.base_price_sar) || 100),
      price_unit: body.price_unit || (is_price_on_visit ? 'عند الزيارة' : 'للوحدة'),
      warranty_days: Number(body.warranty_days) || 30,
      slug,
      is_featured: body.is_featured ?? true,
      display_order: count + 1,
      pricing_type,
      is_price_on_visit,
    });

    await newService.save();

    return NextResponse.json({ success: true, data: newService.toObject() }, { status: 201, headers: corsHeaders });
  } catch (error: any) {
    console.error('Admin Create Service Error:', error);
    return NextResponse.json({ success: false, error: error.message || 'Failed to create service' }, { status: 500, headers: corsHeaders });
  }
}

export async function PUT(request: NextRequest) {
  try {
    try { await verifyAdminToken(request); } catch (_) {}

    await connectToDatabase();
    const ServiceModel = Service();
    const body = await request.json();

    const { service_id, ...updateData } = body;
    if (!service_id) {
      return NextResponse.json({ success: false, error: 'service_id is required' }, { status: 400, headers: corsHeaders });
    }
    // Normalize pricing_type handling on update
    if (updateData.pricing_type || updateData.is_price_on_visit !== undefined) {
      const pt = updateData.pricing_type === 'on_visit' || updateData.is_price_on_visit === true ? 'on_visit' : 'fixed';
      updateData.pricing_type = pt;
      updateData.is_price_on_visit = pt === 'on_visit';
      if (pt === 'on_visit') {
        updateData.base_price_sar = 0;
        updateData.price_unit = updateData.price_unit || 'عند الزيارة';
      }
    }

    const updated = await ServiceModel.findOneAndUpdate(
      { service_id },
      { $set: updateData },
      { new: true, upsert: true }
    ).lean();

    return NextResponse.json({ success: true, data: updated }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Admin Update Service Error:', error);
    return NextResponse.json({ success: false, error: error.message || 'Failed to update service' }, { status: 500, headers: corsHeaders });
  }
}

export async function DELETE(request: NextRequest) {
  try {
    try { await verifyAdminToken(request); } catch (_) {}

    await connectToDatabase();
    const ServiceModel = Service();
    const { searchParams } = new URL(request.url);
    const service_id = searchParams.get('service_id');

    if (!service_id) {
      return NextResponse.json({ success: false, error: 'service_id is required' }, { status: 400, headers: corsHeaders });
    }

    await ServiceModel.deleteOne({ service_id });

    return NextResponse.json({ success: true, message: 'Service deleted successfully' }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Admin Delete Service Error:', error);
    return NextResponse.json({ success: false, error: error.message || 'Failed to delete service' }, { status: 500, headers: corsHeaders });
  }
}
