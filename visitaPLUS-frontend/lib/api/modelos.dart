// =============================================================================
// Modelos (DTOs) da API Visita+ — espelham as structs Resposta*/Requisicao*
// do backend (visitaPLUS-backend/src/interface/api/*/mod.rs).
// Os enums trafegam como texto exatamente como no banco (PascalCase).
// =============================================================================

/// Perfil de acesso (RN02/RN03).
class PerfilUsuario {
  PerfilUsuario._();
  static const coordenador = 'Coordenador';
  static const tecnico = 'Tecnico';
}

/// Status da conta de usuario (RN04).
class StatusUsuario {
  StatusUsuario._();
  static const ativo = 'Ativo';
  static const inativo = 'Inativo';
}

/// Status do cadastro de familia (UC03).
class StatusFamilia {
  StatusFamilia._();
  static const ativa = 'Ativa';
  static const inativa = 'Inativa';
}

/// Prioridade da visita (UC04).
class PrioridadeVisita {
  PrioridadeVisita._();
  static const baixa = 'Baixa';
  static const normal = 'Normal';
  static const alta = 'Alta';
}

/// Status do agendamento da visita (UC04/UC05).
class StatusVisita {
  StatusVisita._();
  static const agendada = 'Agendada';
  static const emAndamento = 'Em andamento';
  static const realizada = 'Realizada';
  static const naoRealizada = 'Não realizada';
  static const cancelada = 'Cancelada';
}

/// Status do registro da visita (RN12).
class StatusRegistro {
  StatusRegistro._();
  static const rascunho = 'Rascunho';
  static const finalizado = 'Finalizado';
}

/// Resultado da tentativa de visita (RN13/RN14).
class ResultadoRegistro {
  ResultadoRegistro._();
  static const realizada = 'Realizada';
  static const naoRealizada = 'Não realizada';
}

/// Status do pedido de retorno (UC08).
class StatusSolicitacao {
  StatusSolicitacao._();
  static const pendente = 'Pendente';
  static const aprovada = 'Aprovada';
  static const rejeitada = 'Rejeitada';
  static const cancelada = 'Cancelada';
  static const agendada = 'Agendada';
}

/// Tipo da notificacao (RN21).
class TipoNotificacao {
  TipoNotificacao._();
  static const lembrete = 'Lembrete';
  static const aviso = 'Aviso';
  static const sistema = 'Sistema';
}

/// Status do encaminhamento (RF17).
class StatusEncaminhamento {
  StatusEncaminhamento._();
  static const aberto = 'Aberto';
  static const concluido = 'Concluído';
}

// ---------------------------------------------------------------------------
// Usuario
// ---------------------------------------------------------------------------

/// Dados publicos do usuario (RespostaUsuario do backend).
class Usuario {
  Usuario({
    required this.id,
    required this.idUnidade,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.status,
  });

  final String id;
  final String idUnidade;
  final String nome;
  final String email;
  final String perfil;
  final String status;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as String,
    idUnidade: json['id_unidade'] as String,
    nome: json['nome'] as String,
    email: json['email'] as String,
    perfil: json['perfil'] as String,
    status: json['status'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_unidade': idUnidade,
    'nome': nome,
    'email': email,
    'perfil': perfil,
    'status': status,
  };
}

/// Resposta do login (token JWT + usuario + flag de troca de senha).
class RespostaLogin {
  RespostaLogin({
    required this.token,
    required this.usuario,
    required this.exigeTrocaSenha,
  });

  final String token;
  final Usuario usuario;
  final bool exigeTrocaSenha;

  factory RespostaLogin.fromJson(Map<String, dynamic> json) => RespostaLogin(
    token: json['token'] as String,
    usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    exigeTrocaSenha: json['exige_troca_senha'] as bool? ?? false,
  );
}

// ---------------------------------------------------------------------------
// Familia
// ---------------------------------------------------------------------------

class Familia {
  Familia({
    required this.id,
    required this.idUnidade,
    required this.codigo,
    required this.nomeReferencia,
    required this.contato,
    required this.endereco,
    required this.status,
  });

  final String id;
  final String idUnidade;
  final String codigo;
  final String nomeReferencia;
  final String contato;
  final String endereco;
  final String status;

  factory Familia.fromJson(Map<String, dynamic> json) => Familia(
    id: json['id'] as String,
    idUnidade: json['id_unidade'] as String,
    codigo: json['codigo'] as String,
    nomeReferencia: json['nome_referencia'] as String,
    contato: json['contato'] as String,
    endereco: json['endereco'] as String,
    status: json['status'] as String,
  );
}

