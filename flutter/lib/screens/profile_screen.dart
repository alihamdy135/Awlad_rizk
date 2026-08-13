import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../models/user_profile.dart';
import '../api_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;

  UserProfileModel? _userProfile;
  List<UserBookingModel> _bookings = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final user = AuthService.currentUser;
    if (user != null) {
      final profile = await ApiService.getUserProfile();
      final bookings = await ApiService.getUserBookings();

      if (profile != null) {
        _userProfile = profile;
        _nameController.text = profile.fullName.isNotEmpty ? profile.fullName : (user.displayName ?? '');
        _phoneController.text = profile.phone;
        _addressController.text = profile.address;
      } else {
        _nameController.text = user.displayName ?? '';
      }

      _bookings = bookings;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final user = AuthService.currentUser;
    final updatedProfile = UserProfileModel(
      userId: user?.uid ?? '',
      fullName: _nameController.text.trim(),
      email: user?.email ?? '',
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      photoUrl: user?.photoURL ?? '',
    );

    final success = await ApiService.updateUserProfile(updatedProfile);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'تم حفظ التغييرات بنجاح!' : 'تعذر حفظ البيانات، حاول لاحقاً',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showRatingDialog(UserBookingModel booking) {
    int rating = 5;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('تقييم الخدمة (${booking.bookingId})', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('كيف كانت تجربتك مع أولاد رزق؟', style: GoogleFonts.cairo(fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(kColorWarning),
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() => rating = index + 1);
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  labelText: 'اكتب رأيك بالخدمة (اختياري)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await ApiService.rateBooking(booking.bookingId, rating, reviewController.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'شكراً لتقييمك! تم حفظ التقييم بنجاح' : 'حدث خطأ أثناء التقييم'),
                    ),
                  );
                  _loadUserData();
                }
              },
              child: Text('إرسال التقييم', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statusId) {
    String label = 'قيد الانتظار';
    Color color = const Color(kColorWarning);
    IconData icon = Icons.hourglass_top;

    switch (statusId) {
      case 'STAT-02':
        label = 'جاري العمل';
        color = Colors.blue;
        icon = Icons.build;
        break;
      case 'STAT-03':
        label = 'مكتمل';
        color = const Color(kColorSuccess);
        icon = Icons.check_circle;
        break;
      case 'STAT-04':
        label = 'ملغي';
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.cairo(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: (Firebase.apps.isNotEmpty) ? FirebaseAuth.instance.authStateChanges() : const Stream.empty(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? AuthService.currentUser;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(kColorBg),
            appBar: AppBar(
              title: Text('حسابي وطلباتي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color(kColorPrimary),
                labelColor: const Color(kColorPrimary),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.person), text: 'البيانات الشخصية'),
                  Tab(icon: Icon(Icons.receipt_long), text: 'طلباتي ومتابعة الحجز'),
                ],
              ),
            ),
            body: user == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('يرجى تسجيل الدخول أولاً للوصول لبيانات حسابك وطلباتك', style: GoogleFonts.cairo(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await AuthService.signInWithGoogle();
                        _loadUserData();
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('تسجيل الدخول بجوجل'),
                    ),
                  ],
                ),
              )
            : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Profile & Contact Info
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                                child: user.photoURL == null ? const Icon(Icons.person, size: 45) : null,
                              ),
                              const SizedBox(height: 12),
                              Text(user.displayName ?? 'مستخدم نسيم (Naseem)', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(user.email ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              if (ApiService.isAdmin()) ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(kColorPrimary),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                                  child: Text('لوحة الإدارة والتحكم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                ),
                              ],
                              const SizedBox(height: 24),

                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'الاسم الكامل',
                                  prefixIcon: const Icon(Icons.person_outline, color: Color(kColorPrimary)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (v) => v!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'رقم الجوال لتأكيد الحجوزات',
                                  prefixIcon: const Icon(Icons.phone_outlined, color: Color(kColorPrimary)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _addressController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'العنوان المفضل في جدة',
                                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(kColorPrimary)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  icon: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
                                  label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ البيانات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tab 2: My Orders & Status Tracking
                      _bookings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text('لا توجد حجوزات حالية لك حتى الآن', style: GoogleFonts.cairo(fontSize: 16)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _bookings.length,
                              itemBuilder: (context, index) {
                                final booking = _bookings[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
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
                                            Text(booking.bookingId, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(kColorPrimary))),
                                            _buildStatusBadge(booking.statusId),
                                          ],
                                        ),
                                        const Divider(height: 20),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text('التاريخ: ${booking.preferredDate}', style: GoogleFonts.cairo(fontSize: 13)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Expanded(child: Text('العنوان: ${booking.addressDetail}', style: GoogleFonts.cairo(fontSize: 13))),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Text('التكلفة المقدرة: ${booking.estimatedPriceSar} ريال', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        if (booking.rating != null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, color: Color(kColorWarning), size: 16),
                                              const SizedBox(width: 4),
                                              Text('تقييمك: ${booking.rating} / 5', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ] else ...[
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: OutlinedButton.icon(
                                              onPressed: () => _showRatingDialog(booking),
                                              icon: const Icon(Icons.rate_review_outlined, size: 16),
                                              label: Text('تقييم الطلب', style: GoogleFonts.cairo(fontSize: 12)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
