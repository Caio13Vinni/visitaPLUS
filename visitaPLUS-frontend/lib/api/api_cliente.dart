// =============================================================================
// Cliente HTTP base da API Visita+ (backend Rust/Axum).
// -----------------------------------------------------------------------------
// Centraliza a URL base, o cabecalho Authorization (Bearer JWT) e a
// conversao do erro padrao da API ({ "mensagem": "..." }) em ExcecaoApi.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'sessao.dart';

/// Erro devolvido pela API (ou de conexao com ela).
class ExcecaoApi implements Exception {
  ExcecaoApi(this.mensagem, {this.status});

  /// Codigo HTTP da resposta (nulo quando a falha e de conexao).
  final int? status;
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Cliente HTTP da API Visita+.
class ApiCliente {
  ApiCliente({String? urlBase}) : urlBase = urlBase ?? _urlPadrao();

  /// URL base do servidor (sem o prefixo /api/v1).
  final String urlBase;

  final http.Client _http = http.Client();

  /// Instancia compartilhada usada por todos os servicos.
  static final ApiCliente instancia = ApiCliente();

  /// Resolve a URL padrao conforme a plataforma:
  /// - emulador Android acessa o host por 10.0.2.2;
  /// - demais alvos usam localhost.
  /// Pode ser sobrescrita com `--dart-define=API_URL=http://192.168.x.x:8080`.
  static String _urlPadrao() {
    const definida = String.fromEnvironment('API_URL');
    if (definida.isNotEmpty) return definida;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  Uri _uri(String caminho, [Map<String, String?>? query]) {
    final parametros = <String, String>{};
    query?.forEach((chave, valor) {
      if (valor != null && valor.isNotEmpty) parametros[chave] = valor;
    });
    return Uri.parse('$urlBase/api/v1$caminho')
        .replace(queryParameters: parametros.isEmpty ? null : parametros);
  }

  Map<String, String> get _cabecalhos {
    final token = Sessao.token;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String caminho, {Map<String, String?>? query}) =>
      _executar(() => _http.get(_uri(caminho, query), headers: _cabecalhos));

  Future<dynamic> post(String caminho, {Object? corpo}) => _executar(
    () => _http.post(
      _uri(caminho),
      headers: _cabecalhos,
      body: corpo == null ? null : jsonEncode(corpo),
    ),
  );

  Future<dynamic> patch(String caminho, {Object? corpo}) => _executar(
    () => _http.patch(
      _uri(caminho),
      headers: _cabecalhos,
      body: corpo == null ? null : jsonEncode(corpo),
    ),
  );

  Future<dynamic> _executar(Future<http.Response> Function() requisicao) async {
    final http.Response resposta;
    try {
      resposta = await requisicao();
    } catch (_) {
      throw ExcecaoApi(
        'Nao foi possivel conectar ao servidor. '
        'Verifique se a API esta rodando em $urlBase.',
      );
    }

    final corpo = resposta.body.isEmpty ? null : jsonDecode(resposta.body);

    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return corpo;
    }

    final mensagem = corpo is Map<String, dynamic>
        ? (corpo['mensagem'] as String? ?? 'Erro inesperado.')
        : 'Erro inesperado.';
    throw ExcecaoApi(mensagem, status: resposta.statusCode);
  }
}
