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
  List<String> _blockedSlots = [];
  bool _isLoading = false;
  bool _isSaving = false;
  
  late List<DateTime> _upcomingDays;

  @override
  void initState() {
    super.initState();
    _upcomingDays = List.generate(30, (index) => DateTime.now().add(Duration(days: index)));
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final blocked = await ApiService.getAdminAvailability(dateStr);
    if (mounted) {
      setState(() {
        _blockedSlots = blocked;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final success = await ApiService.setAdminAvailability(dateStr, _blockedSlots);
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
    }
  }

  void _toggleSlot(String slotId) {
    setState(() {
      if (_blockedSlots.contains(slotId)) {
        _blockedSlots.remove(slotId);
      } else {
        _blockedSlots.add(slotId);
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

  @override
  Widget build(BuildContext context) {
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
                      'التاريخ: ${DateFormat('yyyy-MM-dd (EEEE)', 'ar').format(_selectedDate)}',
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
                      width: 70,
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
                            DateFormat('MMM', 'ar').format(date),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: isSelected ? Colors.white : const Color(kColorTextLight),
                            ),
                          ),
                          Text(
                            date.day.toString(),
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(kColorSecondary),
                            ),
                          ),
                          Text(
                            DateFormat('E', 'ar').format(date),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
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
                Container(width: 20, height: 4, color: Colors.green),
                const SizedBox(width: 8),
                Text('متاح', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                Container(width: 20, height: 4, color: Colors.red),
                const SizedBox(width: 8),
                Text('مشغول', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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
                        childAspectRatio: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: kTimeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = kTimeSlots[index];
                        final isBlocked = _blockedSlots.contains(slot['id']);

                        return InkWell(
                          onTap: () => _toggleSlot(slot['id']!),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isBlocked ? Colors.red.withOpacity(0.8) : Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              slot['name']!,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
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
