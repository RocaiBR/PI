// ============================================================
// ARQUIVO: lib/epico1_automacao/csv_service.dart
//
// CORREÇÕES APLICADAS
// [MÉDIO] Normalização de \r\n antes do parse — CSVs exportados
//         pelo Autodesk Inventor no Windows usam \r\n, fazendo
//         o \r grudar no último campo de cada linha sem a fix.
// ============================================================

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
  /// Abre o seletor de arquivo e retorna os itens lidos.
  Future<List<ItemInventor>> importarCsvInventor() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );

    if (resultado == null || resultado.files.single.path == null) {
      throw Exception('Nenhum arquivo selecionado.');
    }

    final arquivo = File(resultado.files.single.path!);
    final conteudoBruto = await arquivo.readAsString();

    // ✅ CORREÇÃO [MÉDIO]: normaliza quebras de linha antes do parse.
    // Inventor no Windows gera \r\n; sem isso o \r cola no último campo.
    final conteudo = conteudoBruto
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    final linhas = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
    ).convert(conteudo);

    final itens = <ItemInventor>[];
    for (int i = 1; i < linhas.length; i++) {
      final linha = linhas[i];
      if (linha.length < 4) continue;

      itens.add(ItemInventor(
        codigo:     linha[0].toString().trim(),
        descricao:  linha[1].toString().trim(),
        quantidade: double.tryParse(linha[2].toString().trim()) ?? 0,
        unidade:    linha[3].toString().trim(),
      ));
    }

    return itens;
  }
}
