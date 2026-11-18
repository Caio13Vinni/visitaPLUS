// =============================================================================
// Servicos da API Visita+ — um arquivo por modulo do backend.
// As rotas abaixo espelham visitaPLUS-backend/src/interface/api/rotas.rs.
// =============================================================================

import '../api_cliente.dart';
import '../modelos.dart';
import '../sessao.dart';

List<T> _lista<T>(dynamic corpo, T Function(Map<String, dynamic>) ler) =>
    (corpo as List<dynamic>)
        .map((item) => ler(item as Map<String, dynamic>))
        .toList();

String _data(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}-'
    '${data.month.toString().padLeft(2, '0')}-'
    '${data.day.toString().padLeft(2, '0')}';

String _hora(DateTime hora) =>
    '${hora.hour.toString().padLeft(2, '0')}:'
    '${hora.minute.toString().padLeft(2, '0')}:00';

// ---------------------------------------------------------------------------
// UC01 — /auth
// ---------------------------------------------------------------------------

class AutenticacaoApi {
  static final _api = ApiCliente.instancia;

  /// POST /auth/login — autentica e ja registra a sessao local.
  static Future<RespostaLogin> login(String email, String senha) async {
    final corpo = await _api.post(
      '/auth/login',
      corpo: {'email': email, 'senha': senha},
    );
    final resposta = RespostaLogin.fromJson(corpo as Map<String, dynamic>);
    await Sessao.entrar(resposta.token, resposta.usuario);
    return resposta;
  }

  /// POST /auth/trocar-senha — troca de senha (primeiro acesso).
  static Future<void> trocarSenha(String senhaAtual, String novaSenha) =>
      _api.post(
        '/auth/trocar-senha',
        corpo: {'senha_atual': senhaAtual, 'nova_senha': novaSenha},
      );

  /// POST /auth/recuperar-senha — solicita o codigo (RF03, anonimo).
  /// A resposta e sempre generica e nao revela se a conta existe.
  static Future<String> recuperarSenha(String email) async {
    final corpo = await _api.post(
      '/auth/recuperar-senha',
      corpo: {'email': email},
    );
    return (corpo as Map<String, dynamic>)['mensagem'] as String? ??
        'Se o e-mail estiver cadastrado, voce recebera um codigo.';
  }

  /// POST /auth/recuperar-senha/redefinir — redefine a senha (RF03, anonimo).
  static Future<void> redefinirSenha(
    String email,
    String codigo,
    String novaSenha,
  ) => _api.post(
    '/auth/recuperar-senha/redefinir',
    corpo: {'email': email, 'codigo': codigo, 'nova_senha': novaSenha},
  );

  /// POST /auth/logout — encerra a sessao atual (RF04) e limpa o aparelho.
  static Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      await Sessao.sair();
    }
  }
}

// ---------------------------------------------------------------------------
// UC02 — /profissionais (somente Coordenador)
// ---------------------------------------------------------------------------

class ProfissionaisApi {
  static final _api = ApiCliente.instancia;

  /// GET /profissionais — lista os profissionais.
  static Future<List<Usuario>> listar({String? idUnidade}) async {
    final corpo = await _api.get(
      '/profissionais/',
      query: {'id_unidade': idUnidade},
    );
    return _lista(corpo, Usuario.fromJson);
  }

