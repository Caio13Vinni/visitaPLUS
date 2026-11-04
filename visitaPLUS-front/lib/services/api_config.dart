import 'package:flutter/foundation.dart';

/// Configuração de acesso à API Visita+ (visitaPLUS-backend).
///
/// A URL base pode ser sobrescrita em tempo de compilação:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080/api/v1`
class ApiConfig {
  ApiConfig._();

  static const String _definida = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_definida.isNotEmpty) return _definida;
    // O emulador Android enxerga o host da máquina pelo IP 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    return 'http://localhost:8080/api/v1';
  }
}
