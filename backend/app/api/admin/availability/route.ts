import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { DailyAvailability, Booking } from '@/models';
import { verifyAdminToken } from '@/lib/admin-auth-helper';

export const dynamic = 'force-dynamic';
export const revalidate = 0;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export async function OPTIONS() {
  return new NextResponse(null, { status: 200, headers: corsHeaders });
}

// GET /api/admin/availability?date=YYYY-MM-DD
export async function GET(request: NextRequest) {
  try {
    await verifyAdminToken(request);

    await connectToDatabase();
    const DailyAvailabilityModel = DailyAvailability();
    const BookingModel = Booking();
    
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');

    if (!date) {
      return NextResponse.json({ success: false, error: 'date parameter is required' }, { status: 400, headers: corsHeaders });
    }

    // Customer bookings for this date (excluding cancelled)
    const bookings = await BookingModel.find({ 
      preferred_date: date,
      status_id: { $ne: 'STAT-04' }
    }).select('slot_id').lean();

    const customerBookedSlots = bookings.map(b => b.slot_id);

    // Admin manual blocked slots
    const adminAvailability = await DailyAvailabilityModel.findOne({ date }).lean();
    const adminBlockedSlots = adminAvailability ? adminAvailability.blocked_slots : [];

    // Union of all busy slots
    const allBusySlots = Array.from(new Set([...customerBookedSlots, ...adminBlockedSlots]));

    return NextResponse.json({ 
      success: true, 
      data: allBusySlots,
      customer_slots: customerBookedSlots,
      admin_slots: adminBlockedSlots
    }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Admin Availability GET Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500, headers: corsHeaders });
  }
}

// POST /api/admin/availability
// Body: { date: 'YYYY-MM-DD', blocked_slots: ['SLOT-1', 'SLOT-2'] }
export async function POST(request: NextRequest) {
  try {
    await verifyAdminToken(request);

    await connectToDatabase();
    const DailyAvailabilityModel = DailyAvailability();
    
    const body = await request.json();
    const { date, blocked_slots } = body;

    if (!date || !Array.isArray(blocked_slots)) {
      return NextResponse.json({ success: false, error: 'Invalid payload' }, { status: 400, headers: corsHeaders });
    }

    await DailyAvailabilityModel.findOneAndUpdate(
      { date },
      { $set: { blocked_slots } },
      { upsert: true, new: true }
    );

    return NextResponse.json({ success: true, message: 'Availability updated' }, { headers: corsHeaders });
  } catch (error: any) {
    console.error('Admin Availability POST Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500, headers: corsHeaders });
  }
}

