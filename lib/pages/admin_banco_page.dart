// ============================================================
// ARQUIVO: lib/pages/admin_banco_page.dart
//
// CORREÇÕES APLICADAS
// [ALTO] Adicionada verificação de FirebaseAuth.instance.currentUser
//        antes de qualquer upload para o Cloudinary.
//        Sem isso, qualquer pessoa com o cloud name e o preset
//        poderia fazer upload diretamente — independente de login.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';

class AdminBancoPage extends StatefulWidget {
  const AdminBancoPage({super.key});

  @override
  State<AdminBancoPage> createState() => _AdminBancoPageState();
}

class _AdminBancoPageState extends State<AdminBancoPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  List<Map<String, dynamic>> _imagensBanco = [];

  @override
  void initState() {
    super.initState();
    _carregarBanco();
  }

  Future<void> _carregarBanco() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('banco_imagens').get();
    if (!mounted) return;
    setState(() {
      _imagensBanco =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  Future<void> _adicionarImagem() async {
    // ✅ CORREÇÃO [ALTO]: verifica autenticação antes do upload.
    // Sem isso qualquer pessoa com cloud name + preset faz upload.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você precisa estar autenticado para fazer upload.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = kIsWeb
          ? await image.readAsBytes()
          : await File(image.path).readAsBytes();

      const String cloudName = 'dn2vlkwuf';
      const String uploadPreset = 'TOT_CHAT';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: image.name,
      ));

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(await response.stream.bytesToString());
        final imageUrl = data['secure_url'] as String;

        await FirebaseFirestore.instance.collection('banco_imagens').add({
          'imageUrl': imageUrl,
          'nome': image.name,
          'adicionadoEm': DateTime.now().toIso8601String(),
          'adicionadoPor': user.uid, // ✅ rastreia quem fez o upload
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagem adicionada ao banco com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        await _carregarBanco();
      } else {
        throw Exception('Erro Cloudinary: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _removerImagem(String docId) async {
    await FirebaseFirestore.instance
        .collection('banco_imagens')
        .doc(docId)
        .delete();
    await _carregarBanco();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: buildGradientAppBar(title: 'BANCO DE IMAGENS'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _adicionarImagem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add_photo_alternate, color: Colors.white),
                label: Text(
                  _isUploading
                      ? 'Enviando...'
                      : 'Adicionar Imagem de Referência',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_imagensBanco.length} imagem(ns) no banco',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _imagensBanco.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma imagem no banco.\nAdicione imagens de referência.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _imagensBanco.length,
                    itemBuilder: (context, index) {
                      final img = _imagensBanco[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              img['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.cardDark,
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removerImagem(img['id']),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
