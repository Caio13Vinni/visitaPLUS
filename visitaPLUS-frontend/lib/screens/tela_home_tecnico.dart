import 'package:flutter/material.dart';

import '../api/api.dart';

import 'formatos.dart';

import 'tela_perfil_coordenador.dart';

import 'tela_agenda_tecnico.dart';

import 'tela_familias.tecnico.dart';

import 'tela_informacoes_tecnico.dart';

import 'tela_equipe.dart';

/// Dados da home do tecnico carregados da API.
class _DadosHomeTecnico {
  _DadosHomeTecnico({
    required this.visitasHoje,
    required this.familiasPorId,
    required this.retornosPendentes,
  });

  final List<Visita> visitasHoje;
  final Map<String, Familia> familiasPorId;
  final int retornosPendentes;

  /// Primeira visita ainda agendada, em ordem de horario.
  Visita? get proxima {
    final agendadas = visitasHoje
        .where((v) => v.status == StatusVisita.agendada)
        .toList()
      ..sort((a, b) => a.horario.compareTo(b.horario));
    return agendadas.isEmpty ? null : agendadas.first;
  }
}

class TelaHomeTecnico extends StatefulWidget {
  const TelaHomeTecnico({super.key});

  static const verde = Color(0xFF008577);
  static const azulEscuro = Color(0xFF142A40);
  static const azulTexto = Color(0xFF647895);
  static const fundo = Color(0xFFF3F7FA);
  static const borda = Color(0xFFD9E2EC);

  @override
  State<TelaHomeTecnico> createState() => _TelaHomeTecnicoState();
}

