import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { DailyAvailability } from '@/models';
import { verifyAdminToken } from '@/lib/admin-auth-helper';

export const dynamic = 'force-dynamic';

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
    const authError = await verifyAdminToken(request);
    if (authError) return authError;

    await connectToDatabase();
    const DailyAvailabilityModel = DailyAvailability();
    
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');

    if (!date) {
      return NextResponse.json({ success: false, error: 'date parameter is required' }, { status: 400, headers: corsHeaders });
    }

    const adminAvailability = await DailyAvailabilityModel.findOne({ date }).lean();
    
    return NextResponse.json({ 
      success: true, 
      data: adminAvailability ? adminAvailability.blocked_slots : [] 
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
    const authError = await verifyAdminToken(request);
    if (authError) return authError;

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
