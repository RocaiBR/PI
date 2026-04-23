import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classificador_service.dart';

// Melhoria 3: modelo para o histórico de análises
class EntradaHistorico {
  final File imagem;
  final String layoutSugerido;
  final double confianca;
  final DateTime data;

  EntradaHistorico({
    required this.imagem,
    required this.layoutSugerido,
    required this.confianca,
    required this.data,
  });
}

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

  // Melhoria 1: controle de erro no carregamento
  String? _erroCarregamento;

  // Melhoria 3: histórico de análises em memória
  final List<EntradaHistorico> _historico = [];

  @override
  void initState() {
    super.initState();
    _classificador.carregar().then((_) {
      if (mounted) setState(() { _carregando = false; });
    }).catchError((e) {
      // Melhoria 1: exibe erro em vez de spinner infinito
      if (mounted) {
        setState(() {
          _carregando = false;
          _erroCarregamento =
              'Não foi possível carregar o modelo de IA.\n\nDetalhes: $e';
        });
      }
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
    setState(() {
      _imagem = arquivo;
      _analisando = true;
      _resultados = [];
    });
    try {
      final resultados = await _classificador.classificar(arquivo);
      setState(() {
        _resultados = resultados;
        // Melhoria 3: adiciona ao histórico
        if (resultados.isNotEmpty) {
          _historico.insert(
            0,
            EntradaHistorico(
              imagem: arquivo,
              layoutSugerido: resultados.first.layout,
              confianca: resultados.first.confianca,
              data: DateTime.now(),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na análise: $e')),
        );
      }
    } finally {
      if (mounted) setState(() { _analisando = false; });
    }
  }

  @override
  void dispose() {
    _classificador.dispose();
    super.dispose();
  }

  // Melhoria 3: aba de histórico
  Widget _buildHistorico() {
    if (_historico.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma análise realizada ainda.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historico.length,
      itemBuilder: (_, i) {
        final h = _historico[i];
        final hora =
            '${h.data.hour.toString().padLeft(2, '0')}:${h.data.minute.toString().padLeft(2, '0')}';
        return Card(
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(h.imagem,
                  width: 50, height: 50, fit: BoxFit.cover),
            ),
            title: Text(h.layoutSugerido,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${(h.confianca * 100).toStringAsFixed(1)}% de confiança — $hora'),
            trailing:
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Melhoria 1: tela de erro no carregamento
    if (_erroCarregamento != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('IA — Identificar Layout')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(_erroCarregamento!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }

    if (_carregando) {
      return Scaffold(
        appBar: AppBar(title: const Text('IA — Identificar Layout')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Carregando modelo de IA...'),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IA — Identificar Layout'),
          bottom: TabBar(
            tabs: [
              const Tab(icon: Icon(Icons.camera_alt), text: 'Analisar'),
              Tab(
                icon: Badge(
                  label: Text('${_historico.length}'),
                  isLabelVisible: _historico.isNotEmpty,
                  child: const Icon(Icons.history),
                ),
                text: 'Histórico',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aba principal — análise
            SingleChildScrollView(
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
                            child:
                                Image.file(_imagem!, fit: BoxFit.contain),
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
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                              Text(
                                '${(r.confianca * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),

            // Aba histórico
            _buildHistorico(),
          ],
        ),
      ),
    );
  }
}
