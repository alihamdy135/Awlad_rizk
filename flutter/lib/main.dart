import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'constants.dart';
import 'screens/home_screen.dart';
import 'screens/not_implemented_screen.dart';
import 'screens/services_screen.dart';
import 'screens/service_detail_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/about_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_availability_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAtSwiBfCry-b1aGKmdfrN7upkgVbnHSwU',
          appId: '1:549682272929:web:8e1298cb4d14374c446ee0',
          messagingSenderId: '549682272929',
          projectId: 'awlad-rizk',
          authDomain: 'awlad-rizk.firebaseapp.com',
          storageBucket: 'awlad-rizk.firebasestorage.app',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    await GoogleSignIn.instance.initialize(
      clientId: '549682272929-1ntj7kvl5okq7b5f5srudgl75r0at4dk.apps.googleusercontent.com',
    );
  } catch (e) {
    debugPrint('Firebase/GoogleSignIn init error: $e');
  }
  runApp(const AwladRizkApp());
}

class AwladRizkApp extends StatelessWidget {
  const AwladRizkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return Container(
          color: Colors.black87,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRect(
                child: child!,
              ),
            ),
          ),
        );
      },
      title: 'نسيم للتبريد والتكييف - Naseem',
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
        '/service_detail': (_) => const ServiceDetailScreen(),
        '/booking': (_) => const BookingScreen(),
        '/about': (_) => const AboutScreen(),
        '/contact': (_) => const ContactScreen(),
        '/faq': (_) => const FAQScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
        '/admin_availability': (_) => const AdminAvailabilityScreen(),
      },
    );
  }
}
