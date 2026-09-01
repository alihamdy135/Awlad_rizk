import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api_service.dart';
import '../constants.dart';
import '../models.dart';
import '../models/user_profile.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  List<UserBookingModel> _allBookings = [];
  List<ServiceModel> _services = [];
  String _selectedFilter = 'ALL';

  // Analytics state
  Map<String, dynamic>? _analytics;
  int _analyticsYear = DateTime.now().year;
  int _analyticsMonth = DateTime.now().month;
  bool _isLoadingAnalytics = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    final stats = await ApiService.getAdminStats();
    final bookings = await ApiService.getAllBookingsAdmin();
    final services = await ApiService.getServices();
    final analytics = await ApiService.getAdminAnalytics(year: _analyticsYear, month: _analyticsMonth);

    if (mounted) {
      setState(() {
        _stats = stats;
        _allBookings = bookings;
        _services = services;
        _analytics = analytics;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoadingAnalytics = true);
    final analytics = await ApiService.getAdminAnalytics(year: _analyticsYear, month: _analyticsMonth);
    if (mounted) setState(() { _analytics = analytics; _isLoadingAnalytics = false; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<UserBookingModel> get _filteredBookings {
    if (_selectedFilter == 'ALL') return _allBookings;
    return _allBookings.where((b) {
      final st = b.statusCode.toUpperCase();
      if (_selectedFilter == 'STAT-01') return st == 'STAT-01' || st.contains('PENDING') || st.contains('انتظار');
      if (_selectedFilter == 'STAT-02') return st == 'STAT-02' || st.contains('PROGRESS') || st.contains('عمل');
      if (_selectedFilter == 'STAT-03') return st == 'STAT-03' || st.contains('COMPLETED') || st.contains('مكتمل');
      if (_selectedFilter == 'STAT-04') return st == 'STAT-04' || st.contains('CANCEL') || st.contains('ملغي');
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!ApiService.isAdmin()) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة التحكم')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('عذراً، هذه الصفحة مخصصة للمسؤولين والأدمن فقط.', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          title: Text('لوحة التحكم والإدارة (Admin)', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAdminData,
              tooltip: 'تحديث البيانات',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(kColorPrimary),
            labelColor: const Color(kColorPrimary),
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.analytics_outlined), text: 'الإحصائيات'),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'طلبات العملاء'),
              Tab(icon: Icon(Icons.build_circle_outlined), text: 'إدارة الخدمات'),
              Tab(icon: Icon(Icons.bar_chart), text: 'التحليل'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(kColorPrimary)))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildStatsTab(),
                  _buildBookingsTab(),
                  _buildServicesTab(),
                  _buildAnalyticsTab(),
                ],
              ),
      ),
    );
  }

  // ─── Tab 1: Stats ──────────────────────────────────────────────────
  Widget _buildStatsTab() {
    final totalBookings = _stats?['total_bookings'] ?? _allBookings.length;
    final totalRevenue = _stats?['total_revenue_sar'] ?? 0;
    final pending = _stats?['pending_count'] ?? 0;
    final inProgress = _stats?['in_progress_count'] ?? 0;
    final completed = _stats?['completed_count'] ?? 0;
    final totalServices = _stats?['total_services'] ?? _services.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(kColorPrimary), Color(kColorSecondary)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(kColorPrimary).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('أهلاً بك في لوحة الإدارة', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_user, color: Color(kColorAccent), size: 18),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('إدارة وتعديل خدمات ومبيعات التطبيق فورياً', style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('ملخص الأداء والمبيعات', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(kColorSecondary))),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              _buildStatCard('إجمالي الحجوزات', '$totalBookings طلب', Icons.shopping_bag_outlined, Colors.blue),
              _buildStatCard('إجمالي الأرباح', '$totalRevenue ريال', Icons.attach_money, Colors.green),
              _buildStatCard('قيد الانتظار', '$pending طلب', Icons.hourglass_empty, Colors.orange),
              _buildStatCard('طلبات قائمة', '$inProgress طلب', Icons.sync, Colors.indigo),
              _buildStatCard('طلبات مكتملة', '$completed طلب', Icons.check_circle_outline, Colors.teal),
              _buildStatCard('عدد الخدمات', '$totalServices خدمة', Icons.build, Colors.purple),
            ],
          ),

          const SizedBox(height: 24),
          Text('إدارة سريعة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(kColorSecondary))),
          const SizedBox(height: 12),
          
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/admin_availability');
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(kColorPrimary).withOpacity(0.3)),
                boxShadow: [BoxShadow(color: const Color(kColorPrimary).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(kColorPrimary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month_outlined, color: Color(kColorPrimary)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إدارة الأوقات (Slots)', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(kColorSecondary))),
                        Text('تحديد الأوقات المتاحة أو المشغولة', style: GoogleFonts.cairo(color: const Color(kColorTextLight), fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Color(kColorPrimary)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              Text(title, style: GoogleFonts.cairo(color: Colors.grey[700], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }

  // ─── Tab 2: Bookings ───────────────────────────────────────────────
  Widget _buildBookingsTab() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildFilterChip('الكل (${_allBookings.length})', 'ALL'),
              _buildFilterChip('🟡 قيد الانتظار', 'STAT-01'),
              _buildFilterChip('🔵 جاري العمل', 'STAT-02'),
              _buildFilterChip('🟢 مكتمل', 'STAT-03'),
              _buildFilterChip('🔴 ملغي', 'STAT-04'),
            ],
          ),
        ),
        Expanded(
          child: _filteredBookings.isEmpty
              ? Center(child: Text('لا توجد طلبات في هذا القسم حالياً', style: GoogleFonts.cairo(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _filteredBookings[index];
                    return _buildAdminBookingCard(booking);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black87, fontSize: 12)),
        selected: isSelected,
        selectedColor: const Color(kColorPrimary),
        onSelected: (val) {
          if (val) setState(() => _selectedFilter = value);
        },
      ),
    );
  }

  String _getServiceName(String serviceId) {
    final found = _services.firstWhere(
      (s) => s.serviceId == serviceId || s.id == serviceId,
      orElse: () => ServiceModel(id: '', serviceId: '', categoryId: '', nameAr: serviceId.isNotEmpty ? serviceId : 'خدمة تكييف', shortDescriptionAr: '', basePriceSar: 0, priceUnit: '', warrantyDays: 0, slug: '', isFeatured: false),
    );
    return found.nameAr.isNotEmpty ? found.nameAr : (serviceId.isNotEmpty ? serviceId : 'خدمة تكييف وتبريد');
  }

  ServiceModel? _getServiceById(String serviceId) {
    try {
      return _services.firstWhere((s) => s.serviceId == serviceId || s.id == serviceId);
    } catch (_) { return null; }
  }

  String _getAreaName(String areaId) {
    final found = kServiceAreas.firstWhere(
      (a) => a['id'] == areaId,
      orElse: () => {'name': areaId.isNotEmpty ? areaId : 'جدة'},
    );
    return found['name'] ?? areaId;
  }

  String _getSlotName(String slotId) {
    final found = kTimeSlots.firstWhere(
      (s) => s['id'] == slotId,
      orElse: () => {'name': slotId},
    );
    return found['name'] ?? slotId;
  }

  Widget _buildAdminBookingCard(UserBookingModel booking) {
    final serviceName = _getServiceName(booking.serviceId);
    final areaName = _getAreaName(booking.areaId);
    final slotName = _getSlotName(booking.slotId);
    final svc = _getServiceById(booking.serviceId);
    final isOnVisit = booking.isOnVisitPricing || (svc?.isPriceOnVisit ?? false);
    final showFinal = booking.finalPriceSar != null && booking.finalPriceSar! > 0;
    final minPrice = svc?.basePriceSar ?? 0;
    final minDisplay = minPrice > 0 ? minPrice.toStringAsFixed(0) : (booking.estimatedPriceSar > 0 ? (booking.estimatedPriceSar / booking.quantity).toStringAsFixed(0) : null);
    final priceText = isOnVisit
        ? (showFinal ? '${booking.finalPriceSar!.toStringAsFixed(0)} ريال (بعد المعاينة)' : (minDisplay != null && minDisplay != '0' ? 'يبدأ من $minDisplay ريال - لم يحدد بعد' : 'التسعير عند الزيارة - لم يحدد بعد'))
        : '${booking.totalAmountSar.toStringAsFixed(0)} ريال';
    final priceColor = isOnVisit && !showFinal ? Colors.orange[700] : Colors.green[700];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.bookingId, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(kColorSecondary))),
                _buildStatusBadge(booking.statusCode),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Color(kColorPrimary)),
                const SizedBox(width: 6),
                Text('العميل: ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Text(booking.customerName.isNotEmpty ? booking.customerName : 'عميل', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 18, color: Color(kColorPrimary)),
                const SizedBox(width: 6),
                Text('الجوال: ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                SelectableText(booking.customerPhone, style: GoogleFonts.cairo(color: Colors.grey[800], fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.build_outlined, size: 18, color: Color(kColorPrimary)),
                const SizedBox(width: 6),
                Text('الخدمة المطلوبة: ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Expanded(child: Text(serviceName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(kColorPrimary)))),
                if (isOnVisit) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text('عند الزيارة', style: GoogleFonts.cairo(fontSize: 10, color: Colors.orange[800], fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Color(kColorPrimary)),
                const SizedBox(width: 6),
                Text('الحي: ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Expanded(child: Text(areaName, style: GoogleFonts.cairo(color: Colors.grey[800]))),
              ],
            ),
            if (booking.addressDetail.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.home_outlined, size: 18, color: Color(kColorPrimary)),
                  const SizedBox(width: 6),
                  Text('العنوان التفصيلي: ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(booking.addressDetail, style: GoogleFonts.cairo(color: Colors.grey[800]))),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: Color(kColorPrimary)),
                const SizedBox(width: 6),
                Text('الموعد: ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Text('${booking.preferredDate} (${slotName})', style: GoogleFonts.cairo(color: Colors.grey[900], fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.ac_unit, size: 18, color: Color(kColorPrimary)),
                const SizedBox(width: 6),
                Text('الكمية: ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Text('${booking.quantity} مكيف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Flexible(child: Text(priceText, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: priceColor), textAlign: TextAlign.end)),
              ],
            ),
            if (booking.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                child: Text('ملاحظات العميل: ${booking.notes}', style: GoogleFonts.cairo(fontSize: 13, color: Colors.brown[800])),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showChangeStatusDialog(booking),
                icon: const Icon(Icons.edit, size: 16),
                label: Text('تغيير حالة الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statusCode) {
    Color color;
    String text;
    final st = statusCode.toUpperCase();

    if (st == 'STAT-01' || st.contains('PENDING') || st.contains('انتظار')) {
      color = Colors.orange;
      text = '🟡 قيد الانتظار';
    } else if (st == 'STAT-02' || st.contains('PROGRESS') || st.contains('عمل')) {
      color = Colors.blue;
      text = '🔵 جاري العمل';
    } else if (st == 'STAT-03' || st.contains('COMPLETED') || st.contains('مكتمل')) {
      color = Colors.green;
      text = '🟢 مكتمل';
    } else {
      color = Colors.red;
      text = '🔴 ملغي';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
      child: Text(text, style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  void _showChangeStatusDialog(UserBookingModel booking) {
    final svc = _getServiceById(booking.serviceId);
    final isOnVisit = booking.isOnVisitPricing || (svc?.isPriceOnVisit ?? false);
    final isCompletedAlready = booking.statusCode.toUpperCase() == 'STAT-03';

    // If completing an on_visit booking, we need price input with min check
    if (isOnVisit && !isCompletedAlready) {
      final minPerUnit = svc?.basePriceSar ?? 0;
      final minTotal = minPerUnit > 0 ? minPerUnit * booking.quantity : (booking.estimatedPriceSar > 0 ? booking.estimatedPriceSar : 0);
      final priceCtrl = TextEditingController(text: booking.finalPriceSar?.toStringAsFixed(0) ?? (minTotal > 0 ? minTotal.toStringAsFixed(0) : ''));
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('تغيير حالة الطلب (${booking.bookingId})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(minTotal > 0 ? 'هذه الخدمة بنظام "التسعير عند الزيارة" - الحد الأدنى ${minTotal.toStringAsFixed(0)} ريال. عند الإكمال يجب إدخال السعر النهائي (لا يقل عن الحد الأدنى) ليتم احتسابه في الأرباح.' : 'هذه الخدمة بنظام "التسعير عند الزيارة". عند تغيير الحالة إلى مكتمل يجب إدخال السعر النهائي ليتم احتسابه في الأرباح.', style: GoogleFonts.cairo(fontSize: 12, color: Colors.brown[800]))),
                const SizedBox(height: 12),
                ListTile(
                  title: Text('🟡 قيد الانتظار', style: GoogleFonts.cairo()),
                  onTap: () { Navigator.pop(ctx); _updateBookingStatus(booking.bookingId, 'STAT-01'); },
                ),
                ListTile(
                  title: Text('🔵 جاري العمل', style: GoogleFonts.cairo()),
                  onTap: () { Navigator.pop(ctx); _updateBookingStatus(booking.bookingId, 'STAT-02'); },
                ),
                const Divider(),
                Text('إكمال الطلب مع تحديد السعر:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(kColorPrimary))),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: minTotal > 0 ? 'السعر النهائي (الحد الأدنى $minTotal ريال) *' : 'السعر النهائي بالريال *',
                    hintText: minTotal > 0 ? 'أدخل سعراً >= $minTotal' : null,
                    prefixIcon: const Icon(Icons.attach_money, color: Color(kColorPrimary)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: Text('تأكيد الإكمال بالسعر', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final p = double.tryParse(priceCtrl.text.trim());
                      if (p == null || p <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('أدخل سعراً صحيحاً أكبر من صفر', style: GoogleFonts.cairo()), backgroundColor: Colors.red));
                        return;
                      }
                      if (minTotal > 0 && p < minTotal) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('السعر يجب أن لا يقل عن الحد الأدنى $minTotal ريال', style: GoogleFonts.cairo()), backgroundColor: Colors.red));
                        return;
                      }
                      Navigator.pop(ctx);
                      _updateBookingStatus(booking.bookingId, 'STAT-03', finalPrice: p);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text('🔴 ملغي', style: GoogleFonts.cairo()),
                  onTap: () { Navigator.pop(ctx); _updateBookingStatus(booking.bookingId, 'STAT-04'); },
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تغيير حالة الطلب (${booking.bookingId})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('🟡 قيد الانتظار (STAT-01)', style: GoogleFonts.cairo()),
              onTap: () => _updateBookingStatus(booking.bookingId, 'STAT-01'),
            ),
            ListTile(
              title: Text('🔵 جاري العمل (STAT-02)', style: GoogleFonts.cairo()),
              onTap: () => _updateBookingStatus(booking.bookingId, 'STAT-02'),
            ),
            ListTile(
              title: Text('🟢 مكتمل (STAT-03)', style: GoogleFonts.cairo()),
              onTap: () => _updateBookingStatus(booking.bookingId, 'STAT-03'),
            ),
            ListTile(
              title: Text('🔴 ملغي (STAT-04)', style: GoogleFonts.cairo()),
              onTap: () => _updateBookingStatus(booking.bookingId, 'STAT-04'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus, {double? finalPrice}) async {
    // close dialog if still open
    if (Navigator.canPop(context)) {
      try { Navigator.pop(context); } catch (_) {}
    }
    setState(() => _isLoading = true);
    final success = await ApiService.updateBookingStatusAdmin(bookingId, newStatus, finalPriceSar: finalPrice);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'تم تحديث حالة الطلب بنجاح!' : 'فشل تحديث الحالة - تأكد من إدخال السعر للطلبات عند الزيارة'), backgroundColor: success ? Colors.green : Colors.red),
      );
      _loadAdminData();
    }
  }

  // ─── Tab 3: Services Management ────────────────────────────────────
  Widget _buildServicesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _showAddOrEditServiceDialog(),
              icon: const Icon(Icons.add_circle_outline),
              label: Text('إضافة خدمة جديدة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(service.nameAr, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.isPriceOnVisit ? (service.basePriceSar > 0 ? 'يبدأ من ${service.basePriceSar.toStringAsFixed(0)} ريال (قابل للزيادة) / ${service.priceUnit} (ضمان ${service.warrantyDays} يوم)' : 'التسعير عند الزيارة / ${service.priceUnit} (ضمان ${service.warrantyDays} يوم)') : '${service.basePriceSar.toStringAsFixed(0)} ريال / ${service.priceUnit} (ضمان ${service.warrantyDays} يوم)', style: GoogleFonts.cairo(fontSize: 12)),
                      if (service.isPriceOnVisit) Padding(padding: const EdgeInsets.only(top: 2), child: Text(service.basePriceSar > 0 ? '⚠️ الحد الأدنى ${service.basePriceSar.toStringAsFixed(0)} ريال - يحدد السعر النهائي عند الإكمال' : '⚠️ يحدد السعر عند الإكمال', style: GoogleFonts.cairo(fontSize: 10, color: Colors.orange[700], fontWeight: FontWeight.bold))),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddOrEditServiceDialog(service: service)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDeleteService(service)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddOrEditServiceDialog({ServiceModel? service}) {
    final nameCtrl = TextEditingController(text: service?.nameAr ?? '');
    final priceCtrl = TextEditingController(text: service != null ? service.basePriceSar.toStringAsFixed(0) : '120');
    final descCtrl = TextEditingController(text: service?.shortDescriptionAr ?? '');
    final warrantyCtrl = TextEditingController(text: service != null ? service.warrantyDays.toString() : '30');
    bool isOnVisit = service?.isPriceOnVisit ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(service == null ? 'إضافة خدمة جديدة' : 'تعديل الخدمة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الخدمة بالعربية')),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('التسعير عند الزيارة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(isOnVisit ? 'السعر يحدد بعد المعاينة عند الإكمال' : 'سعر ثابت يظهر للعميل', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[600])),
                  value: isOnVisit,
                  activeColor: const Color(kColorPrimary),
                  onChanged: (v) => setS(() => isOnVisit = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isOnVisit ? 'الحد الأدنى للسعر (ريال) - يبدأ من' : 'السعر بالريال السعودي',
                    hintText: isOnVisit ? 'مثال: 100 (سيظهر يبدأ من 100)' : null,
                  ),
                ),
                if (isOnVisit) ...[
                  const SizedBox(height: 6),
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.info_outline, size: 16, color: Colors.orange), const SizedBox(width: 6), Expanded(child: Text('سيظهر للعميل "يبدأ من X ريال" ويمكن أن يزيد بعد المعاينة عند الإكمال', style: GoogleFonts.cairo(fontSize: 11, color: Colors.brown[700])))])),
                ],
                const SizedBox(height: 8),
                TextField(controller: warrantyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مدة الضمان بالأيام (مثلاً 30)')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'وصف الخدمة')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: GoogleFonts.cairo())),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('أدخل اسم الخدمة', style: GoogleFonts.cairo()), backgroundColor: Colors.red));
                  return;
                }
                final parsedPrice = double.tryParse(priceCtrl.text.trim());
                if (parsedPrice == null || parsedPrice < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('أدخل سعراً صحيحاً', style: GoogleFonts.cairo()), backgroundColor: Colors.red));
                  return;
                }
                if (!isOnVisit && parsedPrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('أدخل سعراً أكبر من صفر', style: GoogleFonts.cairo()), backgroundColor: Colors.red));
                  return;
                }
                Navigator.pop(ctx);
                final data = {
                  if (service != null) 'service_id': service.serviceId,
                  'name_ar': nameCtrl.text.trim(),
                  'base_price_sar': parsedPrice,
                  'short_description_ar': descCtrl.text.trim(),
                  'warranty_days': int.tryParse(warrantyCtrl.text) ?? 30,
                  'pricing_type': isOnVisit ? 'on_visit' : 'fixed',
                  'is_price_on_visit': isOnVisit,
                  'price_unit': isOnVisit ? 'يبدأ من' : 'للوحدة',
                };
                setState(() => _isLoading = true);
                bool success = false;
                if (service == null) {
                  success = await ApiService.createServiceAdmin(data);
                } else {
                  success = await ApiService.updateServiceAdmin(data);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'تمت العملية بنجاح!' : 'فشل العملية', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)), backgroundColor: success ? Colors.green : Colors.red),
                  );
                  _loadAdminData();
                }
              },
              child: Text('حفظ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteService(ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('هل أنت تأكد من حذف خدمة "${service.nameAr}"؟', style: GoogleFonts.cairo()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: GoogleFonts.cairo())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await ApiService.deleteServiceAdmin(service.serviceId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حذف الخدمة بنجاح', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)), backgroundColor: Colors.green),
                );
                _loadAdminData();
              }
            },
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Tab 4: Analytics ────────────────────────────────────────────
  Widget _buildAnalyticsTab() {
    if (_analytics == null) {
      return Center(child: _isLoadingAnalytics ? const CircularProgressIndicator(color: Color(kColorPrimary)) : Text('لا توجد بيانات تحليل بعد', style: GoogleFonts.cairo(color: Colors.grey)));
    }
    final monthly = (_analytics!['monthly'] as List?) ?? [];
    final selected = _analytics!['selected'] as Map<String, dynamic>? ?? {};
    final yearData = _analytics!['year'] as Map<String, dynamic>? ?? {};
    final allYears = (_analytics!['all_years'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year/Month selectors
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _analyticsYear,
                  decoration: InputDecoration(labelText: 'السنة', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: (allYears.isEmpty ? [DateTime.now().year, DateTime.now().year - 1, DateTime.now().year - 2] : allYears.map<int>((e) => (e['year'] as num).toInt()).toList()).map((y) => DropdownMenuItem(value: y, child: Text('$y', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _analyticsYear = v); _loadAnalytics(); },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _analyticsMonth,
                  decoration: InputDecoration(labelText: 'الشهر', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(value: m, child: Text(['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'][m-1], style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _analyticsMonth = v); _loadAnalytics(); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingAnalytics) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Color(kColorPrimary))))
          else ...[
            // Selected month summary
            Text('تحليل ${selected['key'] ?? '$_analyticsYear-$_analyticsMonth'}', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(kColorSecondary))),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _buildAnalyticsCard('طلبات الشهر', '${selected['count'] ?? 0}', 'عدد', _growthBadge(selected['growth_count_percent'])),
                _buildAnalyticsCard('إيراد الشهر (مكتمل)', '${(selected['revenue'] ?? 0).toStringAsFixed(0)} ريال', 'ريال', _growthBadge(selected['growth_revenue_percent'])),
                _buildAnalyticsCard('مقارنة سنوية (نفس الشهر)', 'العدد: ${_growthBadge(selected['yoy_count_percent'])}', 'سنة', Text('${selected['yoy_revenue_percent'] ?? 0}% إيراد', style: GoogleFonts.cairo(fontSize: 10, color: _growthColor(selected['yoy_revenue_percent'])))),
                _buildAnalyticsCard('إجمالي السنة $yearData', '${yearData['count'] ?? 0} طلب', '${yearData['revenue']?.toStringAsFixed(0) ?? 0} ريال', _growthBadge(yearData['growth_revenue_percent'])),
              ],
            ),
            const SizedBox(height: 8),
            Text('نسبة النمو = (الحالي - السابق) / السابق ×100 مقارنة بالشهر السابق', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 20),
            // Monthly table
            Text('تفاصيل الأشهر ($yearData)', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(kColorSecondary))),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.15))),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(kColorBg)),
                  columns: [
                    DataColumn(label: Text('الشهر', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('الطلبات', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('الإيراد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('نمو العدد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12))),
                    DataColumn(label: Text('نمو الإيراد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                  rows: monthly.map<DataRow>((m) {
                    final isSelected = m['month'] == _analyticsMonth;
                    return DataRow(
                      color: isSelected ? WidgetStateProperty.all(const Color(kColorPrimary).withOpacity(0.07)) : null,
                      cells: [
                        DataCell(Text(m['month_name_ar'], style: GoogleFonts.cairo(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, fontSize: 12, color: isSelected ? const Color(kColorPrimary) : Colors.black87))),
                        DataCell(Text('${m['count']}', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold))),
                        DataCell(Text('${(m['revenue'] as num).toStringAsFixed(0)}', style: GoogleFonts.cairo(fontSize: 12))),
                        DataCell(_growthBadge(m['growth_count_percent'])),
                        DataCell(_growthBadge(m['growth_revenue_percent'])),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Simple bar visualization using containers
            Text('رسم مبسط للإيراد الشهري', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(kColorSecondary))),
            const SizedBox(height: 12),
            ...monthly.map((m) {
              final maxRev = monthly.map((e) => (e['revenue'] as num).toDouble()).fold<double>(0, (a, b) => b > a ? b : a);
              final rev = (m['revenue'] as num).toDouble();
              final pct = maxRev == 0 ? 0.0 : (rev / maxRev);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text(m['month_name_ar'], style: GoogleFonts.cairo(fontSize: 11))),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(height: 18, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8))),
                          FractionallySizedBox(
                            widthFactor: pct.clamp(0, 1),
                            child: Container(height: 18, decoration: BoxDecoration(color: m['month'] == _analyticsMonth ? const Color(kColorPrimary) : const Color(kColorAccent), borderRadius: BorderRadius.circular(8))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${rev.toStringAsFixed(0)}', style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String unit, Widget badge) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.15)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(kColorSecondary))),
          Text(unit, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[500])),
          const Spacer(),
          badge,
        ],
      ),
    );
  }

  Widget _growthBadge(dynamic percent) {
    final p = (percent is num ? percent.toDouble() : 0.0);
    final isPositive = p >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text('${p > 0 ? '+' : ''}${p.toStringAsFixed(1)}%', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Color _growthColor(dynamic percent) {
    final p = (percent is num ? percent.toDouble() : 0.0);
    return p >= 0 ? Colors.green : Colors.red;
  }
}
