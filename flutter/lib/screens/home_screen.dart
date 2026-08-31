import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models.dart';
import '../api_service.dart';
import '../constants.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ServiceModel> _services = [];
  List<CategoryModel> _categories = [];
  List<TestimonialModel> _testimonials = [];
  List<FAQModel> _faqs = [];
  bool _loading = true;
  int _expandedFaq = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      ApiService.getServices(featured: true),
      ApiService.getCategories(),
      ApiService.getTestimonials(),
      ApiService.getFAQs(limit: 4),
    ]);
    if (mounted) {
      setState(() {
        _services = results[0] as List<ServiceModel>;
        _categories = results[1] as List<CategoryModel>;
        _testimonials = results[2] as List<TestimonialModel>;
        _faqs = results[3] as List<FAQModel>;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(kColorBg),
        body: _loading
            ? _buildSkeleton()
            : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(child: _buildHero()),
                  SliverToBoxAdapter(child: _buildTrustBar()),
                  SliverToBoxAdapter(child: _buildCategories()),
                  SliverToBoxAdapter(child: _buildFeaturedServices()),
                  SliverToBoxAdapter(child: _buildTestimonials()),
                  SliverToBoxAdapter(child: _buildFAQ()),
                  SliverToBoxAdapter(child: _buildFinalCTA()),
                  SliverToBoxAdapter(child: _buildFooter()),
                ],
              ),
        drawer: _buildDrawer(),
      ),
    );
  }

  // ─── Skeleton ───────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(kColorPrimary)),
          SizedBox(height: 16),
          Text('جاري التحميل...', style: TextStyle(color: Color(kColorTextLight))),
        ],
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(kColorBg),
      elevation: 1,
      floating: true,
      snap: true,
      pinned: false,
      leading: null,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(kColorBg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Color(kColorPrimary)),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                // Logo
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [BoxShadow(color: const Color(kColorPrimary).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('نسيم (Naseem)', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(kColorSecondary))),
                    Text('للتبريد والتكييف والخدمات', style: GoogleFonts.cairo(fontSize: 11, color: const Color(kColorTextLight))),
                  ],
                ),
                const Spacer(),
                // Book Now Button
                ElevatedButton(
                  onPressed: () => _navigateTo(context, 'booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(kColorPrimary),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    shadowColor: const Color(kColorPrimary).withOpacity(0.4),
                  ),
                  child: Text('📅 احجز الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
      toolbarHeight: 70,
    );
  }

  // ─── Hero ────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF3B2A1F), Color(0xFF5A3D2B), Color(0xFF7A5235)],
        ),
      ),
      child: Stack(
        children: [
          // Pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Title
                Text(
                  'مكيفك يستحق\nخدمة احترافية\nبضمان حقيقي',
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'تنظيف، صيانة، وإصلاح المكيفات في جدة\nفنيون معتمدون · ضمان 30 يوم · الدفع بعد الخدمة',
                  style: GoogleFonts.cairo(fontSize: 15, color: Colors.white.withOpacity(0.85), height: 1.7),
                ),
                const SizedBox(height: 28),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _navigateTo(context, 'booking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(kColorPrimary),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: const Color(kColorPrimary).withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month, size: 18),
                            const SizedBox(width: 6),
                            Text('احجز الآن', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _navigateTo(context, 'services'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('خدماتنا', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Stats
                FutureBuilder<Map<String, dynamic>>(
                  future: ApiService.getStats(),
                  builder: (context, snapshot) {
                    final customers = snapshot.data?['total_satisfied_customers'] ?? 0;
                    final rating = snapshot.data?['average_rating'] ?? 0.0;
                    
                    final customersText = customers > 0 ? '+$customers' : 'قريباً';
                    final ratingText = rating > 0.0 ? rating.toString() : 'قيد الانتظار';

                    return Row(
                      children: [
                        _buildHeroStat(customersText, 'عميل راضٍ', Icons.people, textFontSize: customers > 0 ? 20 : 16),
                        _buildStatDivider(),
                        _buildHeroStat(ratingText, 'متوسط التقييم', Icons.star, textFontSize: rating > 0.0 ? 20 : 14),
                        _buildStatDivider(),
                        _buildHeroStat('30', 'يوم ضمان', Icons.verified_user),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String num, String label, IconData icon, {double textFontSize = 20}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(kColorAccent), size: 20),
          const SizedBox(height: 4),
          Text(num, style: GoogleFonts.cairo(fontSize: textFontSize, fontWeight: FontWeight.w900, color: const Color(kColorAccent))),
          Text(label, style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: Colors.white12);
  }

  // ─── Trust Bar ──────────────────────────────────────────────────────
  Widget _buildTrustBar() {
    final items = [
      (Icons.verified, 'ضمان 30 يوم'),
      (Icons.credit_card, 'الدفع بعد الخدمة'),
      (Icons.engineering, 'فنيون محترفون'),
      (Icons.attach_money, 'أسعار شفافة'),
    ];
    return Container(
      color: const Color(kColorSecondary),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Row(
              children: [
                Icon(item.$1, color: const Color(kColorAccent), size: 18),
                const SizedBox(width: 8),
                Text(item.$2, style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  // ─── Categories ─────────────────────────────────────────────────────
  Widget _buildCategories() {
    if (_categories.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تصفح حسب التصنيف', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
          Text('اختر نوع الخدمة التي تحتاجها', style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight))),
          const SizedBox(height: 16),
          SizedBox(
            height: 95,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                return InkWell(
                  onTap: () => _navigateTo(context, 'services'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(kColorBorder)),
                      boxShadow: [BoxShadow(color: const Color(kColorSecondary).withOpacity(0.06), blurRadius: 8)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat.iconName, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 6),
                        Text(cat.nameAr, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(kColorSecondary)), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Featured Services ───────────────────────────────────────────────
  Widget _buildFeaturedServices() {
    if (_services.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(top: 32),
      color: const Color(kColorCardWarm),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('خدماتنا الأكثر طلباً', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
                  Text('جودة تُثبت نفسها في كل زيارة', style: GoogleFonts.cairo(fontSize: 13, color: const Color(kColorTextLight))),
                ],
              ),
              TextButton(
                onPressed: () => _navigateTo(context, 'services'),
                child: Text('عرض الكل ←', style: GoogleFonts.cairo(color: const Color(kColorPrimary), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_services.take(6).map((svc) => _buildServiceCard(svc))),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel svc) {
    final icons = {'تنظيف مكيف سبليت':'🧹','صيانة وإصلاح مكيفات':'🔧','تعبئة فريون':'❄️','لحام نحاس':'🔥','عقد صيانة دورية':'📋','تنظيف داكت سنترال':'🏢'};
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(kColorBorder)),
        boxShadow: [BoxShadow(color: const Color(kColorSecondary).withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/service_detail', arguments: svc);
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon / Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(kColorBg),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(kColorBorder)),
                ),
                child: Center(child: Text(icons[svc.nameAr] ?? '❄️', style: const TextStyle(fontSize: 30))),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(svc.nameAr, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(kColorSecondary))),
                    const SizedBox(height: 4),
                    Text(svc.shortDescriptionAr, style: GoogleFonts.cairo(fontSize: 13, color: const Color(kColorTextLight)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${svc.basePriceSar.toInt()} ريال', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 17, color: const Color(kColorPrimary))),
                        Text(' / ${svc.priceUnit}', style: GoogleFonts.cairo(fontSize: 12, color: const Color(kColorTextLight))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(kColorAccent).withOpacity(0.15),
                            border: Border.all(color: const Color(kColorAccent).withOpacity(0.35)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text('⭐ ضمان ${svc.warrantyDays}يوم', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF9A6F1A))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Testimonials ────────────────────────────────────────────────────
  Widget _buildTestimonials() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ماذا يقول عملاؤنا', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
                  Text('تجارب حقيقية من عملاء جدة', style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight))),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddReviewDialog(),
                icon: const Icon(Icons.star, size: 18),
                label: Text('أضف تقييمك', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(kColorPrimary),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_testimonials.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text('كن أول من يشاركنا رأيه!', style: GoogleFonts.cairo(fontSize: 16, color: const Color(kColorTextLight))),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: _testimonials.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final t = _testimonials[i];
                return Container(
                  width: 260,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(kColorBorder)),
                    boxShadow: [BoxShadow(color: const Color(kColorSecondary).withOpacity(0.06), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(kColorPrimary),
                            child: Text(t.customerName[0], style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.customerName, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(kColorSecondary))),
                              Text('📍 ${t.district}', style: GoogleFonts.cairo(fontSize: 12, color: const Color(kColorTextLight))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(children: List.generate(5, (j) => Text(j < t.rating ? '★' : '☆', style: const TextStyle(color: Color(kColorAccent), fontSize: 15)))),
                      const SizedBox(height: 6),
                      Expanded(child: Text('"${t.reviewTextAr}"', style: GoogleFonts.cairo(fontSize: 13, color: const Color(kColorTextLight), fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis, maxLines: 3)),
                      const SizedBox(height: 6),
                      Text('✅ ${t.serviceNameAr}', style: GoogleFonts.cairo(fontSize: 11, color: const Color(kColorPrimary), fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── FAQ ────────────────────────────────────────────────────────────
  Widget _buildFAQ() {
    if (_faqs.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الأسئلة الشائعة', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
          Text('إجابات على أبرز أسئلتكم', style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight))),
          const SizedBox(height: 16),
          ..._faqs.asMap().entries.map((e) {
            final i = e.key; final faq = e.value;
            final isOpen = _expandedFaq == i;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(kColorBorder)),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _expandedFaq = isOpen ? -1 : i),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: Text(faq.questionAr, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 15, color: const Color(kColorSecondary)))),
                          Icon(isOpen ? Icons.remove : Icons.add, color: const Color(kColorPrimary), size: 22),
                        ],
                      ),
                    ),
                  ),
                  if (isOpen) Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(faq.answerAr, style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight), height: 1.8)),
                  ),
                ],
              ),
            );
          }),
          Center(
            child: TextButton(
              onPressed: () => _navigateTo(context, 'faq'),
              child: Text('عرض جميع الأسئلة', style: GoogleFonts.cairo(color: const Color(kColorPrimary), fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Final CTA ──────────────────────────────────────────────────────
  Widget _buildFinalCTA() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(kColorSecondary), Color(0xFF5A3D2B)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('جاهز لتحسين أداء مكيفك؟', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('احجز الآن في أقل من دقيقة · الدفع بعد الخدمة فقط', style: GoogleFonts.cairo(fontSize: 14, color: Colors.white.withOpacity(0.8)), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateTo(context, 'booking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(kColorPrimary),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: Text('📅 احجز الآن مجاناً', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 17)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('💬 تواصل عبر واتساب', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Footer ─────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      color: const Color(kColorSecondary),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/logo.png'), fit: BoxFit.cover))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('نسيم (Naseem)', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                Text('للتبريد والتكييف والخدمات', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12)),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          Text('خدمات تنظيف وصيانة وإصلاح المكيفات في المملكة بأعلى معايير الجودة. فنيون محترفون، ضمان حقيقي.', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13, height: 1.7)),
          const Divider(color: Colors.white12, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('© ${DateTime.now().year} نسيم (Naseem). جميع الحقوق محفوظة.', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateTo(BuildContext context, String route) async {
    await Navigator.pushNamed(context, '/$route');
    if (route == 'admin' && mounted) {
      _loadData();
    }
  }

  void _showAddReviewDialog() {
    // A simple dialog for adding a review, can be expanded to make API call
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('أضف تقييمك', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('نشكرك على ثقتك بنسيم (Naseem). مشاركة تجربتك تهمنا!', style: GoogleFonts.cairo(fontSize: 14)),
              const SizedBox(height: 16),
              TextField(decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'التقييم (1 إلى 5)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'رأيك', border: OutlineInputBorder()), maxLines: 3),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شكراً لتقييمك! سيتم مراجعته وإضافته قريباً.')));
              },
              child: Text('إرسال', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(kColorBg),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(kColorPrimary)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(image: AssetImage('assets/images/logo.png'), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                Text('نسيم للتبريد والتكييف - Naseem', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // User Auth Section
          StreamBuilder<User?>(
            stream: (Firebase.apps.isNotEmpty) ? FirebaseAuth.instance.authStateChanges() : const Stream.empty(),
            builder: (context, snapshot) {
              final user = snapshot.data ?? (Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null);
              if (user != null) {
                final email = (user.email ?? '').toLowerCase().trim();
                final isAdmin = ApiService.kAdminEmails.contains(email);
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null, child: user.photoURL == null ? const Icon(Icons.person) : null),
                      title: Text(user.displayName ?? 'مستخدم', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                      subtitle: Text(user.email ?? '', style: const TextStyle(fontSize: 12)),
                    ),
                    if (isAdmin)
                      ListTile(
                        title: Text('لوحة الإدارة والتحكم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(kColorPrimary))),
                        onTap: () { Navigator.pop(context); _navigateTo(context, 'admin'); },
                      ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text('تسجيل الخروج', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: Colors.red)),
                      onTap: () async {
                        await AuthService.signOut();
                      },
                    ),
                    const Divider(),
                  ],
                );
              } else {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.login, color: Color(kColorPrimary)),
                      title: Text('تسجيل الدخول', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                      onTap: () async {
                        try {
                          final userCred = await AuthService.signInWithGoogle();
                          if (userCred == null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء تسجيل الدخول أو فشل الاتصال')));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                          }
                        }
                      },
                    ),
                    const Divider(),
                  ],
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Color(kColorPrimary)),
            title: Text('الرئيسية', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: Color(kColorPrimary)),
            title: Text('حسابي وطلباتي', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: const Color(kColorPrimary))),
            onTap: () { Navigator.pop(context); _navigateTo(context, 'profile'); },
          ),
          ListTile(
            leading: const Icon(Icons.build_circle_outlined, color: Color(kColorPrimary)),
            title: Text('خدماتنا', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            onTap: () { Navigator.pop(context); _navigateTo(context, 'services'); },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(kColorPrimary)),
            title: Text('من نحن', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            onTap: () { Navigator.pop(context); _navigateTo(context, 'about'); },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(kColorPrimary)),
            title: Text('الأسئلة الشائعة', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            onTap: () { Navigator.pop(context); _navigateTo(context, 'faq'); },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined, color: Color(kColorPrimary)),
            title: Text('تواصل معنا', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            onTap: () { Navigator.pop(context); _navigateTo(context, 'contact'); },
          ),
        ],
      ),
    );
  }
}


// ─── Grid Painter ────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
