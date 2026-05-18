import 'package:flutter/material.dart';
import '../app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Widget _buildLogoCard() {
    return ScaleTransition(
      scale: _logoScale,
      child: FadeTransition(
        opacity: _logoFade,
        child: Container(
          width: 260,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B1C3D).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          // Exibe a imagem do logotipo oficial da Pinhalense de forma centralizada
          child: Image.asset(
            'assets/logo_pinhalense.png',
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback caso a imagem local falhe ou o caminho esteja incorreto
              return const Text(
                'PINHALENSE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7B1C3D),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121214), // Fundo escuro elegante para o Splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoCard(),
            const SizedBox(height: 48),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                color: Color(0xFF7B1C3D),
                backgroundColor: Color(0xFF2A2A30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
