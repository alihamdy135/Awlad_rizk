import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { FAQ } from '@/models';

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
    await connectToDatabase();
    const FAQModel = FAQ();
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '100');
    const faqs = await FAQModel.find({ is_active: true }).sort({ display_order: 1 }).limit(limit).lean();
    return NextResponse.json({ success: true, data: faqs }, { headers: corsHeaders });
  } catch (error) {
    console.error('FAQ API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch FAQs' }, { status: 500, headers: corsHeaders });
  }
}
