import 'package:flutter/material.dart';
import 'epico1_automacao/automacao_page.dart';
import 'epico2_ia/ia_page.dart';

void main() => runApp(const PinhalenseApp());

class PinhalenseApp extends StatelessWidget {
  const PinhalenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinhalense — Setor de Projetos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinhalense — Projetos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Selecione o módulo:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            // Épico 1
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AutomacaoPage())),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(children: [
                    Icon(Icons.table_chart, size: 40, color: Colors.blue),
                    SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Épico 1', style: TextStyle(
                          color: Colors.grey, fontSize: 12)),
                        Text('Automação da Interligação',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('CSV do Inventor → Excel'),
                      ],
                    )),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Épico 2
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const IaPage())),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(children: [
                    Icon(Icons.auto_awesome, size: 40, color: Colors.purple),
                    SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Épico 2', style: TextStyle(
                          color: Colors.grey, fontSize: 12)),
                        Text('IA para Identificação de Layout',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Foto do croqui → Sugestão de layout'),
                      ],
                    )),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
