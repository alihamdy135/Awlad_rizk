import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });
import { connectToDatabase } from '../lib/mongodb';
import { Service, Testimonial } from '../models';

async function run() {
  try {
    await connectToDatabase();
    
    console.log('Connected to DB...');

    // 1. Update Warranty to 30 days for all services
    const ServiceModel = Service();
    const serviceResult = await ServiceModel.updateMany({}, { $set: { warranty_days: 30 } });
    console.log(`Updated warranty for ${serviceResult.modifiedCount} services.`);

    // 2. Delete all existing testimonials
    const TestimonialModel = Testimonial();
    const testimonialResult = await TestimonialModel.deleteMany({});
    console.log(`Deleted ${testimonialResult.deletedCount} testimonials.`);

    console.log('Database update complete!');
    process.exit(0);
  } catch (err) {
    console.error('Error updating db:', err);
    process.exit(1);
  }
}

run();
