import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_excecao.dart';
import 'sessao.dart';

/// Cliente HTTP de baixo nível para a API Visita+.
///
/// - Prefixa todas as chamadas com `ApiConfig.baseUrl`.
/// - Injeta `Authorization: Bearer <token>` quando há sessão ativa.
/// - Converte erros do backend (`{"mensagem": ...}`) em [ApiExcecao].
/// - Em qualquer 401, encerra a sessão local e avisa a UI para
///   voltar à tela de login.
class ApiCliente {
  ApiCliente._();

  static final http.Client _http = http.Client();

  static Map<String, String> _cabecalhos() {
    final cabecalhos = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    final token = Sessao.instancia.token;
    if (token != null) {
      cabecalhos[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return cabecalhos;
  }

  static Uri _uri(String caminho, [Map<String, String>? query]) {
    final base = ApiConfig.baseUrl;
    return Uri.parse('$base$caminho')
        .replace(queryParameters: query == null || query.isEmpty ? null : query);
  }

  static Future<dynamic> get(String caminho,
          {Map<String, String>? query}) =>
      _executar(() => _http.get(_uri(caminho, query), headers: _cabecalhos()));

  static Future<dynamic> post(String caminho, {Object? corpo}) => _executar(
      () => _http.post(_uri(caminho),
          headers: _cabecalhos(), body: corpo == null ? null : jsonEncode(corpo)));

  static Future<dynamic> patch(String caminho, {Object? corpo}) => _executar(
      () => _http.patch(_uri(caminho),
          headers: _cabecalhos(), body: corpo == null ? null : jsonEncode(corpo)));

  static Future<dynamic> _executar(
      Future<http.Response> Function() requisicao) async {
    final http.Response resposta;
    try {
      resposta = await requisicao().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ApiExcecao(
          0, 'O servidor demorou para responder. Tente novamente.');
    } on SocketException {
      throw const ApiExcecao(
          0, 'Sem conexão com o servidor. Verifique sua rede.');
    } on http.ClientException {
      throw const ApiExcecao(
          0, 'Sem conexão com o servidor. Verifique sua rede.');
    }

    if (resposta.statusCode == 401) {
      Sessao.instancia.expirar();
      throw ApiExcecao(401, _mensagemDe(resposta) ??
          'Sessão expirada. Entre novamente.');
    }

    if (resposta.statusCode >= 400) {
      throw ApiExcecao(resposta.statusCode,
          _mensagemDe(resposta) ?? 'Erro inesperado (${resposta.statusCode}).');
    }

    // 204 No Content e afins não têm corpo.
    if (resposta.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  /// Extrai `{"mensagem": "..."}` do corpo de erro do backend.
  static String? _mensagemDe(http.Response resposta) {
    try {
      final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (corpo is Map<String, dynamic> && corpo['mensagem'] is String) {
        return corpo['mensagem'] as String;
      }
    } catch (_) {
      // Corpo não é JSON — cai no fallback do chamador.
    }
    return null;
  }
}
