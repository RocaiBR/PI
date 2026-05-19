import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupera o nome passado pela rota
    final String nomeUsuario =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text('Tot - Olá, $nomeUsuario'),
        backgroundColor: const Color(0xFF58001D),
      ),
      body: const Center(
        child: Text('Bem-vindo ao sistema!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
