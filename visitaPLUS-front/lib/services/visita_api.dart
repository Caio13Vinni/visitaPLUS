import 'api_cliente.dart';
import 'modelos.dart';
import 'sessao.dart';

/// Fachada de alto nível com os endpoints da API Visita+.
///
/// Cada método corresponde a uma rota do contrato (API.md do backend).
class VisitaApi {
  VisitaApi._();

  // ------------------------------------------------------------------
  // Autenticação (/api/v1/auth)
  // ------------------------------------------------------------------

  /// POST /auth/login — devolve o usuário autenticado e abre a sessão local.
  static Future<Usuario> login({
    required String email,
    required String senha,
  }) async {
    final resposta = await ApiCliente.post('/auth/login', corpo: {
      'email': email,
      'senha': senha,
    }) as Map<String, dynamic>;

    final usuario = Usuario.fromJson(resposta['usuario'] as Map<String, dynamic>);
    Sessao.instancia.iniciar(
      token: resposta['token'] as String,
      usuario: usuario,
      exigeTrocaSenha: resposta['exige_troca_senha'] as bool? ?? false,
    );
    return usuario;
  }

  /// POST /auth/logout — encerra a sessão no servidor e limpa localmente.
  static Future<void> logout() async {
    try {
      await ApiCliente.post('/auth/logout');
    } finally {
      Sessao.instancia.encerrar();
    }
  }