// ---------------------------------------------------------------------------
// Visita
// ---------------------------------------------------------------------------

class Visita {
  Visita({
    required this.id,
    required this.idFamilia,
    required this.idTecnico,
    required this.idAgendadoPor,
    required this.dataVisita,
    required this.horario,
    required this.prioridade,
    required this.objetivo,
    required this.status,
    this.motivoCancelamento,
    this.familia,
  });

  final String id;
  final String idFamilia;
  final String idTecnico;
  final String idAgendadoPor;

  /// Data da visita (yyyy-MM-dd).
  final DateTime dataVisita;

  /// Horario no formato devolvido pela API (HH:mm:ss).
  final String horario;
  final String prioridade;
  final String objetivo;
  final String status;
  final String? motivoCancelamento;

  /// Preenchida apenas no detalhamento (RF12).
  final Familia? familia;

  factory Visita.fromJson(Map<String, dynamic> json) => Visita(
    id: json['id'] as String,
    idFamilia: json['id_familia'] as String,
    idTecnico: json['id_tecnico'] as String,
    idAgendadoPor: json['id_agendado_por'] as String,
    dataVisita: DateTime.parse(json['data_visita'] as String),
    horario: json['horario'] as String,
    prioridade: json['prioridade'] as String,
    objetivo: json['objetivo'] as String,
    status: json['status'] as String,
    motivoCancelamento: json['motivo_cancelamento'] as String?,
    familia: json['familia'] == null
        ? null
        : Familia.fromJson(json['familia'] as Map<String, dynamic>),
  );
}

// ---------------------------------------------------------------------------
// Registro da visita (UC05)
// ---------------------------------------------------------------------------

class RegistroVisita {
  RegistroVisita({
    required this.id,
    required this.idVisita,
    required this.status,
    this.resultado,
    this.descricao,
    this.desfecho,
    required this.necessitaRetorno,
    this.motivoNaoRealizada,
    this.dataHoraInicio,
    this.dataHoraFim,
    required this.registradoPor,
  });

  final String id;
  final String idVisita;
  final String status;
  final String? resultado;
  final String? descricao;
  final String? desfecho;
  final bool necessitaRetorno;
  final String? motivoNaoRealizada;
  final DateTime? dataHoraInicio;
  final DateTime? dataHoraFim;
  final String registradoPor;

  factory RegistroVisita.fromJson(Map<String, dynamic> json) => RegistroVisita(
    id: json['id'] as String,
    idVisita: json['id_visita'] as String,
    status: json['status'] as String,
    resultado: json['resultado'] as String?,
    descricao: json['descricao'] as String?,
    desfecho: json['desfecho'] as String?,
    necessitaRetorno: json['necessita_retorno'] as bool? ?? false,
    motivoNaoRealizada: json['motivo_nao_realizada'] as String?,
    dataHoraInicio: json['data_hora_inicio'] == null
        ? null
        : DateTime.parse(json['data_hora_inicio'] as String),
    dataHoraFim: json['data_hora_fim'] == null
        ? null
        : DateTime.parse(json['data_hora_fim'] as String),
    registradoPor: json['registrado_por'] as String,
  );
}

class Complemento {
  Complemento({
    required this.id,
    required this.idRegistro,
    required this.descricao,
    required this.motivo,
    required this.registradoPor,
  });

  final String id;
  final String idRegistro;
  final String descricao;
  final String motivo;
  final String registradoPor;

  factory Complemento.fromJson(Map<String, dynamic> json) => Complemento(
    id: json['id'] as String,
    idRegistro: json['id_registro'] as String,
    descricao: json['descricao'] as String,
    motivo: json['motivo'] as String,
    registradoPor: json['registrado_por'] as String,
  );
}

// ---------------------------------------------------------------------------
// Solicitacao de retorno (UC08)
// ---------------------------------------------------------------------------

class SolicitacaoRetorno {
  SolicitacaoRetorno({
    required this.id,
    required this.idVisita,
    required this.motivo,
    required this.prioridade,
    required this.solicitadoPor,
    required this.dataSolicitacao,
    required this.status,
    this.decididoPor,
    this.decisaoMotivo,
    this.decididoEm,
  });

