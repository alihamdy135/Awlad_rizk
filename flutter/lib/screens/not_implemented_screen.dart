import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class NotImplementedScreen extends StatelessWidget {
  final String title;
  final String description;
  const NotImplementedScreen({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          backgroundColor: const Color(kColorBg),
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(kColorSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(title, style: GoogleFonts.cairo(color: const Color(kColorSecondary), fontWeight: FontWeight.w700)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚧', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(kColorAccent).withOpacity(0.15),
                    border: Border.all(color: const Color(kColorAccent).withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text('قريباً', style: GoogleFonts.cairo(color: const Color(0xFF9A6F1A), fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                const SizedBox(height: 20),
                Text(title, style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(kColorSecondary)), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(description, style: GoogleFonts.cairo(fontSize: 15, color: const Color(kColorTextLight), height: 1.8), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(kColorPrimary),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      shadowColor: const Color(kColorPrimary).withOpacity(0.4),
                    ),
                    child: Text('🏠 الصفحة الرئيسية', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('💬 تواصل عبر واتساب', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF25D366),
          child: const Text('💬', style: TextStyle(fontSize: 26)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