class _TelaHomeTecnicoState extends State<TelaHomeTecnico> {
  late Future<_DadosHomeTecnico> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _carregar();
  }

  Future<_DadosHomeTecnico> _carregar() async {
    final hoje = DateTime.now();
    final resultados = await Future.wait([
      VisitasApi.listar(
        idTecnico: Sessao.usuario?.id,
        dataInicio: hoje,
        dataFim: hoje,
      ),
      FamiliasApi.listar(),
      SolicitacoesApi.listar(status: StatusSolicitacao.pendente),
    ]);
    return _DadosHomeTecnico(
      visitasHoje: resultados[0] as List<Visita>,
      familiasPorId: {
        for (final familia in resultados[1] as List<Familia>) familia.id: familia,
      },
      retornosPendentes: (resultados[2] as List).length,
    );
  }

  void _recarregar() {
    setState(() => _futuro = _carregar());
  }

  String get _primeiroNome {
    final nome = Sessao.usuario?.nome ?? '';
    return nome.isEmpty ? '' : nome.split(' ').first;
  }

  String get _iniciais {
    final partes = (Sessao.usuario?.nome ?? '')
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[partes.length - 1][0]).toUpperCase();
  }

  void _abrirVisita(Visita visita, Familia? familia) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TelaInformacoesVisita(visita: visita, familia: familia),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TelaHomeTecnico.fundo,
      body: SafeArea(
        child: FutureBuilder<_DadosHomeTecnico>(
          future: _futuro,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        color: TelaHomeTecnico.azulTexto,
                        size: 34,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        snapshot.error is ExcecaoApi
                            ? (snapshot.error as ExcecaoApi).mensagem
                            : 'Não foi possível carregar os dados.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: TelaHomeTecnico.azulTexto,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _recarregar,
                        child: const Text(
                          'Tentar novamente',
                          style: TextStyle(color: TelaHomeTecnico.verde),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: TelaHomeTecnico.verde,
                ),
              );
            }

            final dados = snapshot.data!;
            final proxima = dados.proxima;
            final familiaProxima = proxima == null
                ? null
                : dados.familiasPorId[proxima.idFamilia];

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: TelaHomeTecnico.verde,
                    onRefresh: () async => _recarregar(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(17, 17, 17, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Olá, $_primeiroNome',
                                      style: const TextStyle(
                                        color: TelaHomeTecnico.azulEscuro,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Técnico(a) de referência',
                                      style: TextStyle(
                                        color: TelaHomeTecnico.azulTexto,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _mensagem(
                                  context,
                                  'Notificações',
                                ),
                                icon: const Icon(
                                  Icons.notifications_none,
                                  color: TelaHomeTecnico.azulEscuro,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: TelaHomeTecnico.borda,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: const Size(38, 38),
                                ),
                              ),
                              const SizedBox(width: 5),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TelaPerfilCoordenador(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFF092D55),
                                  child: Text(
                                    _iniciais,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Próxima visita em destaque
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF092D55),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'PRÓXIMA VISITA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      proxima == null
                                          ? '--:--'
                                          : fmtHora(proxima.horario),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  familiaProxima?.nomeReferencia ??
                                      'Nenhuma visita agendada',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFFD9E5F2),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        familiaProxima?.endereco ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFFD9E5F2),
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 13),
                                SizedBox(
                                  width: double.infinity,
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: proxima == null
                                        ? null
                                        : () => _abrirVisita(
                                            proxima,
                                            familiaProxima,
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor:
                                          TelaHomeTecnico.azulEscuro,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Ver visita atribuída',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                        Icon(Icons.chevron_right, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Indicadores
                          Row(
                            children: [
                              Expanded(
                                child: _IndicadorTecnico(
                                  icone: Icons.calendar_month_outlined,
                                  numero: dados.visitasHoje.length
                                      .toString()
                                      .padLeft(2, '0'),
                                  titulo: 'Visitas hoje',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _IndicadorTecnico(
                                  icone: Icons.call_missed_outgoing,
                                  numero: dados.retornosPendentes
                                      .toString()
                                      .padLeft(2, '0'),
                                  titulo: 'Retorno pendente',
                                  retorno: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Título da lista
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Próximas visitas',
                                style: TextStyle(
                                  color: TelaHomeTecnico.azulEscuro,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TelaAgendaTecnico(),
                                    ),
                                  );
                                  _recarregar();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(40, 28),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Ver agenda',
                                  style: TextStyle(
                                    color: TelaHomeTecnico.verde,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 7),

                          if (dados.visitasHoje.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Center(
                                child: Text(
                                  'Nenhuma visita agendada para hoje.',
                                  style: TextStyle(
                                    color: TelaHomeTecnico.azulTexto,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...dados.visitasHoje.map((visita) {
                              final familia =
                                  dados.familiasPorId[visita.idFamilia];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _VisitaTecnico(
                                  horario: fmtHora(visita.horario),
                                  familia:
                                      familia?.nomeReferencia ?? 'Família',
                                  local: familia?.endereco ?? '',
                                  detalhe: visita.objetivo,
                                  status: visita.status,
                                  aoTocar: () =>
                                      _abrirVisita(visita, familia),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),

                // Menu inferior
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: TelaHomeTecnico.borda),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(4, 7, 4, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MenuTecnico(
                        icone: Icons.home_outlined,
                        titulo: 'Início',
                        aoTocar: () {},
                      ),
                      _MenuTecnico(
                        icone: Icons.calendar_month_outlined,
                        titulo: 'Agenda',
                        aoTocar: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TelaAgendaTecnico(),
                            ),
                          );
                          _recarregar();
                        },
                      ),
                      _MenuTecnico(
                        icone: Icons.people_outline,
                        titulo: 'Famílias',
                        aoTocar: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TelaFamilias(),
                            ),
                          );
                          _recarregar();
                        },
                      ),
                      _MenuTecnico(
                        icone: Icons.groups_outlined,
                        titulo: 'Equipe',
                        aoTocar: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TelaEquipe(),
                            ),
                          );
                          _recarregar();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static void _mensagem(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$texto: tela ainda em desenvolvimento.')),
    );
  }
}

class _IndicadorTecnico extends StatelessWidget {
  final IconData icone;
  final String numero;
  final String titulo;
  final bool retorno;

  const _IndicadorTecnico({
    required this.icone,
    required this.numero,
    required this.titulo,
    this.retorno = false,
  });

  @override
  Widget build(BuildContext context) {
    final corIcone = retorno ? const Color(0xFFB7791F) : TelaHomeTecnico.verde;

    final fundoIcone = retorno
        ? const Color(0xFFFFF2D8)
        : const Color(0xFFE7F4F1);

    return Container(
      constraints: const BoxConstraints(minHeight: 65),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: TelaHomeTecnico.borda),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: fundoIcone,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icone, color: corIcone, size: 14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  numero,
                  style: const TextStyle(
                    color: TelaHomeTecnico.azulEscuro,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: TelaHomeTecnico.azulTexto,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitaTecnico extends StatelessWidget {
  final String horario;
  final String familia;
  final String local;
  final String detalhe;
  final String status;
  final VoidCallback aoTocar;

  const _VisitaTecnico({
    required this.horario,
    required this.familia,
    required this.local,
    required this.detalhe,
    required this.status,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            border: Border.all(color: TelaHomeTecnico.borda),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    horario,
                    style: const TextStyle(
                      color: TelaHomeTecnico.azulEscuro,
                      fontSize: 9,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F6F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Color(0xFF168363),
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                familia,
                style: const TextStyle(
                  color: TelaHomeTecnico.azulEscuro,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: TelaHomeTecnico.azulTexto,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      local,
                      style: const TextStyle(
                        color: TelaHomeTecnico.azulTexto,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      detalhe,
                      style: const TextStyle(
                        color: TelaHomeTecnico.azulTexto,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  const Text(
                    'Ver detalhes',
                    style: TextStyle(
                      color: TelaHomeTecnico.verde,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: TelaHomeTecnico.verde,
                    size: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTecnico extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _MenuTecnico({
    required this.icone,
    required this.titulo,
    required this.aoTocar,
  }) : selecionado = false;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? TelaHomeTecnico.verde : TelaHomeTecnico.azulTexto;

    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cor, size: 17),
            const SizedBox(height: 3),
            Text(
              titulo,
              style: TextStyle(
                color: cor,
                fontSize: 8,
                fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
