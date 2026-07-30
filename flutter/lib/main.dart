import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'screens/home_screen.dart';
import 'screens/not_implemented_screen.dart';
import 'screens/services_screen.dart';

void main() {
  runApp(const AwladRizkApp());
}

class AwladRizkApp extends StatelessWidget {
  const AwladRizkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return Container(
          color: Colors.black87, // Dark background for the outside area on desktop
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480), // Mobile phone width constraint
              child: ClipRect(
                child: child!,
              ),
            ),
          ),
        );
      },
      title: 'أولاد رزق للتبريد والتكييف',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(kColorPrimary),
          primary: const Color(kColorPrimary),
          secondary: const Color(kColorAccent),
          surface: const Color(kColorBg),
        ),
        textTheme: GoogleFonts.cairoTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(kColorBg),
          foregroundColor: Color(kColorSecondary),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(kColorPrimary),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
        ),
        fontFamily: GoogleFonts.cairo().fontFamily,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/services': (_) => const ServicesScreen(),
        '/service_detail': (_) => const NotImplementedScreen(
          title: 'تفاصيل الخدمة',
          description: 'صفحة تفاصيل الخدمة مع السعر والضمان والحجز المباشر قيد التطوير.',
        ),
        '/booking': (_) => const NotImplementedScreen(
          title: 'نموذج الحجز',
          description: 'نموذج الحجز السريع (الاسم، الجوال، الحي، العنوان، التاريخ، الفترة الزمنية) قيد التطوير. يمكنك التواصل معنا عبر واتساب لحجز موعدك.',
        ),
        '/about': (_) => const NotImplementedScreen(
          title: 'من نحن',
          description: 'صفحة قصتنا ولماذا أولاد رزق هم الخيار الأفضل قيد التطوير.',
        ),
        '/contact': (_) => const NotImplementedScreen(
          title: 'تواصل معنا',
          description: 'صفحة التواصل مع الخريطة والهاتف قيد التطوير.',
        ),
        '/faq': (_) => const NotImplementedScreen(
          title: 'الأسئلة الشائعة',
          description: 'صفحة جميع الأسئلة الشائعة قيد التطوير.',
        ),
      },
    );
  }
}
