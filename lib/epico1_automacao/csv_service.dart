import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class ItemInventor {
  final String codigo;
  final String descricao;
  final double quantidade;
  final String unidade;

  ItemInventor({
    required this.codigo,
    required this.descricao,
    required this.quantidade,
    required this.unidade,
  });
}

class CsvService {
  /// Abre o seletor de arquivo e retorna os itens lidos
  Future<List<ItemInventor>> importarCsvInventor() async {
    // 1. Usuário escolhe o arquivo
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );

    if (resultado == null || resultado.files.single.path == null) {
      throw Exception('Nenhum arquivo selecionado.');
    }

    // 2. Lê o conteúdo
    final arquivo = File(resultado.files.single.path!);
    final conteudo = await arquivo.readAsString();

    // 3. Faz o parse do CSV
    final linhas = const CsvToListConverter(
      fieldDelimiter: ';',   // Inventor costuma usar ponto-e-vírgula
      eol: '\n',
    ).convert(conteudo);

    // 4. Pula o cabeçalho (linha 0) e converte
    final itens = <ItemInventor>[];
    for (int i = 1; i < linhas.length; i++) {
      final linha = linhas[i];
      if (linha.length < 4) continue; // linha incompleta, ignora

      itens.add(ItemInventor(
        codigo:      linha[0].toString().trim(),
        descricao:   linha[1].toString().trim(),
        quantidade:  double.tryParse(linha[2].toString().trim()) ?? 0,
        unidade:     linha[3].toString().trim(),
      ));
    }

    return itens;
  }
}
