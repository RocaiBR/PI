import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/ia_service.dart';

class ChatMessage {
  final String sender;
  final String text;
  final String? imageUrl;

  ChatMessage({
    required this.sender,
    required this.text,
    this.imageUrl,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _chatController = TextEditingController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      sender: 'TOT',
      text: 'Olá! Sou o TOT, o seu assistente preditivo. Como posso ajudar?',
    )
  ];

  bool _isDark = true;
  XFile? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;
      setState(() => _selectedImage = image);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao escolher imagem: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showAttachmentModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Anexar Arquivo', textAlign: TextAlign.center),
          content: Container(
            height: 200,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _pickImage(ImageSource.gallery),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drive_folder_upload, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Clique para selecionar ou arraste para cá',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Formatos: PNG, JPG, GIF',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    String? uploadedImageUrl;
    Uint8List? imageBytesToIA;

    setState(() {
      _messages.add(ChatMessage(
        sender: 'Você',
        text: text,
        imageUrl: _selectedImage?.path,
      ));
      _isUploading = true;
    });

    if (_selectedImage != null) {
      try {
        if (kIsWeb) {
          imageBytesToIA = await _selectedImage!.readAsBytes();
        } else {
          imageBytesToIA = await File(_selectedImage!.path).readAsBytes();
        }

        const String cloudName = 'dn2vlkwuf';
        const String uploadPreset = 'TOT_CHAT';

        final url = Uri.parse(
            'https://api.cloudinary.com/v1_1/$cloudName/image/upload');
        final request = http.MultipartRequest('POST', url);
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytesToIA,
          filename: _selectedImage!.name,
        ));

        final response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = await response.stream.bytesToString();
          final jsonMap = jsonDecode(responseData);
          uploadedImageUrl = jsonMap['secure_url'];
        } else {
          throw Exception(
              'Código de erro do Cloudinary: ${response.statusCode}');
        }

