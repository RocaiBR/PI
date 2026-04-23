import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Resultado {
  final String layout;
  final double confianca; // 0.0 a 1.0

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

    // Melhoria 2: remove o prefixo numérico exportado pelo Teachable Machine
    // Ex.: "0 Layout A"  →  "Layout A"
    _labels = labelsData
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.replaceFirst(RegExp(r'^\d+\s+'), ''))
        .toList();
  }

  Future<List<Resultado>> classificar(File imagem) async {
    if (_interpreter == null) throw Exception('Modelo não carregado');

    // 1. Redimensiona para 224x224 (padrão do Teachable Machine)
    final bytes = await imagem.readAsBytes();
    final original = img.decodeImage(bytes)!;
    final redimensionada =
        img.copyResize(original, width: 224, height: 224);

    // 2. Normaliza pixels para [0, 1]
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

    // 3. Prepara saída
    final output =
        List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

    // 4. Inferência
    _interpreter!.run(input, output);

    // 5. Monta resultados ordenados por confiança
    final confiancas = List<double>.from(output[0] as List);
    final resultados = List.generate(
      _labels.length,
      (i) => Resultado(_labels[i], confiancas[i]),
    )..sort((a, b) => b.confianca.compareTo(a.confianca));

    return resultados;
  }

  void dispose() => _interpreter?.close();
}
