import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Category } from '@/models';


export const dynamic = 'force-dynamic';
export const revalidate = 0;

export async function GET() {
  try {
    await connectToDatabase();
    const CategoryModel = Category();
    const categories = await CategoryModel.find({ is_active: true }).sort({ display_order: 1 }).lean();
    return NextResponse.json({ success: true, data: categories });
  } catch (error) {
    console.error('Categories API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch categories' }, { status: 500 });
  }
}

