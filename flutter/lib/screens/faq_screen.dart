import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models.dart';
import '../api_service.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<FAQModel> _faqs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final faqs = await ApiService.getFAQs(limit: 100);
    if (mounted) {
      setState(() {
        _faqs = faqs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          title: Text('الأسئلة الشائعة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(kColorPrimary)))
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(kColorBorder)),
                    ),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text(faq.questionAr, style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(kColorSecondary))),
                      iconColor: const Color(kColorPrimary),
                      collapsedIconColor: const Color(kColorPrimary),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(faq.answerAr, style: GoogleFonts.cairo(fontSize: 14, color: const Color(kColorTextLight), height: 1.6)),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