        await FirebaseFirestore.instance.collection('chats').add({
          'text': text,
          'imageUrl': uploadedImageUrl,
          'senderId': FirebaseAuth.instance.currentUser?.uid ?? 'anonimo',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erro ao processar imagem: $e'),
                backgroundColor: Colors.red),
          );
        }
        setState(() => _isUploading = false);
        return;
      }
    }

    setState(() {
      _selectedImage = null;
      _isUploading = false;
      _chatController.clear();
    });

    if (imageBytesToIA != null) {
      setState(() {
        _messages.add(
            ChatMessage(sender: 'TOT', text: 'Analisando imagem com IA...'));
      });

      try {
        final snapshot =
            await FirebaseFirestore.instance.collection('banco_imagens').get();

        if (snapshot.docs.isEmpty) {
          if (mounted) {
            setState(() {
              _messages.removeLast();
              _messages.add(ChatMessage(
                sender: 'TOT',
                text:
                    'O banco de imagens está vazio. Adicione imagens de referência primeiro.',
              ));
            });
          }
          return;
        }

        final List<Map<String, dynamic>> imagensBanco = [];
        for (var doc in snapshot.docs) {
          final dados = doc.data();
          if (!dados.containsKey('imageUrl')) continue;
          try {
            final imgRes = await http
                .get(Uri.parse(dados['imageUrl']))
                .timeout(const Duration(seconds: 15));
            if (imgRes.statusCode == 200) {
              imagensBanco.add({
                'imageUrl': dados['imageUrl'],
                'bytes': imgRes.bodyBytes,
              });
            }
          } catch (e) {
            print('Erro ao baixar imagem do banco: $e');
          }
        }

        if (imagensBanco.isEmpty) {
          if (mounted) {
            setState(() {
              _messages.removeLast();
              _messages.add(ChatMessage(
                sender: 'TOT',
                text:
                    'Não consegui acessar as imagens do banco. Verifique a conexão.',
              ));
            });
          }
          return;
        }

        final resultado = await IaService.analisarComContexto(
          imagemUsuario: imageBytesToIA,
          imagensBanco: imagensBanco,
          textoUsuario: text.isNotEmpty ? text : 'análise de imagem',
        );

        if (mounted) {
          setState(() {
            _messages.removeLast();
            if (resultado == null) {
              _messages.add(ChatMessage(
                sender: 'TOT',
                text: 'Não consegui processar a imagem. Tente novamente.',
              ));
            } else if (resultado.containsKey('erro')) {
              _messages.add(ChatMessage(
                sender: 'TOT',
                text: '⚠️ ${resultado['erro']}',
              ));
            } else {
              _messages.add(ChatMessage(
                sender: 'TOT',
                text: resultado['mensagem'] as String,
                imageUrl: resultado['imageUrl'] as String?,
              ));
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _messages.removeLast();
            _messages.add(ChatMessage(
              sender: 'TOT',
              text: 'Erro ao analisar imagem: $e',
            ));
          });
        }
      }
    } else if (text.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              sender: 'TOT',
              text:
                  'Para ativar a busca preditiva, anexe uma imagem usando o ícone de clipe.',
            ));
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDark ? AppColors.surface : const Color(0xFFF7F3F5);
    final textColor = _isDark ? AppColors.textPrimary : const Color(0xFF1C0F18);

    return Theme(
      data: Theme.of(context).copyWith(scaffoldBackgroundColor: bgColor),
      child: Scaffold(
        appBar: buildGradientAppBar(title: 'CHAT'),
        drawer: Drawer(
          backgroundColor: AppColors.cardDark,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: AppColors.primaryDark),
                child: Text('TOT Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: AppColors.textPrimary),
                title: const Text('Novo Chat',
                    style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  setState(() => _messages.clear());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline,
                    color: AppColors.textPrimary),
                title: const Text('FAQ',
                    style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pushNamed(context, '/faq'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.textPrimary),
                title: const Text('Banco de Imagens',
                    style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pushNamed(context, '/admin_banco'),
              ),
              SwitchListTile(
                title: const Text('Modo Escuro',
                    style: TextStyle(color: AppColors.textPrimary)),
                value: _isDark,
                activeColor: AppColors.accent,
                onChanged: (val) => setState(() => _isDark = val),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.sender == 'Você';

                  final bubbleColor = isUser
                      ? (_isDark
                          ? AppColors.primaryLight.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.12))
                      : (_isDark
                          ? AppColors.cardDark
                          : const Color(0xFFEDE0E5));

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isUser
                                ? AppColors.primary.withOpacity(0.5)
                                : Colors.transparent),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (kIsWeb ||
                                        msg.imageUrl!.startsWith('http'))
                                    ? Image.network(
                                        msg.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Text(
                                                    '[Erro ao carregar imagem]',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                      )
                                    : Image.file(
                                        File(msg.imageUrl!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Text(
                                                    '[Erro ao carregar imagem]',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                      ),
                              ),
                            ),
                          if (msg.text.isNotEmpty)
                            Text(
                              '${msg.sender}: ${msg.text}',
                              style: TextStyle(color: textColor),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_selectedImage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(_selectedImage!.path,
                                fit: BoxFit.cover, height: 60, width: 60)
                            : Image.file(File(_selectedImage!.path),
                                fit: BoxFit.cover, height: 60, width: 60),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pronto para enviar',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Imagem anexada',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          )
                        : const Icon(Icons.attach_file,
                            color: AppColors.primary),
                    onPressed: _isUploading ? null : _showAttachmentModal,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Digite a sua dúvida...',
                        hintStyle: TextStyle(
                            color: _isDark
                                ? AppColors.textSecondary
                                : const Color(0xFF7A5566)),
                        filled: true,
                        fillColor: _isDark ? AppColors.cardDark : Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: _isDark
                                    ? Colors.transparent
                                    : AppColors.primary.withOpacity(0.25))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: _isDark
                                    ? Colors.transparent
                                    : AppColors.primary.withOpacity(0.25))),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primary),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
