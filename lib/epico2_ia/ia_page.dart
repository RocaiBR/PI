import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classificador_service.dart';

class IaPage extends StatefulWidget {
  const IaPage({super.key});
  @override
  State<IaPage> createState() => _IaPageState();
}

class _IaPageState extends State<IaPage> {
  final _classificador = ClassificadorService();
  final _picker = ImagePicker();

  File? _imagem;
  List<Resultado> _resultados = [];
  bool _carregando = true;
  bool _analisando = false;

  @override
  void initState() {
    super.initState();
    _classificador.carregar().then((_) {
      setState(() { _carregando = false; });
    });
  }

  Future<void> _tirarFoto() async {
    final foto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (foto == null) return;
    await _analisar(File(foto.path));
  }

  Future<void> _escolherGaleria() async {
    final foto = await _picker.pickImage(source: ImageSource.gallery);
    if (foto == null) return;
    await _analisar(File(foto.path));
  }

  Future<void> _analisar(File arquivo) async {
    setState(() { _imagem = arquivo; _analisando = true; _resultados = []; });
    try {
      final resultados = await _classificador.classificar(arquivo);
      setState(() { _resultados = resultados; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() { _analisando = false; });
    }
  }

  @override
  void dispose() {
    _classificador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IA — Identificar Layout')),
      body: _carregando
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Carregando modelo de IA...'),
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Preview da imagem
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: _imagem != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imagem!, fit: BoxFit.contain),
                          )
                        : const Center(
                            child: Text('Nenhuma imagem selecionada',
                              style: TextStyle(color: Colors.grey)),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Botões
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _analisando ? null : _tirarFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Câmera'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _analisando ? null : _escolherGaleria,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeria'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Resultados
                  if (_analisando)
                    const CircularProgressIndicator()
                  else if (_resultados.isNotEmpty) ...[
                    // Melhor resultado em destaque
                    Card(
                      color: Colors.green.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.auto_awesome,
                          color: Colors.green, size: 32),
                        title: Text(
                          '💡 Sugestão: ${_resultados.first.layout}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          'Confiança: ${(_resultados.first.confianca * 100).toStringAsFixed(1)}%',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Demais resultados
                    const Text('Todas as probabilidades:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._resultados.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.layout),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: r.confianca,
                            backgroundColor: Colors.grey.shade200,
                            color: r == _resultados.first
                                ? Colors.green : Colors.blue,
                          ),
                          Text('${(r.confianca * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
    );
  }
}
