class ErroValidacao {
  final int linha;
  final String campo;
  final String mensagem;

  ErroValidacao(this.linha, this.campo, this.mensagem);

  @override
  String toString() => 'Linha $linha | $campo: $mensagem';
}

class ValidacaoService {
  List<ErroValidacao> validar(List<ItemInventor> itens) {
    final erros = <ErroValidacao>[];

    for (int i = 0; i < itens.length; i++) {
      final item = itens[i];
      final linha = i + 2; // +2 porque linha 1 é cabeçalho

      // Campo vazio
      if (item.codigo.isEmpty) {
        erros.add(ErroValidacao(linha, 'Código', 'Campo vazio'));
      }
      if (item.descricao.isEmpty) {
        erros.add(ErroValidacao(linha, 'Descrição', 'Campo vazio'));
      }
      if (item.unidade.isEmpty) {
        erros.add(ErroValidacao(linha, 'Unidade', 'Campo vazio'));
      }

      // Número negativo ou zero
      if (item.quantidade <= 0) {
        erros.add(ErroValidacao(
          linha,
          'Quantidade',
          'Deve ser maior que zero (valor: ${item.quantidade})',
        ));
      }
    }

    return erros;
  }
}
