import 'package:flutter/material.dart';

import '../api/api.dart';

import 'tela_novo_profissional.dart';

import 'tela_agenda_equipe.dart';

import 'tela_familias.dart';

import 'tela_equipe.dart';

import 'tela_nova_visita.dart';

import 'tela_detalhes_familia.dart';

/// Dados carregados da API para a home do coordenador.
class _DadosHome {
  _DadosHome({
    required this.indicadores,
    required this.visitasHoje,
    required this.familiasPorId,
    required this.tecnicosPorId,
  });

  final Indicadores indicadores;
  final List<Visita> visitasHoje;
  final Map<String, Familia> familiasPorId;
  final Map<String, Usuario> tecnicosPorId;
}

class TelaHomeCoordenador extends StatefulWidget {
  const TelaHomeCoordenador({super.key});

  static const verde = Color(0xFF008577);
  static const azulEscuro = Color(0xFF142A40);
  static const azulTexto = Color(0xFF647895);
  static const borda = Color(0xFFD9E2EC);
  static const fundo = Color(0xFFF4F7FA);

  @override
  State<TelaHomeCoordenador> createState() => _TelaHomeCoordenadorState();
}

class _TelaHomeCoordenadorState extends State<TelaHomeCoordenador> {
  late Future<_DadosHome> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _carregar();
  }

  Future<_DadosHome> _carregar() async {
    final hoje = DateTime.now();
    final resultados = await Future.wait([
      IndicadoresApi.consultar(dataInicio: hoje, dataFim: hoje),
      VisitasApi.listar(dataInicio: hoje, dataFim: hoje),
      FamiliasApi.listar(),
      ProfissionaisApi.listar(),
    ]);
    return _DadosHome(
      indicadores: resultados[0] as Indicadores,
      visitasHoje: resultados[1] as List<Visita>,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TelaHomeCoordenador.fundo,
      body: SafeArea(
        child: FutureBuilder<_DadosHome>(
          future: _futuro,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _EstadoErro(
                mensagem: snapshot.error is ExcecaoApi
                    ? (snapshot.error as ExcecaoApi).mensagem
                    : 'Não foi possível carregar os dados.',
                aoTentarNovamente: _recarregar,
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: TelaHomeCoordenador.verde,
                ),
              );
            }

            final dados = snapshot.data!;
            final indicadores = dados.indicadores;

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: TelaHomeCoordenador.verde,
                    onRefresh: () async => _recarregar(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(17, 16, 17, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho do coordenador
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Olá, $_primeiroNome',
                                      style: const TextStyle(
                                        color: TelaHomeCoordenador.azulEscuro,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Coordenador da unidade',
                                      style: TextStyle(
                                        color: TelaHomeCoordenador.azulTexto,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Nenhuma notificação nova.',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_none,
                                  color: TelaHomeCoordenador.azulEscuro,
                                  size: 21,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: TelaHomeCoordenador.borda,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              CircleAvatar(
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
                            ],
                          ),

                          const SizedBox(height: 19),

                          // Indicadores do dia (API /indicadores)
                          Row(
                            children: [
                              Expanded(
                                child: _IndicadorHome(
                                  icone: Icons.calendar_month_outlined,
                                  numero: indicadores.totalVisitas
                                      .toString()
                                      .padLeft(2, '0'),
                                  titulo: 'Visitas hoje',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _IndicadorHome(
                                  icone: Icons.calendar_month_outlined,
                                  numero: indicadores.visitasRealizadas
                                      .toString()
                                      .padLeft(2, '0'),
                                  titulo: 'Concluídas',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _IndicadorHome(
                                  icone: Icons.calendar_month_outlined,
                                  numero: indicadores.retornosPendentes
                                      .toString()
                                      .padLeft(2, '0'),
                                  titulo: 'Retornos',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 21),

                          const Text(
                            'Ações rápidas',
                            style: TextStyle(
                              color: TelaHomeCoordenador.azulEscuro,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 9),

                          Row(
                            children: [
                              Expanded(
                                child: _AcaoRapidaHome(
                                  icone: Icons.calendar_month_outlined,
                                  titulo: 'Agendar visita',
                                  descricao: 'Definir família, data e técnico',
                                  aoTocar: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TelaNovaVisita(),
                                      ),
                                    );
                                    _recarregar();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _AcaoRapidaHome(
                                  icone: Icons.people_outline,
                                  titulo: 'Novo profissional',
                                  descricao: 'Cadastrar acesso da equipe',
                                  aoTocar: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TelaNovoProfissional(),
                                      ),
                                    );
                                    _recarregar();
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 21),

                          // Título da agenda
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Agenda da equipe',
                                style: TextStyle(
                                  color: TelaHomeCoordenador.azulEscuro,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TelaAgendaEquipe(),
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
                                  'Ver tudo',
                                  style: TextStyle(
                                    color: TelaHomeCoordenador.verde,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          if (dados.visitasHoje.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Center(
                                child: Text(
                                  'Nenhuma visita agendada para hoje.',
                                  style: TextStyle(
                                    color: TelaHomeCoordenador.azulTexto,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...dados.visitasHoje.take(3).map((visita) {
                              final familia =
                                  dados.familiasPorId[visita.idFamilia];
                              final tecnico =
                                  dados.tecnicosPorId[visita.idTecnico];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CardVisitaHome(
                                  horario: visita.horario.length >= 5
                                      ? visita.horario.substring(0, 5)
                                      : visita.horario,
                                  familia:
                                      familia?.nomeReferencia ?? 'Família',
                                  local:
                                      '${familia?.endereco ?? '-'} · ${tecnico?.nome ?? '-'}',
                                  tipo: visita.status,
                                  detalhe: visita.objetivo,
                                  familiaObj: familia,
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
                      top: BorderSide(color: TelaHomeCoordenador.borda),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ItemMenuHome(
                        icone: Icons.home_outlined,
                        titulo: 'Início',
                        selecionado: true,
                        aoTocar: () {},
                      ),
                      _ItemMenuHome(
                        icone: Icons.calendar_month_outlined,
                        titulo: 'Agenda',
                        aoTocar: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TelaAgendaEquipe(),
                            ),
                          );
                          _recarregar();
                        },
                      ),
                      _ItemMenuHome(
                        icone: Icons.people_outline,
                        titulo: 'Famílias',
                        aoTocar: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TelaFamilias(),
                            ),
                          );
                          _recarregar();
                        },
                      ),
                      _ItemMenuHome(
                        icone: Icons.groups_outlined,
                        titulo: 'Equipe',
                        aoTocar: () async {
                          await Navigator.of(context).push(
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
}

/// Estado de erro com botao para tentar novamente.
class _EstadoErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback aoTentarNovamente;

  const _EstadoErro({required this.mensagem, required this.aoTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: TelaHomeCoordenador.azulTexto,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TelaHomeCoordenador.azulTexto,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: aoTentarNovamente,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: TelaHomeCoordenador.verde),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicadorHome extends StatelessWidget {
  final IconData icone;
  final String numero;
  final String titulo;

  const _IndicadorHome({
    required this.icone,
    required this.numero,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TelaHomeCoordenador.borda),
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
          Icon(icone, color: TelaHomeCoordenador.verde, size: 15),
          const SizedBox(height: 3),
          Text(
            numero,
            style: const TextStyle(
              color: TelaHomeCoordenador.azulEscuro,
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
                color: TelaHomeCoordenador.azulTexto,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcaoRapidaHome extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final VoidCallback aoTocar;

  const _AcaoRapidaHome({
    required this.icone,
    required this.titulo,
    required this.descricao,
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
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TelaHomeCoordenador.borda),
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
              Icon(icone, color: TelaHomeCoordenador.verde, size: 18),
              const SizedBox(height: 7),
              Text(
                titulo,
                style: const TextStyle(
                  color: TelaHomeCoordenador.azulEscuro,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descricao,
                style: const TextStyle(
                  color: TelaHomeCoordenador.azulTexto,
                  fontSize: 9,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardVisitaHome extends StatelessWidget {
  final String horario;
  final String familia;
  final String local;
  final String tipo;
  final String detalhe;
  final Familia? familiaObj;

  const _CardVisitaHome({
    required this.horario,
    required this.familia,
    required this.local,
    required this.tipo,
    required this.detalhe,
    this.familiaObj,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TelaHomeCoordenador.borda),
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
                  color: TelaHomeCoordenador.azulEscuro,
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
                  tipo,
                  style: const TextStyle(color: Color(0xFF168363), fontSize: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            familia,
            style: const TextStyle(
              color: TelaHomeCoordenador.azulEscuro,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: TelaHomeCoordenador.azulTexto,
                size: 13,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  local,
                  style: const TextStyle(
                    color: TelaHomeCoordenador.azulTexto,
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
                    color: TelaHomeCoordenador.azulTexto,
                    fontSize: 9,
                  ),
                ),
              ),
              InkWell(
                onTap: familiaObj == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TelaDetalhesFamilia(familia: familiaObj!),
                          ),
                        );
                      },
                child: const Row(
                  children: [
                    Text(
                      'Ver detalhes',
                      style: TextStyle(
                        color: TelaHomeCoordenador.verde,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.chevron_right,
                      color: TelaHomeCoordenador.verde,
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

class _ItemMenuHome extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _ItemMenuHome({
    required this.icone,
    required this.titulo,
    this.selecionado = false,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado
        ? TelaHomeCoordenador.verde
        : TelaHomeCoordenador.azulTexto;

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
