/// Modelos do contrato da API Visita+ (visitaPLUS-backend/API.md).
///
/// Os campos seguem exatamente os nomes snake_case do JSON do backend.
/// Enums chegam em PascalCase ("Coordenador", "Não realizada", ...).

class Usuario {
  final String id;
  final String idUnidade;
  final String nome;
  final String email;
  final String perfil; // "Coordenador" | "Tecnico"
  final String status; // "Ativo" | "Inativo"

  const Usuario({
    required this.id,
    required this.idUnidade,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.status,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as String,
        idUnidade: json['id_unidade'] as String? ?? '',
        nome: json['nome'] as String,
        email: json['email'] as String,
        perfil: json['perfil'] as String,
        status: json['status'] as String,
      );

  bool get ehCoordenador => perfil == 'Coordenador';

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }
}

class Familia {
  final String id;
  final String idUnidade;
  final String codigo;
  final String nomeReferencia;
  final String contato;
  final String endereco;
  final String status; // "Ativa" | "Inativa"

  const Familia({
    required this.id,
    required this.idUnidade,
    required this.codigo,
    required this.nomeReferencia,
    required this.contato,
    required this.endereco,
    required this.status,
  });

  factory Familia.fromJson(Map<String, dynamic> json) => Familia(
        id: json['id'] as String,
        idUnidade: json['id_unidade'] as String,
        codigo: json['codigo'] as String,
        nomeReferencia: json['nome_referencia'] as String,
        contato: json['contato'] as String? ?? '',
        endereco: json['endereco'] as String? ?? '',
        status: json['status'] as String,
      );
}

class Visita {
  final String id;
  final String idFamilia;
  final String idTecnico;
  final String idAgendadoPor;
  final String dataVisita; // "AAAA-MM-DD"
  final String horario; // "HH:MM:SS"
  final String prioridade; // "Baixa" | "Normal" | "Alta"
  final String objetivo;
  final String status; // "Agendada" | "Em andamento" | "Realizada" | ...
  final String? motivoCancelamento;
  final Familia? familia; // só preenchido no GET /visitas/{id}