  final String id;
  final String idVisita;
  final String motivo;
  final String prioridade;
  final String solicitadoPor;
  final DateTime dataSolicitacao;
  final String status;
  final String? decididoPor;
  final String? decisaoMotivo;
  final DateTime? decididoEm;

  factory SolicitacaoRetorno.fromJson(Map<String, dynamic> json) =>
      SolicitacaoRetorno(
        id: json['id'] as String,
        idVisita: json['id_visita'] as String,
        motivo: json['motivo'] as String,
        prioridade: json['prioridade'] as String,
        solicitadoPor: json['solicitado_por'] as String,
        dataSolicitacao: DateTime.parse(json['data_solicitacao'] as String),
        status: json['status'] as String,
        decididoPor: json['decidido_por'] as String?,
        decisaoMotivo: json['decisao_motivo'] as String?,
        decididoEm: json['decidido_em'] == null
            ? null
            : DateTime.parse(json['decidido_em'] as String),
      );
}

/// Resposta da aprovacao: pedido atualizado + visita de retorno criada.
class RespostaAprovacao {
  RespostaAprovacao({required this.solicitacao, required this.visita});

  final SolicitacaoRetorno solicitacao;
  final Visita visita;

  factory RespostaAprovacao.fromJson(Map<String, dynamic> json) =>
      RespostaAprovacao(
        solicitacao: SolicitacaoRetorno.fromJson(
          json['solicitacao'] as Map<String, dynamic>,
        ),
        visita: Visita.fromJson(json['visita'] as Map<String, dynamic>),
      );
}

// ---------------------------------------------------------------------------
// Notificacao (RN21 — conteudo sempre generico)
// ---------------------------------------------------------------------------

class Notificacao {
  Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.tipo,
    required this.lida,
    this.lidaEm,
    required this.dataHora,
  });

  final String id;
  final String titulo;
  final String mensagem;
  final String tipo;
  final bool lida;
  final DateTime? lidaEm;
  final DateTime dataHora;

  factory Notificacao.fromJson(Map<String, dynamic> json) => Notificacao(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    mensagem: json['mensagem'] as String,
    tipo: json['tipo'] as String,
    lida: json['lida'] as bool? ?? false,
    lidaEm: json['lida_em'] == null
        ? null
        : DateTime.parse(json['lida_em'] as String),
    dataHora: DateTime.parse(json['data_hora'] as String),
  );
}

// ---------------------------------------------------------------------------
// Encaminhamento (RF17)
// ---------------------------------------------------------------------------

class Encaminhamento {
  Encaminhamento({
    required this.id,
    required this.idVisita,
    required this.destino,
    required this.motivo,
    required this.dataEncaminhamento,
    required this.status,
    required this.registradoPor,
  });

  final String id;
  final String idVisita;
  final String destino;
  final String motivo;
  final DateTime dataEncaminhamento;
  final String status;
  final String registradoPor;

  factory Encaminhamento.fromJson(Map<String, dynamic> json) => Encaminhamento(
    id: json['id'] as String,
    idVisita: json['id_visita'] as String,
    destino: json['destino'] as String,
    motivo: json['motivo'] as String,
    dataEncaminhamento: DateTime.parse(json['data_encaminhamento'] as String),
    status: json['status'] as String,
    registradoPor: json['registrado_por'] as String,
  );
}

// ---------------------------------------------------------------------------
// Indicadores (RN23 — apenas quantidades)
// ---------------------------------------------------------------------------

class Indicadores {
  Indicadores({
    required this.periodoInicio,
    required this.periodoFim,
    required this.visitasAgendadas,
    required this.visitasEmAndamento,
    required this.visitasRealizadas,
    required this.visitasNaoRealizadas,
    required this.visitasCanceladas,
    required this.totalVisitas,
    required this.retornosPendentes,
    required this.periodoSemDados,
  });

  final DateTime periodoInicio;
  final DateTime periodoFim;
  final int visitasAgendadas;
  final int visitasEmAndamento;
  final int visitasRealizadas;
  final int visitasNaoRealizadas;
  final int visitasCanceladas;
  final int totalVisitas;
  final int retornosPendentes;
  final bool periodoSemDados;

