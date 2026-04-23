import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'csv_service.dart';

class ExcelService {
  Future<String> exportarParaExcel(List<ItemInventor> itens) async {
    final excel = Excel.createExcel();
    final Sheet aba = excel['Interligação'];

    // --- Cabeçalho ---
    final cabecalho = ['Código', 'Descrição', 'Quantidade', 'Unidade'];
    for (int col = 0; col < cabecalho.length; col++) {
      final cell = aba.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.value = TextCellValue(cabecalho[col]);
      // Negrito no cabeçalho
      cell.cellStyle = CellStyle(bold: true);
    }

    // --- Dados ---
    for (int row = 0; row < itens.length; row++) {
      final item = itens[row];
      final rowIndex = row + 1;

      aba.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = TextCellValue(item.codigo);

      aba.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = TextCellValue(item.descricao);

      aba.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = DoubleCellValue(item.quantidade);

      aba.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = TextCellValue(item.unidade);
    }

    // --- Salva o arquivo ---
    final dir = await getApplicationDocumentsDirectory();
    final caminho = '${dir.path}/interligacao_output.xlsx';
    final bytes = excel.encode()!;
    await File(caminho).writeAsBytes(bytes);

    return caminho; // retorna o caminho para mostrar na tela
  }
}
