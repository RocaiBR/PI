import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/faq_screen.dart';
import 'pages/register_page.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/faq_page.dart';
import 'pages/recovery_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/details_page.dart';
import 'pages/marcelaoparte.dart';
import 'pages/admin_banco_page.dart'; // ← novo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TotApp());
}

class TotApp extends StatelessWidget {
  const TotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tot - Assistente Interno',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.surface,
      ),
      initialRoute: '/splash',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/register': (context) => const RegisterPage(),
        '/splash': (context) => const SplashPage(),
        '/home': (context) => const HomePage(),
        '/faq': (context) => const FaqPage(),
        '/recovery': (context) => const RecoveryPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/details': (context) => const DetailsPage(),
        '/marcela_login': (context) => const MarcelaLoginPage(),
        '/search_screen': (context) => const SearchScreen(),
        '/faq_screen': (context) => const FaqScreen(),
        '/admin_banco': (context) => const AdminBancoPage(), // ← novo
      },
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    );
  }
}