  factory Indicadores.fromJson(Map<String, dynamic> json) => Indicadores(
    periodoInicio: DateTime.parse(json['periodo_inicio'] as String),
    periodoFim: DateTime.parse(json['periodo_fim'] as String),
    visitasAgendadas: json['visitas_agendadas'] as int? ?? 0,
    visitasEmAndamento: json['visitas_em_andamento'] as int? ?? 0,
    visitasRealizadas: json['visitas_realizadas'] as int? ?? 0,
    visitasNaoRealizadas: json['visitas_nao_realizadas'] as int? ?? 0,
    visitasCanceladas: json['visitas_canceladas'] as int? ?? 0,
    totalVisitas: json['total_visitas'] as int? ?? 0,
    retornosPendentes: json['retornos_pendentes'] as int? ?? 0,
    periodoSemDados: json['periodo_sem_dados'] as bool? ?? false,
  );
}

// ---------------------------------------------------------------------------
// Auditoria e historico
// ---------------------------------------------------------------------------

class EventoAuditoria {
  EventoAuditoria({
    required this.id,
    this.idUsuario,
    required this.entidade,
    required this.entidadeId,
    required this.acao,
    this.descricao,
    required this.dataHora,
  });

  final String id;
  final String? idUsuario;
  final String entidade;
  final String entidadeId;
  final String acao;
  final String? descricao;
  final DateTime dataHora;

  factory EventoAuditoria.fromJson(Map<String, dynamic> json) =>
      EventoAuditoria(
        id: json['id'] as String,
        idUsuario: json['id_usuario'] as String?,
        entidade: json['entidade'] as String,
        entidadeId: json['entidade_id'] as String,
        acao: json['acao'] as String,
        descricao: json['descricao'] as String?,
        dataHora: DateTime.parse(json['data_hora'] as String),
      );
}

/// Mudanca auditada exibida no historico (RN18/RN22).
class MudancaHistorico {
  MudancaHistorico({
    required this.id,
    this.idUsuario,
    required this.acao,
    this.descricao,
    required this.dataHora,
  });

  final String id;
  final String? idUsuario;
  final String acao;
  final String? descricao;
  final DateTime dataHora;

  factory MudancaHistorico.fromJson(Map<String, dynamic> json) =>
      MudancaHistorico(
        id: json['id'] as String,
        idUsuario: json['id_usuario'] as String?,
        acao: json['acao'] as String,
        descricao: json['descricao'] as String?,
        dataHora: DateTime.parse(json['data_hora'] as String),
      );
}

class DetalheHistorico {
  DetalheHistorico({
    required this.visita,
    this.registro,
    required this.complementos,
    required this.mudancas,
  });

  final Visita visita;
  final RegistroVisita? registro;
  final List<Complemento> complementos;
  final List<MudancaHistorico> mudancas;

  factory DetalheHistorico.fromJson(Map<String, dynamic> json) =>
      DetalheHistorico(
        visita: Visita.fromJson(json['visita'] as Map<String, dynamic>),
        registro: json['registro'] == null
            ? null
            : RegistroVisita.fromJson(json['registro'] as Map<String, dynamic>),
        complementos: (json['complementos'] as List<dynamic>? ?? [])
            .map((item) => Complemento.fromJson(item as Map<String, dynamic>))
            .toList(),
        mudancas: (json['mudancas'] as List<dynamic>? ?? [])
            .map(
              (item) => MudancaHistorico.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// Sincronizacao offline
// ---------------------------------------------------------------------------

class RespostaSincronizacao {
  RespostaSincronizacao({
    required this.enviados,
    required this.recebidos,
    required this.erros,
  });

  final int enviados;
  final int recebidos;
  final int erros;

  factory RespostaSincronizacao.fromJson(Map<String, dynamic> json) =>
      RespostaSincronizacao(
        enviados: json['enviados'] as int? ?? 0,
        recebidos: json['recebidos'] as int? ?? 0,
        erros: json['erros'] as int? ?? 0,
      );
}

class RespostaPush {
  RespostaPush({required this.enviados, required this.erros});

  final int enviados;
  final int erros;

  factory RespostaPush.fromJson(Map<String, dynamic> json) =>
      RespostaPush(
        enviados: json['enviados'] as int? ?? 0,
        erros: json['erros'] as int? ?? 0,
      );
}

class RespostaPull {
  RespostaPull({required this.visitas, required this.familias});

  final List<Visita> visitas;
  final List<Familia> familias;

  factory RespostaPull.fromJson(Map<String, dynamic> json) => RespostaPull(
    visitas: (json['visitas'] as List<dynamic>? ?? [])
        .map((item) => Visita.fromJson(item as Map<String, dynamic>))
        .toList(),
    familias: (json['familias'] as List<dynamic>? ?? [])
        .map((item) => Familia.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
