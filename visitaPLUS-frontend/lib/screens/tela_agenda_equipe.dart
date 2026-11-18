import 'package:flutter/material.dart';

import '../api/api.dart';

import 'formatos.dart';

import 'tela_familias.dart';

import 'tela_informacoes_visita.dart';

import 'tela_historico_visitas.dart';
import 'tela_home_coordenador.dart';
import 'tela_equipe.dart';

/// Dados da agenda da equipe carregados da API.
class _DadosAgendaEquipe {
  _DadosAgendaEquipe({
    required this.indicadores,
    required this.visitas,
    required this.familiasPorId,
    required this.tecnicosPorId,
  });

  final Indicadores indicadores;
  final List<Visita> visitas;
  final Map<String, Familia> familiasPorId;
  final Map<String, Usuario> tecnicosPorId;
}

class TelaAgendaEquipe extends StatefulWidget {
  const TelaAgendaEquipe({super.key});

  static const verde = Color(0xFF008577);
  static const azulEscuro = Color(0xFF142A40);
  static const azulTexto = Color(0xFF647895);
  static const fundo = Color(0xFFF3F7FA);
  static const borda = Color(0xFFD9E2EC);

  @override
  State<TelaAgendaEquipe> createState() => _TelaAgendaEquipeState();
}

class _TelaAgendaEquipeState extends State<TelaAgendaEquipe> {
  late Future<_DadosAgendaEquipe> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _carregar();
  }

  Future<_DadosAgendaEquipe> _carregar() async {
    final hoje = DateTime.now();
    final resultados = await Future.wait([
      IndicadoresApi.consultar(dataInicio: hoje, dataFim: hoje),
      VisitasApi.listar(dataInicio: hoje, dataFim: hoje),
      FamiliasApi.listar(),
      ProfissionaisApi.listar(),
    ]);
    final visitas = resultados[1] as List<Visita>
      ..sort((a, b) => a.horario.compareTo(b.horario));
    return _DadosAgendaEquipe(
      indicadores: resultados[0] as Indicadores,
      visitas: visitas,
      familiasPorId: {
        for (final familia in resultados[2] as List<Familia>) familia.id: familia,
      },
      tecnicosPorId: {
        for (final tecnico in resultados[3] as List<Usuario>) tecnico.id: tecnico,
      },
    );
  }

  void _recarregar() {
    setState(() => _futuro = _carregar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TelaAgendaEquipe.fundo,
      body: SafeArea(
        child: FutureBuilder<_DadosAgendaEquipe>(
          future: _futuro,
          builder: (context, snapshot) {
            final dados = snapshot.data;

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: TelaAgendaEquipe.verde,
                    onRefresh: () async => _recarregar(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(17, 22, 17, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agenda da equipe',
                            style: TextStyle(
                              color: TelaAgendaEquipe.azulEscuro,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Visitas organizadas por horário e profissional.',
                            style: TextStyle(
                              color: TelaAgendaEquipe.azulTexto,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Indicadores do dia (API /indicadores)
                          Row(
                            children: [
                              Expanded(
                                child: _IndicadorAgenda(
                                  numero:
                                      (dados?.indicadores.totalVisitas ?? 0)
                                          .toString()
                                          .padLeft(2, '0'),
                                  titulo: 'Visitas hoje',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _IndicadorAgenda(
                                  numero:
                                      (dados?.indicadores.visitasRealizadas ??
                                              0)
                                          .toString()
                                          .padLeft(2, '0'),
                                  titulo: 'Concluídas',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _IndicadorAgenda(
                                  numero:
                                      (dados?.indicadores.retornosPendentes ??
                                              0)
                                          .toString()
                                          .padLeft(2, '0'),
                                  titulo: 'Retornos',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 21),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Visitas de hoje',
                                style: TextStyle(
                                  color: TelaAgendaEquipe.azulEscuro,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TelaHistoricoVisitas(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Ver todas',
                                  style: TextStyle(
                                    color: TelaAgendaEquipe.verde,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (snapshot.hasError)
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    snapshot.error is ExcecaoApi
                                        ? (snapshot.error as ExcecaoApi)
                                              .mensagem
                                        : 'Não foi possível carregar '
                                              'a agenda.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: TelaAgendaEquipe.azulTexto,
                                      fontSize: 11,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _recarregar,
                                    child: const Text(
                                      'Tentar novamente',
                                      style: TextStyle(
                                        color: TelaAgendaEquipe.verde,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (!snapshot.hasData)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: TelaAgendaEquipe.verde,
                                ),
                              ),
                            )
                          else if (dados!.visitas.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 25),
                              child: Center(
                                child: Text(
                                  'Nenhuma visita agendada para hoje.',
                                  style: TextStyle(
                                    color: TelaAgendaEquipe.azulTexto,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...dados.visitas.map((visita) {
                              final familia =
                                  dados.familiasPorId[visita.idFamilia];
                              final tecnico =
                                  dados.tecnicosPorId[visita.idTecnico];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CardVisitaAgenda(
                                  horario: fmtHora(visita.horario),
                                  familia:
                                      familia?.nomeReferencia ?? 'Família',
                                  local:
                                      '${familia?.endereco ?? '-'} · ${tecnico?.nome ?? '-'}',
                                  detalhe: visita.objetivo,
                                  status: visita.status,
                                  aoVerDetalhes: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TelaInformacoesVisita(
                                              visita: visita,
                                              familia: familia,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),

                // Navegação inferior
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: TelaAgendaEquipe.borda),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ItemMenuAgenda(
                        icone: Icons.home_outlined,
                        titulo: 'Início',
                        aoTocar: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TelaHomeCoordenador(),
                            ),
                          );
                        },
                      ),
                      _ItemMenuAgenda(
                        icone: Icons.calendar_month_outlined,
                        titulo: 'Agenda',
                        selecionado: true,
                        aoTocar: () {},
                      ),
                      _ItemMenuAgenda(
                        icone: Icons.people_outline,
                        titulo: 'Famílias',
                        aoTocar: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TelaFamilias(),
                            ),
                          );
                        },
                      ),
                      _ItemMenuAgenda(
                        icone: Icons.groups_outlined,
                        titulo: 'Equipe',
                        aoTocar: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TelaEquipe(),
                            ),
                          );
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
}

class _IndicadorAgenda extends StatelessWidget {
  final String numero;
  final String titulo;

  const _IndicadorAgenda({required this.numero, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TelaAgendaEquipe.borda),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            color: TelaAgendaEquipe.verde,
            size: 15,
          ),
          const SizedBox(height: 3),
          Text(
            numero,
            style: const TextStyle(
              color: TelaAgendaEquipe.azulEscuro,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              titulo,
              style: const TextStyle(
                color: TelaAgendaEquipe.azulTexto,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardVisitaAgenda extends StatelessWidget {
  final String horario;
  final String familia;
  final String local;
  final String detalhe;
  final String status;
  final VoidCallback aoVerDetalhes;

  const _CardVisitaAgenda({
    required this.horario,
    required this.familia,
    required this.local,
    required this.detalhe,
    required this.status,
    required this.aoVerDetalhes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TelaAgendaEquipe.borda),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
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
                  color: TelaAgendaEquipe.azulEscuro,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Color(0xFF168363), fontSize: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            familia,
            style: const TextStyle(
              color: TelaAgendaEquipe.azulEscuro,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: TelaAgendaEquipe.azulTexto,
                size: 13,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  local,
                  style: const TextStyle(
                    color: TelaAgendaEquipe.azulTexto,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  detalhe,
                  style: const TextStyle(
                    color: TelaAgendaEquipe.azulTexto,
                    fontSize: 9,
                  ),
                ),
              ),
              InkWell(
                onTap: aoVerDetalhes,
                child: const Row(
                  children: [
                    Text(
                      'Ver detalhes',
                      style: TextStyle(
                        color: TelaAgendaEquipe.verde,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.chevron_right,
                      color: TelaAgendaEquipe.verde,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemMenuAgenda extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _ItemMenuAgenda({
    required this.icone,
    required this.titulo,
    this.selecionado = false,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado
        ? TelaAgendaEquipe.verde
        : TelaAgendaEquipe.azulTexto;

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
