import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the service passed via arguments
    final service = ModalRoute.of(context)?.settings.arguments as ServiceModel?;

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: Text('خطأ', style: GoogleFonts.cairo())),
        body: Center(child: Text('الخدمة غير موجودة', style: GoogleFonts.cairo())),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          title: Text('تفاصيل الخدمة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroImage(),
              _buildHeaderInfo(service),
              const SizedBox(height: 24),
              _buildDescription(service),
              const SizedBox(height: 24),
              _buildFeaturesList(),
            ],
          ),
        ),
        bottomSheet: _buildBottomBar(context, service),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        color: Color(kColorPrimaryDark),
        image: DecorationImage(
          image: AssetImage('assets/images/logo.png'),
          fit: BoxFit.contain,
          opacity: 0.2,
        ),
      ),
      child: const Center(
        child: Text('❄️', style: TextStyle(fontSize: 80)),
      ),
    );
  }

  Widget _buildHeaderInfo(ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(kColorPrimary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'رقم الخدمة: ${service.serviceId}',
                  style: GoogleFonts.cairo(color: const Color(kColorPrimary), fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              if (service.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(kColorAccent),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('الأكثر طلباً', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            service.nameAr,
            style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(kColorSecondary)),
          ),
          const SizedBox(height: 8),
          Text(
            service.shortDescriptionAr,
            style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ServiceModel service) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('السعر والضمان', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.payments_outlined,
                  title: 'سعر يبدأ من',
                  value: '${service.basePriceSar} ريال',
                  subtitle: service.priceUnit,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.verified_user_outlined,
                  title: 'فترة الضمان',
                  value: '${service.warrantyDays} يوم',
                  subtitle: 'ضمان حقيقي',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(kColorBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(kColorPrimary), size: 28),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.cairo(fontSize: 12, color: const Color(kColorTextLight))),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
          Text(subtitle, style: GoogleFonts.cairo(fontSize: 11, color: const Color(kColorPrimary))),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ماذا تشمل هذه الخدمة؟', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
          const SizedBox(height: 16),
          _buildFeatureItem('استخدام قطع غيار أصلية ومعتمدة.'),
          _buildFeatureItem('فنيون متخصصون بخبرة لا تقل عن 5 سنوات.'),
          _buildFeatureItem('سرعة في التنفيذ والوصول في الموعد.'),
          _buildFeatureItem('تعقيم ونظافة المكان بعد الانتهاء من العمل.'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF25D366), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight)))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ServiceModel service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/booking', arguments: service);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text('احجز هذه الخدمة الآن', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
