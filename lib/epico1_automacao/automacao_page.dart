import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'csv_service.dart';
import 'validacao_service.dart';
import 'excel_service.dart';

class AutomacaoPage extends StatefulWidget {
  const AutomacaoPage({super.key});
  @override
  State<AutomacaoPage> createState() => _AutomacaoPageState();
}

class _AutomacaoPageState extends State<AutomacaoPage> {
  final _csvService = CsvService();
  final _validacao = ValidacaoService();
  final _excel = ExcelService();

  List<ItemInventor> _itens = [];
  List<ErroValidacao> _erros = [];
  String _status = 'Aguardando arquivo...';
  bool _carregando = false;

  // Melhoria 4: guarda o caminho do último Excel gerado para compartilhar
  String? _caminhoExcel;

  Future<void> _importar() async {
    setState(() {
      _carregando = true;
      _status = 'Lendo CSV...';
      _caminhoExcel = null;
    });

    try {
      final itens = await _csvService.importarCsvInventor();
      final erros = _validacao.validar(itens);

      setState(() {
        _itens = itens;
        _erros = erros;
        _status = erros.isEmpty
            ? '✅ ${itens.length} itens importados sem erros!'
            : '⚠️ ${itens.length} itens | ${erros.length} erro(s) encontrado(s)';
      });
    } catch (e) {
      setState(() { _status = 'Erro: $e'; });
    } finally {
      setState(() { _carregando = false; });
    }
  }

  Future<void> _exportar() async {
    if (_itens.isEmpty) return;
    setState(() { _carregando = true; _status = 'Gerando Excel...'; });

    try {
      final caminho = await _excel.exportarParaExcel(_itens);
      setState(() {
        _caminhoExcel = caminho;
        _status = '✅ Excel gerado! Use o botão abaixo para compartilhar.';
      });
    } catch (e) {
      setState(() { _status = 'Erro ao exportar: $e'; });
    } finally {
      setState(() { _carregando = false; });
    }
  }

  // Melhoria 4: abre o share sheet nativo do Android
  Future<void> _compartilhar() async {
    if (_caminhoExcel == null) return;
    await Share.shareXFiles(
      [XFile(_caminhoExcel!)],
      subject: 'Interligação — Lista de Materiais',
      text: 'Segue a BOM exportada pelo app Pinhalense.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automação — Interligação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_status, style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 16),

            // Botões principais
            ElevatedButton.icon(
              onPressed: _carregando ? null : _importar,
              icon: const Icon(Icons.upload_file),
              label: const Text('1. Importar CSV do Inventor'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: (_carregando || _itens.isEmpty) ? null : _exportar,
              icon: const Icon(Icons.table_chart),
              label: const Text('2. Exportar para Excel'),
            ),

            // Melhoria 4: botão de compartilhar — visível apenas após exportar
            if (_caminhoExcel != null) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: _compartilhar,
                icon: const Icon(Icons.share),
                label: const Text('3. Compartilhar Excel'),
              ),
            ],

            const SizedBox(height: 16),

            // Erros de validação
            if (_erros.isNotEmpty) ...[
              Text(
                'Erros encontrados:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _erros.length,
                  itemBuilder: (_, i) => Card(
                    color: Colors.red.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.error_outline,
                          color: Colors.red),
                      title: Text(_erros[i].toString()),
                    ),
                  ),
                ),
              ),
            ],

            // Preview dos dados
            if (_erros.isEmpty && _itens.isNotEmpty) ...[
              Text(
                'Preview (${_itens.length} itens):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _itens.length,
                  itemBuilder: (_, i) {
                    final item = _itens[i];
                    return ListTile(
                      leading: Text('${i + 1}',
                          style: const TextStyle(color: Colors.grey)),
                      title: Text(item.descricao),
                      subtitle: Text('Cód: ${item.codigo}'),
                      trailing:
                          Text('${item.quantidade} ${item.unidade}'),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
