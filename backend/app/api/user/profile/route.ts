import { NextResponse } from 'next/server';
import { connectToDatabase } from '@/lib/mongodb';
import { UserProfile } from '@/models';
import { verifyOrDecodeToken } from '@/lib/firebase-auth-helper';

export async function GET(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.split('Bearer ')[1];
    const decoded = await verifyOrDecodeToken(token);
    const userId = decoded.uid;

    await connectToDatabase();
    const UserProfileModel = UserProfile();
    let profile = await UserProfileModel.findOne({ user_id: userId }).lean();

    if (!profile) {
      // Create default profile from decoded Google token
      const newProfile = new UserProfileModel({
        user_id: userId,
        full_name: decoded.name || '',
        email: decoded.email || '',
        phone: '',
        address: '',
        photo_url: decoded.picture || '',
      });
      await newProfile.save();
      profile = newProfile.toObject();
    }

    return NextResponse.json({ success: true, data: profile });
  } catch (error) {
    console.error('Get Profile Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to fetch profile' }, { status: 500 });
  }
}

export async function PUT(request: Request) {
  try {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, error: 'Unauthorized' }, { status: 401 });
    }

    const token = authHeader.split('Bearer ')[1];
    const decoded = await verifyOrDecodeToken(token);
    const userId = decoded.uid;

    await connectToDatabase();
    const UserProfileModel = UserProfile();
    const body = await request.json();

    const updatedProfile = await UserProfileModel.findOneAndUpdate(
      { user_id: userId },
      {
        full_name: body.full_name,
        phone: body.phone,
        address: body.address,
        photo_url: body.photo_url || decoded.picture || '',
        email: decoded.email || '',
      },
      { new: true, upsert: true }
    ).lean();

    return NextResponse.json({ success: true, data: updatedProfile });
  } catch (error) {
    console.error('Update Profile Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to update profile' }, { status: 500 });
  }
}

