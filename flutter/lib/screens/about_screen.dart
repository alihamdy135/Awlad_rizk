import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          title: Text('من نحن', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(kColorPrimary).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(kColorPrimary).withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 100, height: 100),
                    const SizedBox(height: 16),
                    Text('نسيم للتبريد والتكييف - Naseem', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(kColorSecondary))),
                    Text('خبرة تتجاوز 10 سنوات في خدمتكم', style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorPrimary))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Text('قصتنا', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(kColorSecondary))),
              const SizedBox(height: 12),
              Text(
                'تأسست شركة نسيم (Naseem) بهدف تقديم خدمات تبريد وتكييف استثنائية وعالية الجودة في المملكة. انطلقنا من رؤية واضحة وهي راحة العميل في منزله ومقر عمله، ونجحنا في كسب ثقة آلاف العملاء بفضل فريقنا المحترف والتزامنا بالمواعيد والمصداقية التامة.',
                style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight), height: 1.8),
              ),
              
              const SizedBox(height: 32),
              Text('لماذا تختارنا؟', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(kColorSecondary))),
              const SizedBox(height: 16),
              
              _buildFeatureItem(Icons.verified_user, 'ضمان حقيقي', 'نقدم ضماناً على جميع خدمات الصيانة والتركيب لضمان راحة بالك.'),
              _buildFeatureItem(Icons.speed, 'سرعة الإنجاز', 'نصلك في أسرع وقت وننجز العمل بكفاءة واحترافية عالية.'),
              _buildFeatureItem(Icons.engineering, 'فريق متخصص', 'فنيون مدربون تدريباً عالياً للتعامل مع أحدث أجهزة التكييف.'),
              _buildFeatureItem(Icons.support_agent, 'خدمة عملاء 24/7', 'متواجدون دائماً للرد على استفساراتكم وحل مشاكلكم.'),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(kColorPrimary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(kColorPrimary), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
                const SizedBox(height: 4),
                Text(description, style: GoogleFonts.cairo(fontSize: 13, color: const Color(kColorTextLight))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
