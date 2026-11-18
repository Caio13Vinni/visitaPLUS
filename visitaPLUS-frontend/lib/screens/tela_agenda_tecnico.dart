import 'package:flutter/material.dart';

import '../api/api.dart';

import 'formatos.dart';

import 'tela_nova_visita.dart';

import 'tela_informacoes_tecnico.dart';

import 'tela_historico_visitas.dart';

import 'tela_familias.tecnico.dart';

import 'tela_equipe.dart';

import 'tela_home_tecnico.dart';

const Color verde = Color(0xFF008577);
const Color azulEscuro = Color(0xFF142A40);
const Color azulTexto = Color(0xFF647895);
const Color borda = Color(0xFFD9E2EC);
const Color fundo = Color(0xFFF4F7FA);

/// Dados da agenda do tecnico carregados da API.
class _DadosAgenda {
  _DadosAgenda({
    required this.visitas,
    required this.familiasPorId,
    required this.retornosPendentes,
  });

  final List<Visita> visitas;
  final Map<String, Familia> familiasPorId;
  final int retornosPendentes;
}

class TelaAgendaTecnico extends StatefulWidget {
  const TelaAgendaTecnico({super.key});

  @override
  State<TelaAgendaTecnico> createState() => _TelaAgendaTecnicoState();
}

