import 'package:flutter/material.dart';
import '../app_theme.dart';

class MarcelaLoginPage extends StatefulWidget {
  const MarcelaLoginPage({super.key});

  @override
  State<MarcelaLoginPage> createState() => _MarcelaLoginPageState();
}

class _MarcelaLoginPageState extends State<MarcelaLoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _doLogin() {
    if (_userController.text == 'admin' && _passController.text == '123') {
      Navigator.pushReplacementNamed(context, '/home_screen');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Credenciais inválidas!'),
            backgroundColor: Colors.red),
      );
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
                decoration: const InputDecoration(
                  labelText: 'Usuário',
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
              AnimatedPressButton(
                onPressed: _doLogin,
                child: const Text('ENTRAR',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
