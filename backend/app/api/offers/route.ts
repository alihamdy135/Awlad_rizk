import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Offer } from '@/models';


export const dynamic = 'force-dynamic';
export const revalidate = 0;

export async function GET() {
  try {
    await connectToDatabase();
    const OfferModel = Offer();
    const today = new Date().toISOString().split('T')[0];
    const offers = await OfferModel.find({
      is_active: true,
      $or: [
        { end_date: { $gte: today } },
        { end_date: { $exists: false } },
        { end_date: '' },
      ]
    }).sort({ display_order: 1 }).lean();
    return NextResponse.json({ success: true, data: offers });
  } catch (error) {
    console.error('Offers API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch offers' }, { status: 500 });
  }
}

