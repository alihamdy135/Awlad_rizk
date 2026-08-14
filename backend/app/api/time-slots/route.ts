import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { TimeSlot } from '@/models';


export const dynamic = 'force-dynamic';
export const revalidate = 0;

export async function GET() {
  try {
    await connectToDatabase();
    const TimeSlotModel = TimeSlot();
    const slots = await TimeSlotModel.find({ is_active: true }).sort({ display_order: 1 }).lean();
    return NextResponse.json({ success: true, data: slots });
  } catch (error) {
    console.error('TimeSlots API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch time slots' }, { status: 500 });
  }
}

