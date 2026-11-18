// =============================================================================
// Sessao do usuario autenticado — token JWT e dados publicos do usuario.
// -----------------------------------------------------------------------------
// O token e devolvido por POST /api/v1/auth/login e enviado no cabecalho
// Authorization: Bearer ... em todas as rotas protegidas.
// =============================================================================

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'modelos.dart';

class Sessao {
  Sessao._();

  static const _chaveToken = 'visita_token';
  static const _chaveUsuario = 'visita_usuario';

  static String? token;
  static Usuario? usuario;

  static bool get autenticado => token != null;

  static bool get ehCoordenador => usuario?.perfil == PerfilUsuario.coordenador;

  /// Restaura a sessao persistida (chamado na abertura do app).
  static Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_chaveToken);
    final dados = prefs.getString(_chaveUsuario);
    if (dados != null) {
      try {
        usuario = Usuario.fromJson(jsonDecode(dados) as Map<String, dynamic>);
      } catch (_) {
        usuario = null;
      }
    }
  }

  /// Registra a sessao apos o login e a persiste no aparelho.
  static Future<void> entrar(String novoToken, Usuario novoUsuario) async {
    token = novoToken;
    usuario = novoUsuario;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveToken, novoToken);
    await prefs.setString(_chaveUsuario, jsonEncode(novoUsuario.toJson()));
  }

  /// Encerra a sessao local (combine com AutenticacaoApi.logout).
  static Future<void> sair() async {
    token = null;
    usuario = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveToken);
    await prefs.remove(_chaveUsuario);
  }
}
