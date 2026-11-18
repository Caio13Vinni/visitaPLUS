import 'package:flutter/material.dart';

import '../api/api.dart';

import 'formatos.dart';

import 'tela_historico_visitas.dart';

import 'tela_resultado_visita.dart';

import 'tela_equipe.dart';

import 'tela_agenda_equipe.dart';

import 'tela_familias.dart';

import 'tela_home_coordenador.dart';

class TelaInformacoesVisita extends StatelessWidget {
  final Visita visita;
  final Familia? familia;

  const TelaInformacoesVisita({
    super.key,
    required this.visita,
    this.familia,
  });

  static const verde = Color(0xFF008577);
  static const azulEscuro = Color(0xFF142A40);
  static const azulTexto = Color(0xFF647895);
  static const fundo = Color(0xFFF3F7FA);
  static const borda = Color(0xFFD9E2EC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(17, 22, 17, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações da visita',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Resumo e próximos passos',
                      style: TextStyle(color: azulTexto, fontSize: 11),
                    ),

                    const SizedBox(height: 30),

                    // Visita agendada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: const Color(0xFF092D55),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  visita.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                fmtData(visita.dataVisita),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(width: 7),
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                fmtHora(visita.horario),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      familia?.nomeReferencia ?? 'Família',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      familia?.endereco ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFFD9E5F2),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.family_restroom,
                                  color: verde,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 17),
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TelaResultadoVisita(visita: visita),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: azulEscuro,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Ver resumo da visita',
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

                    const SizedBox(height: 25),

                    const Text(
                      'Detalhes do agendamento',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Objetivo e prioridade
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borda),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: verde,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${fmtData(visita.dataVisita)} às '
                                '${fmtHora(visita.horario)}',
                                style: const TextStyle(
                                  color: azulEscuro,
                                  fontSize: 10,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F6F0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Prioridade ${visita.prioridade.toLowerCase()}',
                                  style: const TextStyle(
                                    color: Color(0xFF168363),
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Objetivo',
                            style: TextStyle(
                              color: azulEscuro,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            visita.objetivo,
                            style: const TextStyle(
                              color: azulEscuro,
                              fontSize: 9,
                              height: 1.35,
                            ),
                          ),
                          if (visita.motivoCancelamento != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Cancelada: ${visita.motivoCancelamento}',
                              style: const TextStyle(
                                color: Color(0xFFB23A3A),
                                fontSize: 9,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 27),

                    const Text(
                      'Histórico de visitas',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Histórico
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TelaHistoricoVisitas(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: borda),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                color: verde,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Ver todas as visitas',
                                    style: TextStyle(
                                      color: azulEscuro,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: azulTexto,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Barra inferior
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: borda)),
              ),
              padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ItemMenuVisita(
                    icone: Icons.home_outlined,
                    titulo: 'Início',
                    aoTocar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaHomeCoordenador(),
                        ),
                      );
                    },
                  ),

                  _ItemMenuVisita(
                    icone: Icons.calendar_month_outlined,
                    titulo: 'Agenda',
                    aoTocar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaAgendaEquipe(),
                        ),
                      );
                    },
                  ),

                  _ItemMenuVisita(
                    icone: Icons.people_outline,
                    titulo: 'Famílias',
                    selecionado: true,
                    aoTocar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TelaFamilias()),
                      );
                    },
                  ),

                  _ItemMenuVisita(
                    icone: Icons.groups_outlined,
                    titulo: 'Equipe',
                    aoTocar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TelaEquipe()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemMenuVisita extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _ItemMenuVisita({
    required this.icone,
    required this.titulo,
    this.selecionado = false,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado
        ? TelaInformacoesVisita.verde
        : TelaInformacoesVisita.azulTexto;

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