  /// POST /profissionais — cadastra um novo profissional.
  static Future<Usuario> cadastrar({
    required String idUnidade,
    required String nome,
    required String email,
    required String senha,
    required String perfil,
  }) async {
    final corpo = await _api.post(
      '/profissionais/',
      corpo: {
        'id_unidade': idUnidade,
        'nome': nome,
        'email': email,
        'senha': senha,
        'perfil': perfil,
      },
    );
    return Usuario.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /profissionais/{id} — edita nome e perfil.
  static Future<Usuario> editar(
    String id, {
    required String nome,
    required String perfil,
  }) async {
    final corpo = await _api.patch(
      '/profissionais/$id',
      corpo: {'nome': nome, 'perfil': perfil},
    );
    return Usuario.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /profissionais/{id}/status — ativa/inativa a conta (RN04).
  static Future<Usuario> alterarStatus(String id, String status) async {
    final corpo = await _api.patch(
      '/profissionais/$id/status',
      corpo: {'status': status},
    );
    return Usuario.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// UC03 — /familias
// ---------------------------------------------------------------------------

class FamiliasApi {
  static final _api = ApiCliente.instancia;

  /// GET /familias — lista as familias (coordenador e tecnico).
  static Future<List<Familia>> listar({
    String? idUnidade,
    String? status,
  }) async {
    final corpo = await _api.get(
      '/familias/',
      query: {'id_unidade': idUnidade, 'status': status},
    );
    return _lista(corpo, Familia.fromJson);
  }

  /// POST /familias — cadastra uma nova familia (Coordenador).
  static Future<Familia> cadastrar({
    required String codigo,
    required String nomeReferencia,
    required String contato,
    required String endereco,
  }) async {
    final corpo = await _api.post(
      '/familias/',
      corpo: {
        'codigo': codigo,
        'nome_referencia': nomeReferencia,
        'contato': contato,
        'endereco': endereco,
      },
    );
    return Familia.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /familias/{id} — edita os dados da familia.
  static Future<Familia> editar(
    String id, {
    required String codigo,
    required String nomeReferencia,
    required String contato,
    required String endereco,
  }) async {
    final corpo = await _api.patch(
      '/familias/$id',
      corpo: {
        'codigo': codigo,
        'nome_referencia': nomeReferencia,
        'contato': contato,
        'endereco': endereco,
      },
    );
    return Familia.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /familias/{id}/status — ativa/inativa o cadastro.
  static Future<Familia> alterarStatus(String id, String status) async {
    final corpo = await _api.patch(
      '/familias/$id/status',
      corpo: {'status': status},
    );
    return Familia.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// UC04 — /visitas
// ---------------------------------------------------------------------------

class VisitasApi {
  static final _api = ApiCliente.instancia;

  /// GET /visitas — lista as visitas conforme o perfil, com filtros.
  static Future<List<Visita>> listar({
    String? idTecnico,
    String? idFamilia,
    String? idUnidade,
    String? status,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final corpo = await _api.get(
      '/visitas/',
      query: {
        'id_tecnico': idTecnico,
        'id_familia': idFamilia,
        'id_unidade': idUnidade,
        'status': status,
        'data_inicio': dataInicio == null ? null : _data(dataInicio),
        'data_fim': dataFim == null ? null : _data(dataFim),
      },
    );
    return _lista(corpo, Visita.fromJson);
  }

  /// GET /visitas/{id} — detalha a visita (RF12, inclui a familia).
  static Future<Visita> detalhar(String id) async {
    final corpo = await _api.get('/visitas/$id');
    return Visita.fromJson(corpo as Map<String, dynamic>);
  }

  /// POST /visitas — agenda uma nova visita (Coordenador).
  static Future<Visita> agendar({
    required String idFamilia,
    required String idTecnico,
    required DateTime dataVisita,
    required DateTime horario,
    required String prioridade,
    required String objetivo,
  }) async {
    final corpo = await _api.post(
      '/visitas/',
      corpo: {
        'id_familia': idFamilia,
        'id_tecnico': idTecnico,
        'data_visita': _data(dataVisita),
        'horario': _hora(horario),
        'prioridade': prioridade,
        'objetivo': objetivo,
      },
    );
    return Visita.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /visitas/{id} — reagenda a visita (RN18: apenas Agendada).
  static Future<Visita> reagendar(
    String id, {
    required DateTime dataVisita,
    required DateTime horario,
    String? idTecnico,
  }) async {
    final corpo = await _api.patch(
      '/visitas/$id',
      corpo: {
        'data_visita': _data(dataVisita),
        'horario': _hora(horario),
        if (idTecnico != null) 'id_tecnico': idTecnico,
      },
    );
    return Visita.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /visitas/{id}/cancelar — cancela o agendamento (RN18).
  static Future<Visita> cancelar(String id, String motivo) async {
    final corpo = await _api.patch(
      '/visitas/$id/cancelar',
      corpo: {'motivo': motivo},
    );
    return Visita.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// UC05 — /registros
// ---------------------------------------------------------------------------

class RegistrosApi {
  static final _api = ApiCliente.instancia;

  /// POST /registros — inicia a visita (status Em andamento).
  static Future<RegistroVisita> iniciar(String idVisita) async {
    final corpo = await _api.post('/registros/', corpo: {'id_visita': idVisita});
    return RegistroVisita.fromJson(corpo as Map<String, dynamic>);
  }

  /// GET /registros/visita/{idVisita} — registro vinculado a visita.
  static Future<RegistroVisita> detalharPorVisita(String idVisita) async {
    final corpo = await _api.get('/registros/visita/$idVisita');
    return RegistroVisita.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /registros/{id} — salva o rascunho (RN12).
  static Future<RegistroVisita> salvarRascunho(
    String id, {
    String? resultado,
    String? descricao,
    String? desfecho,
    bool necessitaRetorno = false,
    String? motivoNaoRealizada,
  }) => _salvar(
    id,
    '/registros/$id',
    resultado: resultado,
    descricao: descricao,
    desfecho: desfecho,
    necessitaRetorno: necessitaRetorno,
    motivoNaoRealizada: motivoNaoRealizada,
  );

  /// POST /registros/{id}/finalizar — fecha o registro (RN16, imutavel).
  static Future<RegistroVisita> finalizar(
    String id, {
    String? resultado,
    String? descricao,
    String? desfecho,
    bool necessitaRetorno = false,
    String? motivoNaoRealizada,
  }) => _salvar(
    id,
    '/registros/$id/finalizar',
    resultado: resultado,
    descricao: descricao,
    desfecho: desfecho,
    necessitaRetorno: necessitaRetorno,
    motivoNaoRealizada: motivoNaoRealizada,
    metodo: _api.post,
  );

  static Future<RegistroVisita> _salvar(
    String id,
    String caminho, {
    String? resultado,
    String? descricao,
    String? desfecho,
    bool necessitaRetorno = false,
    String? motivoNaoRealizada,
    Future<dynamic> Function(String, {Object? corpo})? metodo,
  }) async {
    final corpo = await (metodo ?? _api.patch)(
      caminho,
      corpo: {
        if (resultado != null) 'resultado': resultado,
        if (descricao != null) 'descricao': descricao,
        if (desfecho != null) 'desfecho': desfecho,
        'necessita_retorno': necessitaRetorno,
        if (motivoNaoRealizada != null)
          'motivo_nao_realizada': motivoNaoRealizada,
      },
    );
    return RegistroVisita.fromJson(corpo as Map<String, dynamic>);
  }

  /// GET /registros/{id}/complementos — lista os complementos (RN17).
  static Future<List<Complemento>> listarComplementos(String id) async {
    final corpo = await _api.get('/registros/$id/complementos');
    return _lista(corpo, Complemento.fromJson);
  }

  /// POST /registros/{id}/complementos — adiciona complemento (RN17).
  static Future<Complemento> adicionarComplemento(
    String id, {
    required String descricao,
    required String motivo,
  }) async {
    final corpo = await _api.post(
      '/registros/$id/complementos',
      corpo: {'descricao': descricao, 'motivo': motivo},
    );
    return Complemento.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// UC08 — /solicitacoes-retorno
// ---------------------------------------------------------------------------

class SolicitacoesApi {
  static final _api = ApiCliente.instancia;

  /// GET /solicitacoes-retorno — lista os pedidos (filtro por status).
  static Future<List<SolicitacaoRetorno>> listar({String? status}) async {
    final corpo = await _api.get(
      '/solicitacoes-retorno/',
      query: {'status': status},
    );
    return _lista(corpo, SolicitacaoRetorno.fromJson);
  }

  /// POST /solicitacoes-retorno — pede o retorno de uma visita (RN19).
  static Future<SolicitacaoRetorno> solicitar({
    required String idVisita,
    required String motivo,
    required String prioridade,
  }) async {
    final corpo = await _api.post(
      '/solicitacoes-retorno/',
      corpo: {
        'id_visita': idVisita,
        'motivo': motivo,
        'prioridade': prioridade,
      },
    );
    return SolicitacaoRetorno.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /solicitacoes-retorno/{id}/aprovar — aprova e agenda o retorno.
  static Future<RespostaAprovacao> aprovar(
    String id, {
    required String idTecnico,
    required DateTime dataVisita,
    required DateTime horario,
  }) async {
    final corpo = await _api.patch(
      '/solicitacoes-retorno/$id/aprovar',
      corpo: {
        'id_tecnico': idTecnico,
        'data_visita': _data(dataVisita),
        'horario': _hora(horario),
      },
    );
    return RespostaAprovacao.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /solicitacoes-retorno/{id}/rejeitar — rejeita com justificativa.
  static Future<SolicitacaoRetorno> rejeitar(
    String id,
    String justificativa,
  ) async {
    final corpo = await _api.patch(
      '/solicitacoes-retorno/$id/rejeitar',
      corpo: {'justificativa': justificativa},
    );
    return SolicitacaoRetorno.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /solicitacoes-retorno/{id}/cancelar — cancela o pedido (RN20).
  static Future<SolicitacaoRetorno> cancelar(String id) async {
    final corpo = await _api.patch('/solicitacoes-retorno/$id/cancelar');
    return SolicitacaoRetorno.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// UC10 — /notificacoes
// ---------------------------------------------------------------------------

class NotificacoesApi {
  static final _api = ApiCliente.instancia;

  /// GET /notificacoes — lista as notificacoes do usuario autenticado.
  static Future<List<Notificacao>> listar({
    bool somenteNaoLidas = false,
  }) async {
    final corpo = await _api.get(
      '/notificacoes/',
      query: {'somente_nao_lidas': somenteNaoLidas ? 'true' : null},
    );
    return _lista(corpo, Notificacao.fromJson);
  }

  /// PATCH /notificacoes/{id}/abrir — marca a notificacao como lida.
  static Future<Notificacao> abrir(String id) async {
    final corpo = await _api.patch('/notificacoes/$id/abrir');
    return Notificacao.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// UC11 — /indicadores (RN23 — somente Coordenador)
// ---------------------------------------------------------------------------

class IndicadoresApi {
  static final _api = ApiCliente.instancia;

  /// GET /indicadores — consulta os indicadores do periodo (padrao: 30 dias).
  static Future<Indicadores> consultar({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final corpo = await _api.get(
      '/indicadores/',
      query: {
        'data_inicio': dataInicio == null ? null : _data(dataInicio),
        'data_fim': dataFim == null ? null : _data(dataFim),
      },
    );
    return Indicadores.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// UC12 — /auditoria (somente Coordenador)
// ---------------------------------------------------------------------------

class AuditoriaApi {
  static final _api = ApiCliente.instancia;

  /// GET /auditoria — lista os eventos da trilha de auditoria.
  static Future<List<EventoAuditoria>> consultar({
    String? idUsuario,
    String? acao,
    String? entidade,
    String? entidadeId,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final corpo = await _api.get(
      '/auditoria/',
      query: {
        'id_usuario': idUsuario,
        'acao': acao,
        'entidade': entidade,
        'entidade_id': entidadeId,
        'data_inicio': dataInicio?.toUtc().toIso8601String(),
        'data_fim': dataFim?.toUtc().toIso8601String(),
      },
    );
    return _lista(corpo, EventoAuditoria.fromJson);
  }
}

// ---------------------------------------------------------------------------
// /historico
// ---------------------------------------------------------------------------

class HistoricoApi {
  static final _api = ApiCliente.instancia;

  /// GET /historico — lista as visitas do historico (mais recente primeiro).
  static Future<List<Visita>> consultar({
    String? idFamilia,
    String? status,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final corpo = await _api.get(
      '/historico/',
      query: {
        'id_familia': idFamilia,
        'status': status,
        'data_inicio': dataInicio == null ? null : _data(dataInicio),
        'data_fim': dataFim == null ? null : _data(dataFim),
      },
    );
    return _lista(corpo, Visita.fromJson);
  }

  /// GET /historico/{id} — detalhe: visita, registro, complementos, mudancas.
  static Future<DetalheHistorico> detalhar(String id) async {
    final corpo = await _api.get('/historico/$id');
    return DetalheHistorico.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// RF17 — /encaminhamentos
// ---------------------------------------------------------------------------

class EncaminhamentosApi {
  static final _api = ApiCliente.instancia;

  /// GET /encaminhamentos?id_visita= — lista os encaminhamentos da visita.
  static Future<List<Encaminhamento>> listar(String idVisita) async {
    final corpo = await _api.get(
      '/encaminhamentos/',
      query: {'id_visita': idVisita},
    );
    return _lista(corpo, Encaminhamento.fromJson);
  }

  /// POST /encaminhamentos — registra um encaminhamento no atendimento.
  static Future<Encaminhamento> registrar({
    required String idVisita,
    required String destino,
    required String motivo,
  }) async {
    final corpo = await _api.post(
      '/encaminhamentos/',
      corpo: {'id_visita': idVisita, 'destino': destino, 'motivo': motivo},
    );
    return Encaminhamento.fromJson(corpo as Map<String, dynamic>);
  }

  /// PATCH /encaminhamentos/{id}/concluir — conclui o encaminhamento.
  static Future<Encaminhamento> concluir(String id) async {
    final corpo = await _api.patch('/encaminhamentos/$id/concluir');
    return Encaminhamento.fromJson(corpo as Map<String, dynamic>);
  }
}

// ---------------------------------------------------------------------------
// Sincronizacao offline — /sincronizacao
// ---------------------------------------------------------------------------

class SincronizacaoApi {
  static final _api = ApiCliente.instancia;

  /// POST /sincronizacao — sincroniza as pendencias do banco local.
  static Future<RespostaSincronizacao> sincronizar() async {
    final corpo = await _api.post('/sincronizacao/');
    return RespostaSincronizacao.fromJson(corpo as Map<String, dynamic>);
  }

  /// POST /sincronizacao/push — envia pendencias (app mobile).
  static Future<RespostaPush> push(
    List<Map<String, dynamic>> pendencias,
  ) async {
    final corpo = await _api.post(
      '/sincronizacao/push',
      corpo: {'pendencias': pendencias},
    );
    return RespostaPush.fromJson(corpo as Map<String, dynamic>);
  }

  /// GET /sincronizacao/pull — baixa a agenda do perfil.
  static Future<RespostaPull> pull() async {
    final corpo = await _api.get('/sincronizacao/pull');
    return RespostaPull.fromJson(corpo as Map<String, dynamic>);
  }
}
