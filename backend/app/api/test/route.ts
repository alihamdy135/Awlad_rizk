import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  return NextResponse.json({ message: 'Hello from Vercel API test!', timestamp: new Date().toISOString() });
}

export async function POST() {
  return NextResponse.json({ message: 'Hello from Vercel API test POST!', timestamp: new Date().toISOString() });
}
