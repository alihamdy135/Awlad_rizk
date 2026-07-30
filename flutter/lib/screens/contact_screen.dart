import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          title: Text('تواصل معنا', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('نحن هنا لخدمتك!', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(kColorSecondary))),
              const SizedBox(height: 8),
              Text('لا تتردد في التواصل معنا لأي استفسار أو لطلب خدمة طارئة. فريقنا متواجد للرد عليك في أسرع وقت.', style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight), height: 1.6)),
              
              const SizedBox(height: 32),
              _buildContactCard(
                icon: Icons.phone_in_talk_outlined,
                title: 'اتصل بنا المبيعات',
                subtitle: '+966 50 000 0000',
                color: const Color(kColorPrimary),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.support_agent_outlined,
                title: 'الدعم الفني',
                subtitle: '+966 50 000 0001',
                color: const Color(kColorPrimary),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.email_outlined,
                title: 'البريد الإلكتروني',
                subtitle: 'info@awlad-rizk.com',
                color: const Color(kColorPrimary),
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.location_on_outlined,
                title: 'العنوان',
                subtitle: 'جدة، المملكة العربية السعودية',
                color: const Color(kColorPrimary),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat),
                  label: Text('تواصل معنا عبر واتساب', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(kColorBorder)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight))),
                Text(subtitle, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
