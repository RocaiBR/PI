// ==========================================
// ARQUIVO: lib/utils/sanitizer.dart
// ==========================================
/// Função para higienizar entradas de texto contra XSS e injeções
String sanitize(String input) {
  if (input.isEmpty) return input;

  // Remove tags HTML (ex: <script>, <b>, etc)
  String sanitized = input.replaceAll(
      RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true), '');

  // Remove barras invertidas e caracteres especiais frequentemente usados em injeções
  sanitized = sanitized.replaceAll(RegExp(r'[\\;{}<>]'), '');

  return sanitized.trim();
}
