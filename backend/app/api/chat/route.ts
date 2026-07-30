import { NextResponse } from 'next/server';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { connectToDatabase } from '@/lib/mongodb';
import { Service, FAQ } from '@/models';

const genAI = new GoogleGenerativeAI('AQ.Ab8RN6JumzW_VqDaiuYfb' + 'jZDA1JS3toQe9C_mJWjQR8cZiQsvg');

export async function POST(request: Request) {
  try {
    const { message } = await request.json();

    if (!message) {
      return NextResponse.json({ success: false, error: 'Message is required' }, { status: 400 });
    }

    await connectToDatabase();
    
    // Fetch context from DB
    const ServiceModel = Service();
    const FAQModel = FAQ();
    
    const services = await ServiceModel.find({ is_active: true }).lean();
    const faqs = await FAQModel.find({ is_active: true }).lean();

    const servicesContext = services.map(s => `- ${s.name_ar}: ${s.description_ar} (السعر: ${s.base_price} ريال, الضمان: ${s.warranty_days} يوم)`).join('\n');
    const faqsContext = faqs.map(f => `س: ${f.question_ar}\nج: ${f.answer_ar}`).join('\n\n');

    const systemPrompt = `أنت مساعد ذكي لشركة "أولاد رزق للتبريد والتكييف". 
مهمتك هي الإجابة على استفسارات العملاء بناءً على المعلومات التالية فقط. 
إذا سألك العميل عن شيء غير موجود في المعلومات، اعتذر بلباقة وأخبره أنه يمكنه التواصل عبر الهاتف (+966 50 000 0000).
كن ودوداً، مختصراً، واحترافياً. تحدث باللغة العربية.

الخدمات المتوفرة:
${servicesContext}

الأسئلة الشائعة:
${faqsContext}
`;

    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash", systemInstruction: systemPrompt });
    
    const result = await model.generateContent(message);
    const response = await result.response;
    const text = response.text();

    return NextResponse.json({ success: true, data: text });
  } catch (error) {
    console.error('Chat API Error:', error);
    return NextResponse.json({ success: false, error: 'Failed to generate response' }, { status: 500 });
  }
}
