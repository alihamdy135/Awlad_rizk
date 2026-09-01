import { NextRequest, NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { Booking } from '@/models';
import { verifyOrDecodeToken } from '@/lib/firebase-auth-helper';

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

export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('Authorization');
    let user_id = '';
    let customer_email = '';
    let customer_name = '';

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split('Bearer ')[1];
      try {
        const decoded = await verifyOrDecodeToken(token);
        user_id = decoded.uid || '';
        customer_email = decoded.email || '';
        customer_name = decoded.name || '';
      } catch (err) {
        console.warn('Booking Auth token warning:', err);
      }
    }

    await connectToDatabase();
    const BookingModel = Booking();
    const { DailyAvailability, Service } = await import('@/models');
    const DailyAvailabilityModel = DailyAvailability();
    const ServiceModel = Service();
    const body = await request.json();

    // Validate required fields
    if (!body.preferred_date || !body.slot_id || !body.service_id || !body.area_id) {
      return NextResponse.json({ success: false, error: 'Missing required booking fields (date, slot, service, area)' }, { status: 400, headers: corsHeaders });
    }
    // Load service to determine pricing type
    let servicePricingType = 'fixed';
    let serviceIsOnVisit = false;
    try {
      const svc = await ServiceModel.findOne({ service_id: body.service_id }).lean() as any;
      if (svc) {
        servicePricingType = svc.pricing_type || (svc.is_price_on_visit ? 'on_visit' : 'fixed');
        serviceIsOnVisit = servicePricingType === 'on_visit' || !!svc.is_price_on_visit;
      }
    } catch (_) {}

    // Prevent double-booking: check if slot already taken for same date (excluding cancelled)
    const existingBooking = await BookingModel.findOne({
      preferred_date: body.preferred_date,
      slot_id: body.slot_id,
      status_id: { $ne: 'STAT-04' },
    }).lean();
    if (existingBooking) {
      return NextResponse.json({ success: false, error: 'هذا الموعد محجوز بالفعل. الرجاء اختيار وقت آخر.' }, { status: 409, headers: corsHeaders });
    }
    // Also check admin blocked slots
    const adminBlock = await DailyAvailabilityModel.findOne({ date: body.preferred_date }).lean();
    if (adminBlock && adminBlock.blocked_slots.includes(body.slot_id)) {
      return NextResponse.json({ success: false, error: 'هذا الوقت غير متاح حالياً (مشغول من قبل الإدارة).' }, { status: 409, headers: corsHeaders });
    }

    const final_name = customer_name || body.customer_name || 'عميل';
    const final_email = customer_email || body.customer_email || '';
    // Enforce private per-account: if authenticated, use token data; else fallback to body
    const final_user_id = user_id || body.user_id || `guest_${Date.now()}`;

    // Generate collision-proof unique booking ID
    const count = await BookingModel.countDocuments();
    const uniqueSuffix = Date.now().toString().slice(-6);
    const booking_id = `BK-${String(100001 + count).padStart(6, '0')}-${uniqueSuffix}`;

    // Handle pricing: if on_visit, estimated_price is 0 and final will be set on completion
    const estimated = serviceIsOnVisit ? 0 : Number(body.estimated_price_sar || body.total_amount_sar || 0);
    const booking = new BookingModel({
      ...body,
      customer_name: final_name,
      customer_email: final_email,
      user_id: final_user_id,
      booking_id,
      status_id: 'STAT-01',
      status_code: 'STAT-01',
      estimated_price_sar: estimated,
      final_price_sar: null,
      pricing_type: servicePricingType,
      is_price_on_visit: serviceIsOnVisit,
      created_at: new Date().toISOString(),
    });

    await booking.save();
    return NextResponse.json({ success: true, data: booking, booking_id }, { status: 201, headers: corsHeaders });
  } catch (error: any) {
    console.error('Bookings API Error:', error);
    return NextResponse.json({ success: false, error: error.message || 'Failed to create booking' }, { status: 500, headers: corsHeaders });
  }
}

export async function GET(request: NextRequest) {
  try {
    // Secure: require auth, return only own bookings for users, all for admins
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Unauthorized - token required' }, { status: 401, headers: corsHeaders });
    }
    const token = authHeader.split('Bearer ')[1];
    let decoded: any = null;
    try {
      decoded = await verifyOrDecodeToken(token);
    } catch (e) {
      return NextResponse.json({ success: false, error: 'Invalid token' }, { status: 401, headers: corsHeaders });
    }
    const email = (decoded.email || '').toLowerCase().trim();
    const uid = decoded.uid || '';
    const { ADMIN_EMAILS } = await import('@/lib/admin-auth-helper');
    const isAdmin = ADMIN_EMAILS.map((x: string) => x.toLowerCase().trim()).includes(email);

    await connectToDatabase();
    const BookingModel = Booking();
    let bookings;
    if (isAdmin) {
      bookings = await BookingModel.find({}).sort({ _id: -1 }).lean();
    } else {
      // Private per account: only own bookings
      bookings = await BookingModel.find({
        $or: [{ user_id: uid }, { customer_email: email }],
      }).sort({ _id: -1 }).lean();
    }
    return NextResponse.json({ success: true, data: bookings }, { headers: corsHeaders });
  } catch (error: any) {
    return NextResponse.json({ success: false, error: 'Failed to fetch bookings' }, { status: 500, headers: corsHeaders });
  }
}
