import 'package:flutter/material.dart';

import '../services/api_excecao.dart';
import '../services/modelos.dart';
import '../services/sessao.dart';
import '../services/visita_api.dart';

import 'tela_familias.dart';

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
  bool _carregando = true;
  String? _erro;

  List<Visita> _visitasHoje = [];
  Map<String, Familia> _familiasPorId = {};
  Map<String, Usuario> _tecnicosPorId = {};
  Indicadores? _indicadores;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  static String _hoje() {
    final agora = DateTime.now();
    final mm = agora.month.toString().padLeft(2, '0');
    final dd = agora.day.toString().padLeft(2, '0');
    return '${agora.year}-$mm-$dd';
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final hoje = _hoje();
      final ehCoordenador =
          Sessao.instancia.usuario?.ehCoordenador ?? false;

      final resultados = await Future.wait([
        VisitaApi.listarVisitas(dataInicio: hoje, dataFim: hoje),
        VisitaApi.listarFamilias(),
        if (ehCoordenador)
          VisitaApi.listarProfissionais()
        else
          Future.value(<Usuario>[]),
        if (ehCoordenador)
          VisitaApi.obterIndicadores(dataInicio: hoje, dataFim: hoje)
        else
          Future<Indicadores?>.value(),
      ]);

      if (!mounted) return;

      final visitas = resultados[0] as List<Visita>;
      visitas.sort((a, b) => a.horario.compareTo(b.horario));

      setState(() {
        _visitasHoje = visitas;
        _familiasPorId = {
          for (final f in resultados[1] as List<Familia>) f.id: f,
        };
        _tecnicosPorId = {
          for (final u in resultados[2] as List<Usuario>) u.id: u,
        };
        _indicadores = resultados[3] as Indicadores?;
        _carregando = false;
      });
    } on ApiExcecao catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro.mensagem;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final concluidasHoje = _indicadores == null
        ? _visitasHoje.where((v) => v.status == 'Realizada').length
        : _indicadores!.visitasRealizadas;
    final retornos = _indicadores?.retornosPendentes ?? 0;

    return Scaffold(
      backgroundColor: TelaAgendaEquipe.fundo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _carregar,
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

                      // Indicadores
                      Row(
                        children: [
                          Expanded(
                            child: _IndicadorAgenda(
                              numero: _visitasHoje.length
                                  .toString()
                                  .padLeft(2, '0'),
                              titulo: 'Visitas hoje',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _IndicadorAgenda(
                              numero:
                                  concluidasHoje.toString().padLeft(2, '0'),
                              titulo: 'Concluídas',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _IndicadorAgenda(
                              numero: retornos.toString().padLeft(2, '0'),
                              titulo: 'Retornos',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 21),

                      const Text(
                        'Visitas de hoje',
                        style: TextStyle(
                          color: TelaAgendaEquipe.azulEscuro,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (_carregando)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 25),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_erro != null)
                        Center(
                          child: Column(
                            children: [
                              Text(
                                _erro!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: TelaAgendaEquipe.azulTexto,
                                  fontSize: 11,
                                ),
                              ),
                              TextButton(
                                onPressed: _carregar,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      else if (_visitasHoje.isEmpty)
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
                        ..._visitasHoje.map(
                          (visita) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CardVisitaAgenda(
                              horario: visita.horarioCurto,
                              familia: _familiasPorId[visita.idFamilia]
                                      ?.nomeReferencia ??
                                  'Família',
                              local:
                                  '${_familiasPorId[visita.idFamilia]?.endereco ?? ''} · ${_tecnicosPorId[visita.idTecnico]?.nome ?? ''}',
                              detalhe: visita.objetivo,
                              status: visita.status,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Navegação inferior
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: TelaAgendaEquipe.borda)),
              ),
              padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ItemMenuAgenda(
                    icone: Icons.home_outlined,
                    titulo: 'Início',
                    aoTocar: () => Navigator.of(context).pop(),
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
                    aoTocar: () => _mensagem(context, 'Equipe'),
                  ),
                  _ItemMenuAgenda(
                    icone: Icons.more_horiz,
                    titulo: 'Mais',
                    aoTocar: () => _mensagem(context, 'Mais opções'),
                  ),
                ],
              ),
            ),
          ],
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

  const _CardVisitaAgenda({
    required this.horario,
    required this.familia,
    required this.local,
    required this.detalhe,
    this.status = 'Agendada',
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Detalhes de $familia em desenvolvimento.'),
                    ),
                  );
                },
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
