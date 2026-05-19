// ============================================================
// ARQUIVO: lib/epico2_ia/classificador_service.dart
//
// CORREÇÕES APLICADAS
// [MÉDIO] Cast seguro do output TFLite: o original usava
//         List.from(output[0] as List) que pode lançar TypeError
//         em runtime se os elementos não forem double puro.
//         Substituído por .map((e) => (e as num).toDouble()).
// ============================================================

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Resultado {
  final String layout;
  final double confianca;

  Resultado(this.layout, this.confianca);
}

class ClassificadorService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  /// Chame isso no initState da tela.
  /// Lança [Exception] se o modelo ou labels não puderem ser carregados.
  Future<void> carregar() async {
    _interpreter =
        await Interpreter.fromAsset('assets/modelo/model_unquant.tflite');

    final labelsData =
        await rootBundle.loadString('assets/modelo/labels.txt');

    _labels = labelsData
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^\d+\s+'), ''))
        .toList();
  }

  Future<List<Resultado>> classificar(File imagem) async {
    if (_interpreter == null) throw Exception('Modelo não carregado');

    final bytes = await imagem.readAsBytes();
    final original = img.decodeImage(bytes)!;
    final redimensionada =
        img.copyResize(original, width: 224, height: 224);

    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = redimensionada.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ),
    );

    final output =
        List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

    _interpreter!.run(input, output);

    // ✅ CORREÇÃO [MÉDIO]: cast seguro — output[0] é List dinâmico;
    // elementos podem ser int ou double dependendo do delegate TFLite.
    // O original "List<double>.from(output[0] as List)" lança TypeError
    // quando os elementos são int. O map abaixo cobre ambos os casos.
    final raw = output[0] as List;
    final confiancas = raw.map((e) => (e as num).toDouble()).toList();

    final resultados = List.generate(
      _labels.length,
      (i) => Resultado(_labels[i], confiancas[i]),
    )..sort((a, b) => b.confianca.compareTo(a.confianca));

    return resultados;
  }

  void dispose() => _interpreter?.close();
}
