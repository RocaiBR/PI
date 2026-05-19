import 'package:flutter/material.dart';
import '../app_theme.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(title: 'Detalhes do Projeto'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.cardDark,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: const [
                    Icon(Icons.folder_shared,
                        size: 64, color: AppColors.accentSoft),
                    SizedBox(height: 16),
                    Text(
                      'Documento Estrutural Alpha',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Criado em: 07/04/2026',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8.0,
              children: const [
                Chip(label: Text('Engenharia')),
                Chip(label: Text('Aprovado')),
                Chip(label: Text('Norma ABNT')),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Informações Adicionais:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Placeholder: A integração com a base de dados real será implementada em atualizações futuras para exibição dinâmica dos dados técnicos da obra.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
