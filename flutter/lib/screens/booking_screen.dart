import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../models.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../api_service.dart';

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
  
  ServiceModel? _selectedService;
  List<ServiceModel> _availableServices = [];
  bool _isLoadingServices = false;
  bool _isSubmitting = false;
  List<String> _bookedSlots = [];
  bool _isLoadingSlots = false;




  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argsService = ModalRoute.of(context)?.settings.arguments as ServiceModel?;
    if (argsService != null && _selectedService == null) {
      _selectedService = argsService;
    }
  }

  Future<void> _loadServices() async {
    setState(() => _isLoadingServices = true);
    try {
      final services = await ApiService.getServices();
      setState(() {
        _availableServices = services;
        _isLoadingServices = false;
        if (_selectedService == null && _availableServices.isNotEmpty) {
          _selectedService = _availableServices.first;
        }
      });
    } catch (_) {
      setState(() => _isLoadingServices = false);
    }
  }

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
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _selectedDate = formattedDate;
        _selectedSlotId = null;
        _isLoadingSlots = true;
      });
      final booked = await ApiService.getBookedSlotsForDate(formattedDate);
      if (mounted) {
        setState(() {
          _bookedSlots = booked;
          _isLoadingSlots = false;
        });
      }
    }
  }

  Future<void> _submitBooking(ServiceModel? routeService) async {
    final targetService = routeService ?? _selectedService;
    if (targetService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء اختيار الخدمة المطلوب حجزها', style: GoogleFonts.cairo())),
      );
      return;
    }

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

      String bookingId = 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      bool apiSuccess = false;
      String? apiError;
      try {
        final response = await http.post(
          Uri.parse('$kBaseUrl/api/bookings'),
          headers: headers,
          body: jsonEncode({
            'customer_name': _customerName,
            'customer_phone': _customerPhone,
            'service_id': targetService.serviceId,
            'area_id': _selectedAreaId,
            'address_detail': _addressDetail,
            'preferred_date': _selectedDate,
            'slot_id': _selectedSlotId,
            'quantity': _quantity,
            'notes': _notes,
            'estimated_price_sar': targetService.basePriceSar * _quantity,
          }),
        ).timeout(const Duration(seconds: 12));

        final data = jsonDecode(response.body);
        if (response.statusCode == 201 && data['success'] == true) {
          if (data['booking_id'] != null && data['booking_id'].toString().isNotEmpty) {
            bookingId = data['booking_id'].toString();
          }
          apiSuccess = true;
        } else if (response.statusCode == 409) {
          apiError = data['error']?.toString() ?? 'هذا الموعد محجوز بالفعل';
        } else if (response.statusCode >= 400) {
          apiError = data['error']?.toString() ?? 'فشل إنشاء الحجز';
        } else {
          // fallback: if no booking_id, still treat as success if local fallback needed
          if (data['booking_id'] != null) {
            bookingId = data['booking_id'].toString();
            apiSuccess = true;
          } else {
            apiError = data['error']?.toString();
          }
        }
      } catch (err) {
        debugPrint('Booking API warning, fallback used: $err');
        apiError = err.toString();
      }

      if (apiError != null && !apiSuccess) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(apiError, style: GoogleFonts.cairo()), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final newBooking = UserBookingModel(
        id: bookingId,
        bookingId: bookingId,
        customerName: _customerName,
        customerPhone: _customerPhone,
        serviceId: targetService.serviceId,
        areaId: _selectedAreaId ?? '',
        addressDetail: _addressDetail,
        preferredDate: _selectedDate ?? '',
        slotId: _selectedSlotId ?? '',
        quantity: _quantity,
        notes: _notes,
        statusId: 'STAT-01',
        estimatedPriceSar: targetService.basePriceSar * _quantity,
        pricingType: targetService.isPriceOnVisit ? 'on_visit' : 'fixed',
        isPriceOnVisit: targetService.isPriceOnVisit,
        createdAt: DateTime.now().toIso8601String(),
      );
      ApiService.addLocalBooking(newBooking);

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.check_circle, color: Color(0xFF25D366), size: 64),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تم تأكيد طلبك بنجاح!', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('رقم الحجز: $bookingId', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(kColorPrimary))),
              const SizedBox(height: 8),
              Text('سيتواصل معك فريق نسيم قريباً لتأكيد الموعد.', style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight)), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('العودة للرئيسية'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Submit booking error: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeService = ModalRoute.of(context)?.settings.arguments as ServiceModel?;
    final activeService = routeService ?? _selectedService;

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
                // Service Selector Section
                Text('الخدمة المطلوبة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
                const SizedBox(height: 12),

                if (routeService != null)
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
                        const Icon(Icons.build_circle, color: Color(kColorPrimary), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الخدمة المختارة:', style: GoogleFonts.cairo(fontSize: 12, color: const Color(kColorTextLight))),
                              Text(routeService.isPriceOnVisit ? (routeService.basePriceSar > 0 ? '${routeService.nameAr} (يبدأ من ${routeService.basePriceSar.toStringAsFixed(0)} ريال)' : '${routeService.nameAr} (التسعير عند الزيارة)') : '${routeService.nameAr} (${routeService.basePriceSar.toStringAsFixed(0)} ريال)', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(kColorPrimary))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: _isLoadingServices
                        ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                        : DropdownButtonFormField<ServiceModel>(
                            value: _selectedService,
                            decoration: InputDecoration(
                              labelText: 'اختر الخدمة المطلوبة *',
                              prefixIcon: const Icon(Icons.build_circle_outlined, color: Color(kColorPrimary)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _availableServices.map((srv) {
                              return DropdownMenuItem<ServiceModel>(
                                value: srv,
                                child: Text(srv.isPriceOnVisit ? (srv.basePriceSar > 0 ? '${srv.nameAr} - (يبدأ من ${srv.basePriceSar.toStringAsFixed(0)} ريال)' : '${srv.nameAr} - (عند الزيارة)') : '${srv.nameAr} - (${srv.basePriceSar.toStringAsFixed(0)} ريال)', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                            onChanged: (srv) {
                              setState(() {
                                _selectedService = srv;
                              });
                            },
                            validator: (v) => _selectedService == null ? 'الرجاء اختيار الخدمة' : null,
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
                  value: _selectedAreaId,
                  decoration: InputDecoration(
                    labelText: 'اختر الحي بجدة',
                    prefixIcon: const Icon(Icons.location_city_outlined, color: Color(kColorPrimary)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  isExpanded: true,
                  items: kServiceAreas.map((area) {
                    final bool isHeader = area['isHeader'] == true;
                    return DropdownMenuItem<String>(
                      value: area['id'] as String,
                      enabled: !isHeader,
                      child: Text(
                        area['name'] as String,
                        style: GoogleFonts.cairo(
                          fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                          color: isHeader ? const Color(kColorPrimary) : Colors.black87,
                          fontSize: isHeader ? 13 : 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null && !v.startsWith('HEADER-')) {
                      setState(() => _selectedAreaId = v);
                    }
                  },
                  validator: (v) => (v == null || v.startsWith('HEADER-')) ? 'الرجاء اختيار الحي' : null,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: 'العنوان بالتفصيل',
                  icon: Icons.home_outlined,
                  validator: (v) => v!.isEmpty ? 'الرجاء إدخال العنوان' : null,
                  onSaved: (v) => _addressDetail = v!,
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'تاريخ الزيارة',
                      prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(kColorPrimary)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    child: Text(
                      _selectedDate ?? 'اختر التاريخ',
                      style: GoogleFonts.cairo(color: _selectedDate == null ? Colors.grey[600] : Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _isLoadingSlots 
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                  value: _selectedSlotId,
                  decoration: InputDecoration(
                    labelText: 'الوقت المفضّل',
                    prefixIcon: const Icon(Icons.access_time_outlined, color: Color(kColorPrimary)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: kTimeSlots.map((slot) {
                    final isBooked = _bookedSlots.contains(slot['id']);
                    return DropdownMenuItem(
                      value: slot['id'],
                      enabled: !isBooked,
                      child: Text(isBooked ? '${slot['name']} (محجوز)' : slot['name']!, style: GoogleFonts.cairo(color: isBooked ? Colors.red : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedSlotId = v),
                  validator: (v) => v == null ? 'الرجاء اختيار الوقت' : null,
                ),

                const SizedBox(height: 32),
                Text('تفاصيل إضافية', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(kColorSecondary))),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('عدد المكيفات (الكمية):', style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(kColorPrimary),
                        ),
                        Text('$_quantity', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(kColorPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  label: 'ملاحظات إضافية (اختياري)',
                  icon: Icons.note_outlined,
                  maxLines: 3,
                  onSaved: (v) => _notes = v ?? '',
                ),
                const SizedBox(height: 32),

                // Total estimation card
                if (activeService != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade700.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(activeService.isPriceOnVisit ? 'الحد الأدنى:' : 'السعر التقديري الفوري:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        Text(activeService.isPriceOnVisit ? (activeService.basePriceSar > 0 ? 'يبدأ من ${(activeService.basePriceSar * _quantity).toStringAsFixed(0)} ريال' : 'عند الزيارة (يحدد بعد المعاينة)') : '${(activeService.basePriceSar * _quantity).toStringAsFixed(0)} ريال', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(kColorPrimary))),
                      ],
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitBooking(routeService),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: const Color(kColorPrimary),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'تأكيد الطلب',
                            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(kColorPrimary)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
    );
  }
}