  const Visita({
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

  factory Visita.fromJson(Map<String, dynamic> json) => Visita(
        id: json['id'] as String,
        idFamilia: json['id_familia'] as String,
        idTecnico: json['id_tecnico'] as String,
        idAgendadoPor: json['id_agendado_por'] as String,
        dataVisita: json['data_visita'] as String,
        horario: json['horario'] as String,
        prioridade: json['prioridade'] as String,
        objetivo: json['objetivo'] as String? ?? '',
        status: json['status'] as String,
        motivoCancelamento: json['motivo_cancelamento'] as String?,
        familia: json['familia'] == null
            ? null
            : Familia.fromJson(json['familia'] as Map<String, dynamic>),
      );

  /// "09:30:00" -> "09:30"
  String get horarioCurto =>
      horario.length >= 5 ? horario.substring(0, 5) : horario;

  /// "2026-10-25" -> "25/10/2026"
  String get dataFormatada {
    final partes = dataVisita.split('-');
    if (partes.length != 3) return dataVisita;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }
}

class RegistroVisita {
  final String id;
  final String idVisita;
  final String status; // "Rascunho" | "Finalizado"
  final String? resultado; // "Realizada" | "Não realizada"
  final String? descricao;
  final String? desfecho;
  final bool? necessitaRetorno;
  final String? motivoNaoRealizada;
  final String? dataHoraInicio;
  final String? dataHoraFim;
  final String registradoPor;

  const RegistroVisita({
    required this.id,
    required this.idVisita,
    required this.status,
    this.resultado,
    this.descricao,
    this.desfecho,
    this.necessitaRetorno,
    this.motivoNaoRealizada,
    this.dataHoraInicio,
    this.dataHoraFim,
    required this.registradoPor,
  });

  factory RegistroVisita.fromJson(Map<String, dynamic> json) => RegistroVisita(
        id: json['id'] as String,
        idVisita: json['id_visita'] as String,
        status: json['status'] as String,
        resultado: json['resultado'] as String?,
        descricao: json['descricao'] as String?,
        desfecho: json['desfecho'] as String?,
        necessitaRetorno: json['necessita_retorno'] as bool?,
        motivoNaoRealizada: json['motivo_nao_realizada'] as String?,
        dataHoraInicio: json['data_hora_inicio'] as String?,
        dataHoraFim: json['data_hora_fim'] as String?,
        registradoPor: json['registrado_por'] as String,
      );
}

class SolicitacaoRetorno {
  final String id;
  final String idVisita;
  final String motivo;
  final String prioridade;
  final String solicitadoPor;
  final String dataSolicitacao;
  final String status; // "Pendente" | "Aprovada" | "Rejeitada" | "Cancelada" | "Agendada"
  final String? decididoPor;
  final String? decisaoMotivo;
  final String? decididoEm;

  const SolicitacaoRetorno({
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

  factory SolicitacaoRetorno.fromJson(Map<String, dynamic> json) =>
      SolicitacaoRetorno(
        id: json['id'] as String,
        idVisita: json['id_visita'] as String,
        motivo: json['motivo'] as String,
        prioridade: json['prioridade'] as String,
        solicitadoPor: json['solicitado_por'] as String,
        dataSolicitacao: json['data_solicitacao'] as String,
        status: json['status'] as String,
        decididoPor: json['decidido_por'] as String?,
        decisaoMotivo: json['decisao_motivo'] as String?,
        decididoEm: json['decidido_em'] as String?,
      );
}

class Notificacao {
  final String id;
  final String titulo;
  final String mensagem;
  final String tipo; // "Lembrete" | "Aviso" | "Sistema"
  final bool lida;
  final String? lidaEm;
  final String dataHora;

  const Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.tipo,
    required this.lida,
    this.lidaEm,
    required this.dataHora,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) => Notificacao(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        mensagem: json['mensagem'] as String,
        tipo: json['tipo'] as String,
        lida: json['lida'] as bool,
        lidaEm: json['lida_em'] as String?,
        dataHora: json['data_hora'] as String,
      );
}

class Indicadores {
  final String periodoInicio;
  final String periodoFim;
  final int visitasAgendadas;
  final int visitasEmAndamento;
  final int visitasRealizadas;
  final int visitasNaoRealizadas;
  final int visitasCanceladas;
  final int totalVisitas;
  final int retornosPendentes;
  final bool periodoSemDados;

  const Indicadores({
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

  factory Indicadores.fromJson(Map<String, dynamic> json) => Indicadores(
        periodoInicio: json['periodo_inicio'] as String,
        periodoFim: json['periodo_fim'] as String,
        visitasAgendadas: json['visitas_agendadas'] as int,
        visitasEmAndamento: json['visitas_em_andamento'] as int,
        visitasRealizadas: json['visitas_realizadas'] as int,
        visitasNaoRealizadas: json['visitas_nao_realizadas'] as int,
        visitasCanceladas: json['visitas_canceladas'] as int,
        totalVisitas: json['total_visitas'] as int,
        retornosPendentes: json['retornos_pendentes'] as int,
        periodoSemDados: json['periodo_sem_dados'] as bool,
      );
}

class Encaminhamento {
  final String id;
  final String idVisita;
  final String destino;
  final String motivo;
  final String dataEncaminhamento;
  final String status; // "Aberto" | "Concluído"
  final String registradoPor;

  const Encaminhamento({
    required this.id,
    required this.idVisita,
    required this.destino,
    required this.motivo,
    required this.dataEncaminhamento,
    required this.status,
    required this.registradoPor,
  });

  factory Encaminhamento.fromJson(Map<String, dynamic> json) => Encaminhamento(
        id: json['id'] as String,
        idVisita: json['id_visita'] as String,
        destino: json['destino'] as String,
        motivo: json['motivo'] as String,
        dataEncaminhamento: json['data_encaminhamento'] as String,
        status: json['status'] as String,
        registradoPor: json['registrado_por'] as String,
      );
}
