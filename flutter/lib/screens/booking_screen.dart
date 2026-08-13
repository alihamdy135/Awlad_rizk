import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../models.dart';
import '../services/auth_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _customerName = '';
  String _customerPhone = '';
  String _addressDetail = '';
  String _notes = '';
  int _quantity = 1;
  
  String? _selectedAreaId;
  String? _selectedDate;
  String? _selectedSlotId;

  bool _isSubmitting = false;

  final List<Map<String, String>> _areas = [
    {'id': 'AREA-01', 'name': 'حي الروضة'},
    {'id': 'AREA-02', 'name': 'حي الصفا'},
    {'id': 'AREA-03', 'name': 'حي النزهة'},
    {'id': 'AREA-04', 'name': 'حي الخالدية'},
    {'id': 'AREA-05', 'name': 'أحياء أخرى'},
  ];

  final List<Map<String, String>> _timeSlots = [
    {'id': 'SLOT-1', 'name': 'صباحاً (9ص - 12م)'},
    {'id': 'SLOT-2', 'name': 'ظهراً (12م - 4م)'},
    {'id': 'SLOT-3', 'name': 'عصراً (4م - 8م)'},
    {'id': 'SLOT-4', 'name': 'مساءً (8م - 11م)'},
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(kColorPrimary),
              onPrimary: Colors.white,
              onSurface: Color(kColorSecondary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitBooking(ServiceModel? service) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAreaId == null || _selectedDate == null || _selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء تعبئة جميع الحقول المطلوبة (الحي، التاريخ، الوقت)', style: GoogleFonts.cairo())),
      );
      return;
    }
    
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      String? idToken = await AuthService.getIdToken();
      Map<String, String> headers = {'Content-Type': 'application/json'};
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }

      final response = await http.post(
        Uri.parse('$kBaseUrl/api/bookings'),
        headers: headers,
        body: jsonEncode({
          'customer_name': _customerName,
          'customer_phone': _customerPhone,
          'service_id': service?.serviceId ?? 'SRV-000',
          'area_id': _selectedAreaId,
          'address_detail': _addressDetail,
          'preferred_date': _selectedDate,
          'slot_id': _selectedSlotId,
          'quantity': _quantity,
          'notes': _notes,
          'estimated_price_sar': (service?.basePriceSar ?? 0) * _quantity,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201 || data['success'] == true) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Icon(Icons.check_circle, color: const Color(0xFF25D366), size: 64),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تم تأكيد طلبك بنجاح!', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('سيتواصل معك فريقنا قريباً لتأكيد الموعد.', style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight)), textAlign: TextAlign.center),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).popUntil((route) => route.isFirst); // Go to home
                  },
                  child: const Text('العودة للرئيسية'),
                ),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب، الرجاء المحاولة لاحقاً', style: GoogleFonts.cairo())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)?.settings.arguments as ServiceModel?;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          title: Text('إتمام الحجز', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(kColorPrimary).withOpacity(0.05),
                      border: Border.all(color: const Color(kColorPrimary).withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(kColorPrimary)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الخدمة المختارة:', style: GoogleFonts.cairo(fontSize: 12, color: const Color(kColorTextLight))),
                              Text(service.nameAr, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(kColorPrimary))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                Text('البيانات الشخصية', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'الاسم الكريم',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                  onSaved: (v) => _customerName = v!,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'رقم الجوال',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 9 ? 'الرجاء إدخال رقم جوال صحيح' : null,
                  onSaved: (v) => _customerPhone = v!,
                ),
                
                const SizedBox(height: 32),
                Text('تفاصيل الموقع والموعد', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'الحي',
                    prefixIcon: const Icon(Icons.location_city_outlined, color: Color(kColorPrimary)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(kColorBorder))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(kColorBorder))),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedAreaId,
                  items: _areas.map((a) => DropdownMenuItem(value: a['id'], child: Text(a['name']!, style: GoogleFonts.cairo()))).toList(),
                  onChanged: (v) => setState(() => _selectedAreaId = v),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'العنوان بالتفصيل',
                  icon: Icons.home_outlined,
                  validator: (v) => v!.isEmpty ? 'الرجاء إدخال العنوان' : null,
                  onSaved: (v) => _addressDetail = v!,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'تاريخ الزيارة',
                            prefixIcon: const Icon(Icons.calendar_month_outlined, color: Color(kColorPrimary)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          child: Text(_selectedDate ?? 'اختر التاريخ', style: GoogleFonts.cairo(color: _selectedDate == null ? Colors.grey : Colors.black)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'الوقت المفضل',
                    prefixIcon: const Icon(Icons.access_time_outlined, color: Color(kColorPrimary)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(kColorBorder))),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedSlotId,
                  items: _timeSlots.map((a) => DropdownMenuItem(value: a['id'], child: Text(a['name']!, style: GoogleFonts.cairo()))).toList(),
                  onChanged: (v) => setState(() => _selectedSlotId = v),
                ),

                const SizedBox(height: 32),
                Text('تفاصيل إضافية', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('عدد المكيفات (الكمية):', style: GoogleFonts.cairo(fontSize: 16)),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(color: const Color(kColorPrimary).withOpacity(0.1), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.remove, color: Color(kColorPrimary)),
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('$_quantity', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    Container(
                      decoration: BoxDecoration(color: const Color(kColorPrimary).withOpacity(0.1), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Color(kColorPrimary)),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'ملاحظات إضافية (اختياري)',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                  onSaved: (v) => _notes = v ?? '',
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitBooking(service),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('تأكيد الطلب', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      style: GoogleFonts.cairo(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(kColorPrimary)) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(kColorBorder))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(kColorBorder))),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
