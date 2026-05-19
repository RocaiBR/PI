// ============================================================
// ARQUIVO: lib/pages/marcelaoparte.dart
//
// CORREÇÕES APLICADAS
// [CRÍTICO] Removido login admin/123 hardcoded.
//           Substituído por Firebase Auth real, igual ao LoginScreen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';

class MarcelaLoginPage extends StatefulWidget {
  const MarcelaLoginPage({super.key});

  @override
  State<MarcelaLoginPage> createState() => _MarcelaLoginPageState();
}

class _MarcelaLoginPageState extends State<MarcelaLoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  // ✅ CORREÇÃO [CRÍTICO]: removido o bloco abaixo que existia aqui:
  //
  //   void _doLogin() {
  //     if (_userController.text == 'admin' && _passController.text == '123') {
  //       Navigator.pushReplacementNamed(context, '/home_screen');
  //     } else {
  //       ScaffoldMessenger...showSnackBar('Credenciais inválidas!');
  //     }
  //   }
  //
  // Substituído por autenticação real via Firebase Auth.
  // Para testar, crie a conta pelo Firebase Console:
  //   Authentication → Adicionar usuário → email + senha.

  Future<void> _doLogin() async {
    final email = _userController.text.trim();
    final senha = _passController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Preencha e-mail e senha.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: senha);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home_screen');
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Credenciais inválidas.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        msg = 'E-mail ou senha incorretos.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(title: 'Acesso Restrito'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings,
                  size: 80, color: AppColors.primary),
              const SizedBox(height: 32),
              TextField(
                controller: _userController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : AnimatedPressButton(
                      onPressed: _doLogin,
                      child: const Text('ENTRAR',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
