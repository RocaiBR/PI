import 'package:flutter/material.dart';
import '../app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(title: 'Meu Perfil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Usuário TOT',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'usuario@empresa.com.br',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.phone, color: AppColors.primary),
                    title: Text('Telefone'),
                    subtitle: Text('(11) 99999-9999'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.cake, color: AppColors.primary),
                    title: Text('Data de Nascimento'),
                    subtitle: Text('15/08/1990'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AnimatedPressButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Funcionalidade de edição em breve.')),
                );
              },
              isOutlined: true,
              child: const Text('EDITAR PERFIL',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