class _TelaAgendaTecnicoState extends State<TelaAgendaTecnico> {
  late Future<_DadosAgenda> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _carregar();
  }

  Future<_DadosAgenda> _carregar() async {
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
    final visitas = resultados[0] as List<Visita>
      ..sort((a, b) => a.horario.compareTo(b.horario));
    return _DadosAgenda(
      visitas: visitas,
      familiasPorId: {
        for (final familia in resultados[1] as List<Familia>) familia.id: familia,
      },
      retornosPendentes: (resultados[2] as List).length,
    );
  }

  void _recarregar() {
    setState(() => _futuro = _carregar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,

      body: SafeArea(
        child: FutureBuilder<_DadosAgenda>(
          future: _futuro,
          builder: (context, snapshot) {
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: verde,
                    onRefresh: () async => _recarregar(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CABEÇALHO
                          const Text(
                            'Agenda',
                            style: TextStyle(
                              color: azulEscuro,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Visitas atribuídas a ${Sessao.usuario?.nome ?? ''}.',
                            style: const TextStyle(
                              color: azulTexto,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // RESUMO DA AGENDA
                          Row(
                            children: [
                              Expanded(
                                child: _CartaoResumo(
                                  icone: Icons.calendar_month_outlined,
                                  quantidade: (snapshot.data?.visitas.length ?? 0)
                                      .toString()
                                      .padLeft(2, '0'),
                                  titulo: 'Visitas hoje',
                                  cor: const Color(0xFFE3F3F0),
                                  corIcone: verde,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _CartaoResumo(
                                  icone: Icons.key_outlined,
                                  quantidade:
                                      (snapshot.data?.retornosPendentes ?? 0)
                                          .toString()
                                          .padLeft(2, '0'),
                                  titulo: 'Retorno pendente',
                                  cor: const Color(0xFFFFF0D5),
                                  corIcone: const Color(0xFFB7791F),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // BOTÃO AGENDAR
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TelaNovaVisita(),
                                  ),
                                );
                                _recarregar();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: verde,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Agendar nova visita',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.chevron_right, size: 20),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // TÍTULO DA LISTA
                          const Text(
                            'Visitas de hoje',
                            style: TextStyle(
                              color: azulEscuro,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // LISTA DE VISITAS
                          if (snapshot.hasError)
                            _QuadroErro(
                              mensagem: snapshot.error is ExcecaoApi
                                  ? (snapshot.error as ExcecaoApi).mensagem
                                  : 'Não foi possível carregar a agenda.',
                              aoTentarNovamente: _recarregar,
                            )
                          else if (!snapshot.hasData)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: verde,
                                ),
                              ),
                            )
                          else if (snapshot.data!.visitas.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 25),
                              child: Center(
                                child: Text(
                                  'Nenhuma visita agendada para hoje.',
                                  style: TextStyle(
                                    color: azulTexto,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...snapshot.data!.visitas.map((visita) {
                              final familia =
                                  snapshot.data!.familiasPorId[visita.idFamilia];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _CartaoVisita(
                                  horario: fmtHora(visita.horario),
                                  familia:
                                      familia?.nomeReferencia ?? 'Família',
                                  endereco: familia?.endereco ?? '',
                                  tipo: visita.objetivo,
                                  status: visita.status,
                                  aoTocar: () {
                                    Navigator.push(
                                      context,
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

                          const SizedBox(height: 8),

                          // VER TODAS AS VISITAS
                          Container(
                            width: double.infinity,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: borda),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TelaHistoricoVisitas(),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    color: verde,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Ver todas as visitas',
                                    style: TextStyle(
                                      color: azulEscuro,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.chevron_right,
                                    color: azulEscuro,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // MENU INFERIOR
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: borda)),
                  ),
                  padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ItemMenu(
                        icone: Icons.home_outlined,
                        texto: 'Início',
                        aoTocar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TelaHomeTecnico(),
                            ),
                          );
                        },
                      ),

                      _ItemMenu(
                        icone: Icons.calendar_month_outlined,
                        texto: 'Agenda',
                        selecionado: true,
                        aoTocar: () {
                          // Já está na tela Agenda.
                        },
                      ),

                      _ItemMenu(
                        icone: Icons.people_outline,
                        texto: 'Famílias',
                        aoTocar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TelaFamilias(modoTecnico: true),
                            ),
                          );
                        },
                      ),

                      _ItemMenu(
                        icone: Icons.groups_outlined,
                        texto: 'Equipe',
                        aoTocar: () {
                          Navigator.push(
                            context,
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

/// Quadro de erro com opcao de tentar novamente.
class _QuadroErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback aoTentarNovamente;

  const _QuadroErro({required this.mensagem, required this.aoTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Column(
          children: [
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: azulTexto, fontSize: 11),
            ),
            TextButton(
              onPressed: aoTentarNovamente,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: verde),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CARTÃO DE RESUMO

class _CartaoResumo extends StatelessWidget {
  final IconData icone;
  final String quantidade;
  final String titulo;
  final Color cor;
  final Color corIcone;

  const _CartaoResumo({
    required this.icone,
    required this.quantidade,
    required this.titulo,
    required this.cor,
    required this.corIcone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borda),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icone, color: corIcone, size: 17),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quantidade,
                  style: const TextStyle(
                    color: azulEscuro,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: azulTexto, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CARTÃO DE CADA VISITA

class _CartaoVisita extends StatelessWidget {
  final String horario;
  final String familia;
  final String endereco;
  final String tipo;
  final String status;
  final VoidCallback aoTocar;

  const _CartaoVisita({
    required this.horario,
    required this.familia,
    required this.endereco,
    required this.tipo,
    required this.status,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borda),
          borderRadius: BorderRadius.circular(12),
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
            // HORÁRIO E STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  horario,
                  style: const TextStyle(
                    color: azulEscuro,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F5EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: verde,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // NOME DA FAMÍLIA
            Text(
              familia,
              style: const TextStyle(
                color: azulEscuro,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            // ENDEREÇO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: azulTexto,
                  size: 13,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    endereco,
                    style: const TextStyle(color: azulTexto, fontSize: 9),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // TIPO E DETALHES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tipo,
                    style: const TextStyle(color: azulTexto, fontSize: 9),
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver detalhes',
                      style: TextStyle(
                        color: verde,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: verde, size: 17),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ITEM DO MENU INFERIOR

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String texto;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _ItemMenu({
    required this.icone,
    required this.texto,
    required this.aoTocar,
    this.selecionado = false,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? verde : azulTexto;

    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cor, size: 19),
            const SizedBox(height: 4),
            Text(
              texto,
              style: TextStyle(
                color: cor,
                fontSize: 9,
                fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
