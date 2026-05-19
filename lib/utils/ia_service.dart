// ============================================================
// ARQUIVO: lib/utils/ia_service.dart
//
// CORREÇÕES APLICADAS
// [ALTO] Todos os print() substituídos por blocos condicionais
//        com kDebugMode — em builds de release (APK final)
//        nenhum dado de payload ou erro vaza via adb logcat.
//
// NOTA ARQUITETURAL [ALTO — não resolvido aqui]:
//   A _geminiKey via dart-define ainda é embutida no APK.
//   A solução correta é mover a chamada ao Gemini para um
//   Cloud Function (Firebase Functions) e o app apenas
//   chamar esse endpoint autenticado. Isso requer mudança
//   de arquitetura e está fora do escopo deste PR de fixes.
// ============================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

class IaService {
  static const String _geminiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<Map<String, dynamic>?> analisarComContexto({
    required Uint8List imagemUsuario,
    required List<Map<String, dynamic>> imagensBanco,
    required String textoUsuario,
  }) async {
    if (_geminiKey.isEmpty) {
      // ✅ CORREÇÃO [ALTO]: era print() sem guarda — visível em produção
      if (kDebugMode) {
        print('[IaService] GEMINI_API_KEY não configurada!');
      }
      return {
        'erro':
            'Chave da API não configurada. Rode com --dart-define=GEMINI_API_KEY=sua_chave'
      };
    }

    try {
      if (imagensBanco.isEmpty) {
        return {
          'erro':
              'Banco de imagens vazio. Adicione imagens de referência primeiro.'
        };
      }

      final parts = <Map<String, dynamic>>[];

      parts.add({
        'text': '''
O usuário enviou uma imagem com o seguinte contexto: "$textoUsuario".

A primeira imagem abaixo é a do usuário.
Compare-a visualmente com as imagens do banco numeradas a seguir.

Responda APENAS E EXCLUSIVAMENTE com um JSON neste formato exato:
{
  "indice": <número da imagem do banco mais similar, começando em 1>,
  "mensagem": "<frase curta confirmando a sugestão>"
}

Se nenhuma imagem for suficientemente similar, responda:
{
  "indice": 0,
  "mensagem": "Não encontrei correspondência no banco para este pedido."
}
'''
      });

      parts.add({
        'inlineData': {
          'mimeType': 'image/jpeg',
          'data': base64Encode(imagemUsuario),
        }
      });

      final bancoParcial =
          imagensBanco.length > 3 ? imagensBanco.sublist(0, 3) : imagensBanco;

      for (int i = 0; i < bancoParcial.length; i++) {
        parts.add({'text': 'Imagem do banco ${i + 1}:'});
        final imageBytes = bancoParcial[i]['bytes'] as Uint8List?;
        if (imageBytes != null) {
          parts.add({
            'inlineData': {
              'mimeType': 'image/jpeg',
              'data': base64Encode(imageBytes),
            }
          });
        }
      }

      // ✅ CORREÇÃO [ALTO]: print com tamanho do payload só em debug
      if (kDebugMode) {
        final requestBody = jsonEncode({
          'contents': [
            {'parts': parts}
          ]
        });
        print(
            '[IaService] Enviando para Gemini com ${bancoParcial.length} imagem(ns)...');
        print(
            '[IaService] Payload: ${(requestBody.length / 1024).toStringAsFixed(1)} KB');
      }

      final requestBody = jsonEncode({
        'contents': [
          {'parts': parts}
        ]
      });

      final response = await http
          .post(
            Uri.parse('$_apiUrl?key=$_geminiKey'),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 60));

      // ✅ CORREÇÃO [ALTO]: status code e resposta só em debug
      if (kDebugMode) {
        print('[IaService] Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['candidates'] == null ||
            (decoded['candidates'] as List).isEmpty) {
          if (kDebugMode) {
            print('[IaService] Gemini sem candidatos: ${response.body}');
          }
          return {
            'erro': 'Gemini não retornou candidatos.'
          };
        }

        final textoBruto =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;

        if (kDebugMode) print('[IaService] Resposta: $textoBruto');

        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(textoBruto);

        if (jsonMatch != null) {
          final json = jsonDecode(jsonMatch.group(0)!);
          final indice = json['indice'] as int;
          final mensagem = json['mensagem'] as String;

          if (indice >= 1 && indice <= bancoParcial.length) {
            return {
              'imageUrl': bancoParcial[indice - 1]['imageUrl'] as String,
              'mensagem': mensagem,
            };
          } else {
            return {'imageUrl': null, 'mensagem': mensagem};
          }
        } else {
          if (kDebugMode) {
            print('[IaService] Resposta inesperada: $textoBruto');
          }
          return {'erro': 'Resposta inesperada do Gemini.'};
        }
      } else {
        String mensagemErro;
        try {
          final erroJson = jsonDecode(response.body);
          mensagemErro = erroJson['error']?['message'] ?? 'Erro desconhecido';
        } catch (_) {
          mensagemErro = 'HTTP ${response.statusCode}';
        }
        if (kDebugMode) print('[IaService] Erro: $mensagemErro');
        return {'erro': 'Erro Gemini: $mensagemErro'};
      }
    } catch (e) {
      if (kDebugMode) print('[IaService] Exceção: $e');
      return {'erro': 'Exceção: $e'};
    }
  }
}
