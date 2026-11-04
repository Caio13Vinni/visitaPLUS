/// Erro devolvido pela API Visita+.
///
/// Todo erro de domínio do backend chega como `{"mensagem": "<texto>"}`
/// com o status HTTP correspondente (ver API.md do backend).
class ApiExcecao implements Exception {
  final int statusCode;
  final String mensagem;

  const ApiExcecao(this.statusCode, this.mensagem);

  bool get sessaoExpirada => statusCode == 401;

  @override
  String toString() => mensagem;
}
