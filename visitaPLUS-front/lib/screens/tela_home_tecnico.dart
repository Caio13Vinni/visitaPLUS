import 'package:flutter/material.dart';

import '../services/api_excecao.dart';
import '../services/modelos.dart';
import '../services/sessao.dart';
import '../services/visita_api.dart';

import 'tela_familias.dart';
import 'tela_perfil_coordenador.dart';

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
  bool _carregando = true;
  String? _erro;

  List<Visita> _proximas = [];
  int _visitasHoje = 0;
  int _retornosPendentes = 0;
  Map<String, Familia> _familiasPorId = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  static String _dataHoje() {
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
      final resultados = await Future.wait([
        VisitaApi.listarVisitas(status: 'Agendada'),
        VisitaApi.listarFamilias(),
        VisitaApi.listarSolicitacoes(status: 'Pendente'),
      ]);

      if (!mounted) return;

      final visitas = resultados[0] as List<Visita>;
      final hoje = _dataHoje();

      visitas.sort((a, b) =>
          '${a.dataVisita} ${a.horario}'.compareTo('${b.dataVisita} ${b.horario}'));

      setState(() {
        _proximas = visitas;
        _visitasHoje = visitas.where((v) => v.dataVisita == hoje).length;
        _retornosPendentes =
            (resultados[2] as List<SolicitacaoRetorno>).length;
        _familiasPorId = {
          for (final f in resultados[1] as List<Familia>) f.id: f,
        };
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

  Familia? _familiaDe(Visita visita) => _familiasPorId[visita.idFamilia];

  @override
  Widget build(BuildContext context) {
    final usuario = Sessao.instancia.usuario;
    final primeiroNome = (usuario?.nome ?? '').split(' ').first;
    final proxima = _proximas.isEmpty ? null : _proximas.first;

    return Scaffold(
      backgroundColor: TelaHomeTecnico.fundo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _carregar,
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
                                  'Olá, $primeiroNome',
                                  style: const TextStyle(
                                    color: TelaHomeTecnico.azulEscuro,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Técnica de referência',
                                  style: TextStyle(
                                    color: TelaHomeTecnico.azulTexto,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _mensagem(context, 'Notificações'),
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
                              final u = Sessao.instancia.usuario;
                              if (u == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TelaPerfilCoordenador(
                                    nome: u.nome,
                                    matricula: '-',
                                    unidade: '-',
                                    funcao: u.ehCoordenador
                                        ? 'Coordenador(a)'
                                        : 'Técnico(a) de referência',
                                    email: u.email,
                                    telefone: '-',
                                    visitas: '-',
                                    acompanhamentos: '-',
                                  ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF092D55),
                              child: Text(
                                usuario?.iniciais ?? '',
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

                      if (_carregando)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_erro != null)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Text(
                                _erro!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: TelaHomeTecnico.azulTexto,
                                  fontSize: 12,
                                ),
                              ),
                              TextButton(
                                onPressed: _carregar,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      else ...[
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
                                  if (proxima != null) ...[
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      proxima.horarioCurto,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                proxima == null
                                    ? 'Nenhuma visita agendada'
                                    : _familiaDe(proxima)?.nomeReferencia ??
                                        'Família',
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
                                      proxima == null
                                          ? 'Sua agenda está livre.'
                                          : '${_familiaDe(proxima)?.endereco ?? ''} · ${proxima.dataFormatada}',
                                      style: const TextStyle(
                                        color: Color(0xFFD9E5F2),
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
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
                                numero: _visitasHoje
                                    .toString()
                                    .padLeft(2, '0'),
                                titulo: 'Visitas hoje',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _IndicadorTecnico(
                                icone: Icons.call_missed_outgoing,
                                numero: _retornosPendentes
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Próximas visitas',
                              style: TextStyle(
                                color: TelaHomeTecnico.azulEscuro,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        if (_proximas.length <= 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: Text(
                                'Nenhuma outra visita na agenda.',
                                style: TextStyle(
                                  color: TelaHomeTecnico.azulTexto,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          )
                        else
                          ..._proximas.skip(1).map(
                                (visita) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _VisitaTecnico(
                                    horario:
                                        '${visita.dataFormatada} ${visita.horarioCurto}',
                                    familia: _familiaDe(visita)
                                            ?.nomeReferencia ??
                                        'Família',
                                    local:
                                        _familiaDe(visita)?.endereco ?? '',
                                    detalhe: visita.objetivo,
                                  ),
                                ),
                              ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Menu inferior
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: TelaHomeTecnico.borda)),
              ),
              padding: const EdgeInsets.fromLTRB(4, 7, 4, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MenuTecnico(
                    icone: Icons.home_outlined,
                    titulo: 'Início',
                    selecionado: true,
                    aoTocar: () {},
                  ),
                  _MenuTecnico(
                    icone: Icons.calendar_month_outlined,
                    titulo: 'Agenda',
                    aoTocar: () => _mensagem(context, 'Agenda'),
                  ),
                  _MenuTecnico(
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
                  _MenuTecnico(
                    icone: Icons.groups_outlined,
                    titulo: 'Equipe',
                    aoTocar: () => _mensagem(context, 'Equipe'),
                  ),
                  _MenuTecnico(
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

  const _VisitaTecnico({
    required this.horario,
    required this.familia,
    required this.local,
    required this.detalhe,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalhes de $familia em desenvolvimento.')),
          );
        },
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
                    child: const Text(
                      'Agendada',
                      style: TextStyle(color: Color(0xFF168363), fontSize: 8),
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
    this.selecionado = false,
    required this.aoTocar,
  });

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
