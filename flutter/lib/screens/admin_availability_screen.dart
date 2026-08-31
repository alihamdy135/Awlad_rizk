import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../constants.dart';
import '../api_service.dart';

class AdminAvailabilityScreen extends StatefulWidget {
  const AdminAvailabilityScreen({super.key});

  @override
  State<AdminAvailabilityScreen> createState() => _AdminAvailabilityScreenState();
}

class _AdminAvailabilityScreenState extends State<AdminAvailabilityScreen> {
  DateTime _selectedDate = DateTime.now();
  List<String> _adminBlockedSlots = [];
  List<String> _customerBookedSlots = [];
  bool _isLoading = false;
  bool _isSaving = false;
  
  late List<DateTime> _upcomingDays;

  List<String> get _allBlockedSlots => [..._adminBlockedSlots, ..._customerBookedSlots].toSet().toList();

  @override
  void initState() {
    super.initState();
    _upcomingDays = List.generate(30, (index) => DateTime.now().add(Duration(days: index)));
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final detail = await ApiService.getAdminAvailabilityDetail(dateStr);
    if (mounted) {
      setState(() {
        _adminBlockedSlots = detail['admin'] ?? [];
        _customerBookedSlots = detail['customer'] ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    // Only save admin slots, customer slots are auto from bookings
    final success = await ApiService.setAdminAvailability(dateStr, _adminBlockedSlots);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'تم حفظ التعديلات بنجاح' : 'حدث خطأ أثناء الحفظ',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) _loadAvailability();
    }
  }

  void _toggleSlot(String slotId) {
    // If slot is booked by customer, cannot toggle (show message)
    if (_customerBookedSlots.contains(slotId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('هذا الوقت محجوز من قبل عميل (${slotId}) ولا يمكن إلغاؤه إلا بإلغاء الحجز', style: GoogleFonts.cairo(fontSize: 12)),
          backgroundColor: Colors.orange[700],
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      if (_adminBlockedSlots.contains(slotId)) {
        _adminBlockedSlots.remove(slotId);
      } else {
        _adminBlockedSlots.add(slotId);
      }
    });
  }

  Future<void> _pickExactDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
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
        _selectedDate = picked;
      });
      _loadAvailability();
    }
  }

String _arabicMonthName(int month) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return months[(month - 1) % 12];
}

String _arabicDayName(int weekday) {
  const days = {
    1: 'الإثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };
  return days[weekday] ?? '';
}

  @override
  Widget build(BuildContext context) {
    final y = _selectedDate.year;
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final d = _selectedDate.day.toString().padLeft(2, '0');
    final dayName = _arabicDayName(_selectedDate.weekday);
    final dateDisplay = '$y-$m-$d ($dayName)';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          title: Text('إدارة الأوقات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          centerTitle: true,
          backgroundColor: const Color(kColorBg),
        ),
        body: Column(
          children: [
            // Exact Date Picker Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(kColorPrimary), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'التاريخ: $dateDisplay',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(kColorSecondary)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickExactDate,
                    icon: const Icon(Icons.edit_calendar, size: 16, color: Color(kColorPrimary)),
                    label: Text('اختيار يوم محدد', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(kColorPrimary))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(kColorPrimary)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Horizontal Date Picker
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _upcomingDays.length,
                itemBuilder: (context, index) {
                  final date = _upcomingDays[index];
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      _loadAvailability();
                    },
                    child: Container(
                      width: 75,
                      margin: EdgeInsets.only(
                        right: index == 0 ? 16 : 8,
                        left: index == _upcomingDays.length - 1 ? 16 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(kColorAccent) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? const Color(kColorAccent) : const Color(kColorBorder),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _arabicMonthName(date.month),
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: isSelected ? Colors.white : const Color(kColorTextLight),
                            ),
                          ),
                          Text(
                            date.day.toString(),
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(kColorSecondary),
                            ),
                          ),
                          Text(
                            _arabicDayName(date.weekday),
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: isSelected ? Colors.white : const Color(kColorTextLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.green.withOpacity(0.8), borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 6),
                Text('متاح', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 16),
                Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 6),
                Text('محجوب (أدمن)', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 16),
                Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.9), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.deepOrange))),
                const SizedBox(width: 6),
                Text('محجوز (عميل)', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            
            const SizedBox(height: 16),

            // Slots Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: kTimeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = kTimeSlots[index];
                        final isCustomerBooked = _customerBookedSlots.contains(slot['id']);
                        final isAdminBlocked = _adminBlockedSlots.contains(slot['id']);
                        final isBlocked = isCustomerBooked || isAdminBlocked;
                        Color bg;
                        String label = slot['name']!;
                        if (isCustomerBooked) {
                          bg = Colors.orange.withOpacity(0.95);
                          label = '${slot['name']} (عميل)';
                        } else if (isAdminBlocked) {
                          bg = Colors.red.withOpacity(0.85);
                        } else {
                          bg = Colors.green.withOpacity(0.85);
                        }

                        return InkWell(
                          onTap: () => _toggleSlot(slot['id']!),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(8),
                              border: isCustomerBooked ? Border.all(color: Colors.deepOrange, width: 1.5) : null,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  label,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (isCustomerBooked)
                                  Text('محجوز تلقائيا', style: GoogleFonts.cairo(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(kColorAccent),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('حفظ', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
