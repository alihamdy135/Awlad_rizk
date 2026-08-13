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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    final stats = await ApiService.getAdminStats();
    final bookings = await ApiService.getAllBookingsAdmin();
    final services = await ApiService.getServices();

    if (mounted) {
      setState(() {
        _stats = stats;
        _allBookings = bookings;
        _services = services;
        _isLoading = false;
      });
    }
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
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.analytics_outlined), text: 'الإحصائيات'),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'طلبات العملاء'),
              Tab(icon: Icon(Icons.build_circle_outlined), text: 'إدارة الخدمات'),
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
          // Header Card
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

          // Grid of Stat Cards
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
        // Filter Chips
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

        // List
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

  Widget _buildAdminBookingCard(UserBookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            Text('العميل: ${booking.customerName}', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            Text('رقم الجوال: ${booking.customerPhone}', style: GoogleFonts.cairo(color: Colors.grey[700], fontSize: 13)),
            Text('العنوان: ${booking.addressDetail}', style: GoogleFonts.cairo(color: Colors.grey[700], fontSize: 13)),
            Text('الخدمات: ${booking.serviceNames.join(", ")}', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: const Color(kColorPrimary))),
            Text('المبلغ: ${booking.totalAmountSar} ريال', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
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

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    final success = await ApiService.updateBookingStatusAdmin(bookingId, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'تم تحديث حالة الطلب بنجاح!' : 'فشل تحديث الحالة'), backgroundColor: success ? Colors.green : Colors.red),
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
                  subtitle: Text('${service.basePriceSar} ريال / ${service.priceUnit} (ضمان ${service.warrantyDays} يوم)', style: GoogleFonts.cairo(fontSize: 12)),
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
    final priceCtrl = TextEditingController(text: service != null ? service.basePriceSar.toString() : '120');
    final descCtrl = TextEditingController(text: service?.shortDescriptionAr ?? '');
    final warrantyCtrl = TextEditingController(text: service != null ? service.warrantyDays.toString() : '30');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(service == null ? 'إضافة خدمة جديدة' : 'تعديل الخدمة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الخدمة بالعربية')),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر بالريال السعودي')),
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
              Navigator.pop(ctx);
              final data = {
                if (service != null) 'service_id': service.serviceId,
                'name_ar': nameCtrl.text.trim(),
                'base_price_sar': double.tryParse(priceCtrl.text) ?? 100,
                'short_description_ar': descCtrl.text.trim(),
                'warranty_days': int.tryParse(warrantyCtrl.text) ?? 30,
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
                  SnackBar(content: Text(success ? 'تمت العملية بنجاح!' : 'فشلت العملية'), backgroundColor: success ? Colors.green : Colors.red),
                );
                _loadAdminData();
              }
            },
            child: Text('حفظ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
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
              final success = await ApiService.deleteServiceAdmin(service.serviceId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'تم حذف الخدمة' : 'فشل الحذف'), backgroundColor: success ? Colors.green : Colors.red),
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
}
