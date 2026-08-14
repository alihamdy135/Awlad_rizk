import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { FAQ } from '@/models';


export const dynamic = 'force-dynamic';
export const revalidate = 0;

export async function GET(request: Request) {
  try {
    await connectToDatabase();
    const FAQModel = FAQ();
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '100');
    const faqs = await FAQModel.find({ is_active: true }).sort({ display_order: 1 }).limit(limit).lean();
    return NextResponse.json({ success: true, data: faqs });
  } catch (error) {
    console.error('FAQ API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch FAQs' }, { status: 500 });
  }
}

