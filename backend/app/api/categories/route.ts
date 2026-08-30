import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Category } from '@/models';

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

export async function GET() {
  try {
    await connectToDatabase();
    const CategoryModel = Category();
    const categories = await CategoryModel.find({ is_active: true }).sort({ display_order: 1 }).lean();
    return NextResponse.json({ success: true, data: categories }, { headers: corsHeaders });
  } catch (error) {
    console.error('Categories API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch categories' }, { status: 500, headers: corsHeaders });
  }
}
