// ATENÇÃO: Este arquivo NÃO deve ser versionado com chaves reais.
// Está no .gitignore. Cada desenvolvedor gera o seu via:
//   flutterfire configure
//
// Para rodar localmente, crie um arquivo .env ou use dart-define:
//   flutter run --dart-define=FIREBASE_API_KEY=sua_chave

// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions não configurado para Android. '
          'Rode: flutterfire configure',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions não configurado para iOS. '
          'Rode: flutterfire configure',
        );
      default:
        throw UnsupportedError(
          'Plataforma não suportada.',
        );
    }
  }

  // ⚠️ Substitua pelos valores reais APENAS localmente.
  // Nunca faça commit com a apiKey preenchida.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment('FIREBASE_SENDER_ID', defaultValue: ''),
    projectId: 'tot-pi',
    authDomain: 'tot-pi.firebaseapp.com',
    storageBucket: 'tot-pi.firebasestorage.app',
  );
}
