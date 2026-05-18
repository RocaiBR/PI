import 'package:flutter/material.dart';
import '../app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, dynamic>> _faqs = const [
    {
      "q": "Como usar o app?",
      "a":
          "Navegue pelos botões da HomeScreen: use Pesquisa para buscar projetos, FAQ para dúvidas frequentes e Chat TOT para interagir com o assistente.",
      "icon": Icons.phone_android_rounded
    },
    {
      "q": "Esqueci minha senha. O que fazer?",
      "a":
          "Use a opção 'Esqueceu a senha?' na tela de login. Um link de recuperação será enviado ao e-mail cadastrado.",
      "icon": Icons.lock_reset_rounded
    },
    {
      "q": "O app é gratuito?",
      "a":
          "Sim. O TOT é um sistema interno desenvolvido como Atividade do Projeto Integrador, disponibilizado sem custo para usuários autorizados da empresa.",
      "icon": Icons.monetization_on_outlined
    },
    {
      "q": "O TOT é uma IA generativa?",
      "a":
          "Não. O TOT é uma IA preditiva focada em auxiliar na pesquisa de projetos existentes e na automatização de dados e cálculos para a interligação de projetos.",
      "icon": Icons.psychology_outlined
    },
    {
      "q": "Qual a base de dados do TOT?",
      "a":
          "Arquivos específicos da empresa parceira (dados exclusivamente reais), sem uso de dados provenientes de outras inteligências artificiais.",
      "icon": Icons.storage_rounded
    },
    {
      "q": "Como são realizados os cálculos?",
      "a":
          "Utilizando normas e fórmulas parametrizadas pela empresa, seguindo suas regras e práticas. Por ser uma IA, recomenda-se verificação humana dos resultados.",
      "icon": Icons.calculate_outlined
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildGradientAppBar(title: 'Perguntas Frequentes'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              leading: Icon(_faqs[index]["icon"], color: AppColors.primary),
              title: Text(_faqs[index]["q"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              childrenPadding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_faqs[index]["a"]!,
                            style: const TextStyle(color: Colors.black87))),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
