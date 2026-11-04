import 'package:flutter/foundation.dart';

import 'modelos.dart';

/// Sessão autenticada do app (token JWT + usuário logado).
///
/// O backend encerra a sessão no logout e rejeita tokens de sessões
/// encerradas com 401 — por isso o app descarta o token no logout e
/// trata qualquer 401 como "voltar para o login" (ver API.md §2).
class Sessao extends ChangeNotifier {
  Sessao._();

  static final Sessao instancia = Sessao._();

  String? token;
  Usuario? usuario;
  bool exigeTrocaSenha = false;

  /// Chamado quando a API responde 401 (token/sessão mortos).
  /// A tela raiz registra um callback para voltar ao login.
  VoidCallback? aoExpirar;

  bool get autenticado => token != null && usuario != null;

  void iniciar({
    required String token,
    required Usuario usuario,
    required bool exigeTrocaSenha,
  }) {
    this.token = token;
    this.usuario = usuario;
    this.exigeTrocaSenha = exigeTrocaSenha;
    notifyListeners();
  }

  void encerrar() {
    token = null;
    usuario = null;
    exigeTrocaSenha = false;
    notifyListeners();
  }

  /// Sessão morreu no servidor (401): limpa local e avisa a UI.
  void expirar() {
    if (!autenticado) return;
    encerrar();
    aoExpirar?.call();
  }
}
