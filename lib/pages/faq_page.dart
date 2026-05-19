import 'package:flutter/material.dart';
import '../app_theme.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(title: 'FAQ - Ajuda Rápida'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.help_outline, color: AppColors.primary),
              title: Text('Como usar o app?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Navegue pela HomeScreen para acessar a Pesquisa, FAQ e o Chat TOT para interagir com o assistente.'),
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.lock_reset, color: AppColors.primary),
              title: Text('Esqueci minha senha. O que fazer?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Use a opção "Esqueceu a senha?" na tela de login para receber um link de recuperação.'),
            ),
          ),
          SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.monetization_on_outlined,
                  color: AppColors.primary),
              title: Text('O app é gratuito?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Sim. O TOT é um sistema interno desenvolvido sem custo para usuários autorizados da empresa.'),
            ),
          ),
        ],
      ),
    );
  }
}
