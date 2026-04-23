import 'package:flutter_test/flutter_test.dart';
import 'package:pinhalense/epico1_automacao/csv_service.dart';
import 'package:pinhalense/epico1_automacao/validacao_service.dart';

void main() {
  final validacao = ValidacaoService();

  // Helper para criar itens de teste facilmente
  ItemInventor item({
    String codigo = 'COD-001',
    String descricao = 'Peça Teste',
    double quantidade = 1.0,
    String unidade = 'UN',
  }) {
    return ItemInventor(
      codigo: codigo,
      descricao: descricao,
      quantidade: quantidade,
      unidade: unidade,
    );
  }

  group('ValidacaoService —', () {
    test('lista vazia não retorna erros', () {
      final erros = validacao.validar([]);
      expect(erros, isEmpty);
    });

    test('item válido não retorna erros', () {
      final erros = validacao.validar([item()]);
      expect(erros, isEmpty);
    });

    test('código vazio gera erro no campo Código', () {
      final erros = validacao.validar([item(codigo: '')]);
      expect(erros.any((e) => e.campo == 'Código'), isTrue);
    });

    test('descrição vazia gera erro no campo Descrição', () {
      final erros = validacao.validar([item(descricao: '')]);
      expect(erros.any((e) => e.campo == 'Descrição'), isTrue);
    });

    test('unidade vazia gera erro no campo Unidade', () {
      final erros = validacao.validar([item(unidade: '')]);
      expect(erros.any((e) => e.campo == 'Unidade'), isTrue);
    });

    test('quantidade zero gera erro no campo Quantidade', () {
      final erros = validacao.validar([item(quantidade: 0)]);
      expect(erros.any((e) => e.campo == 'Quantidade'), isTrue);
    });

    test('quantidade negativa gera erro no campo Quantidade', () {
      final erros = validacao.validar([item(quantidade: -5)]);
      expect(erros.any((e) => e.campo == 'Quantidade'), isTrue);
    });

    test('item com todos os campos vazios gera 3 erros', () {
      final erros = validacao.validar([
        item(codigo: '', descricao: '', unidade: '', quantidade: 0),
      ]);
      // codigo, descricao, unidade, quantidade = 4 erros
      expect(erros.length, 4);
    });

    test('número da linha nos erros começa em 2 (linha 1 é cabeçalho)', () {
      final erros = validacao.validar([item(codigo: '')]);
      expect(erros.first.linha, 2);
    });

    test('múltiplos itens — erros apontam linhas corretas', () {
      final itens = [
        item(),           // linha 2 — válido
        item(codigo: ''), // linha 3 — inválido
        item(),           // linha 4 — válido
      ];
      final erros = validacao.validar(itens);
      expect(erros.length, 1);
      expect(erros.first.linha, 3);
    });
  });
}