  /// POST /auth/trocar-senha (RN03 — troca obrigatória no primeiro acesso).
  static Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    await ApiCliente.post('/auth/trocar-senha', corpo: {
      'senha_atual': senhaAtual,
      'nova_senha': novaSenha,
    });
    Sessao.instancia.exigeTrocaSenha = false;
  }

  /// POST /auth/recuperar-senha — resposta genérica, não revela se a conta existe.
  static Future<String> recuperarSenha({required String email}) async {
    final resposta = await ApiCliente.post('/auth/recuperar-senha', corpo: {
      'email': email,
    }) as Map<String, dynamic>;
    return resposta['mensagem'] as String? ??
        'Se o e-mail estiver cadastrado, você receberá as orientações.';
  }

  /// POST /auth/recuperar-senha/redefinir — redefine a senha com o código recebido.
  static Future<void> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    await ApiCliente.post('/auth/recuperar-senha/redefinir', corpo: {
      'email': email,
      'codigo': codigo,
      'nova_senha': novaSenha,
    });
  }

  // ------------------------------------------------------------------
  // Profissionais (/api/v1/profissionais) — Coordenador
  // ------------------------------------------------------------------

  static Future<List<Usuario>> listarProfissionais({String? idUnidade}) async {
    final resposta = await ApiCliente.get('/profissionais', query: {
      if (idUnidade != null) 'id_unidade': idUnidade,
    }) as List<dynamic>;
    return resposta
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Usuario> cadastrarProfissional({
    required String idUnidade,
    required String nome,
    required String email,
    required String senha,
    required String perfil,
  }) async {
    final resposta = await ApiCliente.post('/profissionais', corpo: {
      'id_unidade': idUnidade,
      'nome': nome,
      'email': email,
      'senha': senha,
      'perfil': perfil,
    }) as Map<String, dynamic>;
    return Usuario.fromJson(resposta);
  }

  static Future<Usuario> alterarProfissional(
    String id, {
    required String nome,
    required String perfil,
  }) async {
    final resposta = await ApiCliente.patch('/profissionais/$id', corpo: {
      'nome': nome,
      'perfil': perfil,
    }) as Map<String, dynamic>;
    return Usuario.fromJson(resposta);
  }

  static Future<Usuario> alterarStatusProfissional(
      String id, String status) async {
    final resposta = await ApiCliente.patch('/profissionais/$id/status', corpo: {
      'status': status,
    }) as Map<String, dynamic>;
    return Usuario.fromJson(resposta);
  }

  // ------------------------------------------------------------------
  // Famílias (/api/v1/familias)
  // ------------------------------------------------------------------

  static Future<List<Familia>> listarFamilias({
    String? idUnidade,
    String? status,
  }) async {
    final resposta = await ApiCliente.get('/familias', query: {
      if (idUnidade != null) 'id_unidade': idUnidade,
      if (status != null) 'status': status,
    }) as List<dynamic>;
    return resposta
        .map((e) => Familia.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Familia> cadastrarFamilia({
    required String idUnidade,
    required String codigo,
    required String nomeReferencia,
    required String contato,
    required String endereco,
  }) async {
    final resposta = await ApiCliente.post(
      '/familias?id_unidade=$idUnidade',
      corpo: {
        'codigo': codigo,
        'nome_referencia': nomeReferencia,
        'contato': contato,
        'endereco': endereco,
      },
    ) as Map<String, dynamic>;
    return Familia.fromJson(resposta);
  }

  static Future<Familia> alterarFamilia(
    String id, {
    required String codigo,
    required String nomeReferencia,
    required String contato,
    required String endereco,
  }) async {
    final resposta = await ApiCliente.patch('/familias/$id', corpo: {
      'codigo': codigo,
      'nome_referencia': nomeReferencia,
      'contato': contato,
      'endereco': endereco,
    }) as Map<String, dynamic>;
    return Familia.fromJson(resposta);
  }

  static Future<Familia> alterarStatusFamilia(String id, String status) async {
    final resposta = await ApiCliente.patch('/familias/$id/status', corpo: {
      'status': status,
    }) as Map<String, dynamic>;
    return Familia.fromJson(resposta);
  }

  // ------------------------------------------------------------------
  // Visitas (/api/v1/visitas)
  // ------------------------------------------------------------------

  static Future<List<Visita>> listarVisitas({
    String? idTecnico,
    String? idFamilia,
    String? idUnidade,
    String? status,
    String? dataInicio,
    String? dataFim,
  }) async {
    final resposta = await ApiCliente.get('/visitas', query: {
      if (idTecnico != null) 'id_tecnico': idTecnico,
      if (idFamilia != null) 'id_familia': idFamilia,
      if (idUnidade != null) 'id_unidade': idUnidade,
      if (status != null) 'status': status,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
    }) as List<dynamic>;
    return resposta
        .map((e) => Visita.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /visitas/{id} — único ponto em que `familia` vem preenchido (RF12).
  static Future<Visita> obterVisita(String id) async {
    final resposta =
        await ApiCliente.get('/visitas/$id') as Map<String, dynamic>;
    return Visita.fromJson(resposta);
  }

  static Future<Visita> agendarVisita({
    required String idFamilia,
    required String idTecnico,
    required String dataVisita, // "AAAA-MM-DD"
    required String horario, // "HH:MM:SS"
    required String prioridade,
    required String objetivo,
  }) async {
    final resposta = await ApiCliente.post('/visitas', corpo: {
      'id_familia': idFamilia,
      'id_tecnico': idTecnico,
      'data_visita': dataVisita,
      'horario': horario,
      'prioridade': prioridade,
      'objetivo': objetivo,
    }) as Map<String, dynamic>;
    return Visita.fromJson(resposta);
  }

  static Future<Visita> reagendarVisita(
    String id, {
    required String dataVisita,
    required String horario,
    String? idTecnico,
  }) async {
    final resposta = await ApiCliente.patch('/visitas/$id', corpo: {
      'data_visita': dataVisita,
      'horario': horario,
      if (idTecnico != null) 'id_tecnico': idTecnico,
    }) as Map<String, dynamic>;
    return Visita.fromJson(resposta);
  }

  static Future<Visita> cancelarVisita(String id, String motivo) async {
    final resposta = await ApiCliente.patch('/visitas/$id/cancelar', corpo: {
      'motivo': motivo,
    }) as Map<String, dynamic>;
    return Visita.fromJson(resposta);
  }

  // ------------------------------------------------------------------
  // Registros da visita (/api/v1/registros)
  // ------------------------------------------------------------------

  static Future<RegistroVisita> iniciarRegistro(String idVisita) async {
    final resposta = await ApiCliente.post('/registros', corpo: {
      'id_visita': idVisita,
    }) as Map<String, dynamic>;
    return RegistroVisita.fromJson(resposta);
  }

  static Future<RegistroVisita> obterRegistroDaVisita(String idVisita) async {
    final resposta = await ApiCliente.get('/registros/visita/$idVisita')
        as Map<String, dynamic>;
    return RegistroVisita.fromJson(resposta);
  }

  static Future<RegistroVisita> salvarRascunho(
    String id, {
    String? resultado,
    String? descricao,
    String? desfecho,
    bool? necessitaRetorno,
    String? motivoNaoRealizada,
  }) async {
    final resposta = await ApiCliente.patch('/registros/$id', corpo: {
      if (resultado != null) 'resultado': resultado,
      if (descricao != null) 'descricao': descricao,
      if (desfecho != null) 'desfecho': desfecho,
      if (necessitaRetorno != null) 'necessita_retorno': necessitaRetorno,
      if (motivoNaoRealizada != null)
        'motivo_nao_realizada': motivoNaoRealizada,
    }) as Map<String, dynamic>;
    return RegistroVisita.fromJson(resposta);
  }

  static Future<RegistroVisita> finalizarRegistro(
    String id, {
    String? resultado,
    String? descricao,
    String? desfecho,
    bool? necessitaRetorno,
    String? motivoNaoRealizada,
  }) async {
    final resposta = await ApiCliente.post('/registros/$id/finalizar', corpo: {
      if (resultado != null) 'resultado': resultado,
      if (descricao != null) 'descricao': descricao,
      if (desfecho != null) 'desfecho': desfecho,
      if (necessitaRetorno != null) 'necessita_retorno': necessitaRetorno,
      if (motivoNaoRealizada != null)
        'motivo_nao_realizada': motivoNaoRealizada,
    }) as Map<String, dynamic>;
    return RegistroVisita.fromJson(resposta);
  }

  // ------------------------------------------------------------------
  // Solicitações de retorno (/api/v1/solicitacoes-retorno)
  // ------------------------------------------------------------------

  static Future<List<SolicitacaoRetorno>> listarSolicitacoes({
    String? status,
  }) async {
    final resposta = await ApiCliente.get('/solicitacoes-retorno', query: {
      if (status != null) 'status': status,
    }) as List<dynamic>;
    return resposta
        .map((e) => SolicitacaoRetorno.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<SolicitacaoRetorno> solicitarRetorno({
    required String idVisita,
    required String motivo,
    required String prioridade,
  }) async {
    final resposta = await ApiCliente.post('/solicitacoes-retorno', corpo: {
      'id_visita': idVisita,
      'motivo': motivo,
      'prioridade': prioridade,
    }) as Map<String, dynamic>;
    return SolicitacaoRetorno.fromJson(resposta);
  }

  // ------------------------------------------------------------------
  // Notificações (/api/v1/notificacoes)
  // ------------------------------------------------------------------

  static Future<List<Notificacao>> listarNotificacoes({
    bool somenteNaoLidas = false,
  }) async {
    final resposta = await ApiCliente.get('/notificacoes', query: {
      if (somenteNaoLidas) 'somente_nao_lidas': 'true',
    }) as List<dynamic>;
    return resposta
        .map((e) => Notificacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Notificacao> abrirNotificacao(String id) async {
    final resposta = await ApiCliente.patch('/notificacoes/$id/abrir')
        as Map<String, dynamic>;
    return Notificacao.fromJson(resposta);
  }

  // ------------------------------------------------------------------
  // Indicadores (/api/v1/indicadores) — Coordenador
  // ------------------------------------------------------------------

  static Future<Indicadores> obterIndicadores({
    String? dataInicio,
    String? dataFim,
  }) async {
    final resposta = await ApiCliente.get('/indicadores', query: {
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
    }) as Map<String, dynamic>;
    return Indicadores.fromJson(resposta);
  }

  // ------------------------------------------------------------------
  // Histórico (/api/v1/historico)
  // ------------------------------------------------------------------

  static Future<List<Visita>> listarHistorico({
    String? idFamilia,
    String? status,
    String? dataInicio,
    String? dataFim,
  }) async {
    final resposta = await ApiCliente.get('/historico', query: {
      if (idFamilia != null) 'id_familia': idFamilia,
      if (status != null) 'status': status,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
    }) as List<dynamic>;
    return resposta
        .map((e) => Visita.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ------------------------------------------------------------------
  // Encaminhamentos (/api/v1/encaminhamentos)
  // ------------------------------------------------------------------

  static Future<List<Encaminhamento>> listarEncaminhamentos(
      String idVisita) async {
    final resposta = await ApiCliente.get('/encaminhamentos', query: {
      'id_visita': idVisita,
    }) as List<dynamic>;
    return resposta
        .map((e) => Encaminhamento.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Encaminhamento> registrarEncaminhamento({
    required String idVisita,
    required String destino,
    required String motivo,
  }) async {
    final resposta = await ApiCliente.post('/encaminhamentos', corpo: {
      'id_visita': idVisita,
      'destino': destino,
      'motivo': motivo,
    }) as Map<String, dynamic>;
    return Encaminhamento.fromJson(resposta);
  }
}
