import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking } from '@/models';

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
    const BookingModel = Booking();
    
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');

    if (!date) {
      return NextResponse.json({ success: false, error: 'date parameter is required' }, { status: 400, headers: corsHeaders });
    }

    // Find all bookings for this date that are NOT cancelled (STAT-04)
    const bookings = await BookingModel.find({ 
      preferred_date: date,
      status_id: { $ne: 'STAT-04' }
    }).select('slot_id').lean();

    const bookedSlots = bookings.map(b => b.slot_id);

    return NextResponse.json({ success: true, data: bookedSlots }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Booked Slots API Error:', error);
    return NextResponse.json({ success: false, error: error.message || 'Failed to fetch booked slots' }, { status: 500, headers: corsHeaders });
  }
}
