import 'package:flutter/material.dart';

import '../api/api.dart';

import 'formatos.dart';

import 'tela_observacoes.dart';

/// Tela de execucao da visita pelo tecnico (UC05): mostra os dados da
/// visita em andamento e leva ao registro de observacoes.
class TelaDetalheVisitaTecnico extends StatelessWidget {
  final Visita visita;
  final Familia? familia;
  final RegistroVisita registro;

  const TelaDetalheVisitaTecnico({
    super.key,
    required this.visita,
    required this.registro,
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
                      'Visita em andamento',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Registro iniciado — preencha as observações',
                      style: TextStyle(color: azulTexto, fontSize: 11),
                    ),

                    const SizedBox(height: 27),

                    // Identificação da família
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borda),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD8EFEB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.family_restroom,
                              color: verde,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  familia?.nomeReferencia ?? 'Família',
                                  style: const TextStyle(
                                    color: azulEscuro,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: azulTexto,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        familia?.endereco ?? '',
                                        style: const TextStyle(
                                          color: azulTexto,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF5F2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    visita.status,
                                    style: const TextStyle(
                                      color: verde,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Dados da visita',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 19),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borda),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Column(
                        children: [
                          _InformacaoFamilia(
                            icone: Icons.calendar_month_outlined,
                            titulo: 'Data e horário',
                            descricao:
                                '${fmtData(visita.dataVisita)} às '
                                '${fmtHora(visita.horario)}',
                          ),
                          _InformacaoFamilia(
                            icone: Icons.flag_outlined,
                            titulo: 'Prioridade',
                            descricao: visita.prioridade,
                          ),
                          _InformacaoFamilia(
                            icone: Icons.info,
                            titulo: 'Objetivo',
                            descricao: visita.objetivo,
                          ),
                          _InformacaoFamilia(
                            icone: Icons.edit_note,
                            titulo: 'Situação do registro',
                            descricao: registro.status,
                            ultima: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TelaObservacoes(
                                visita: visita,
                                registro: registro,
                                familia: familia,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'Preencher observações',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InformacaoFamilia extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final bool ultima;

  const _InformacaoFamilia({
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.ultima = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: ultima
            ? null
            : const Border(
                bottom: BorderSide(color: TelaDetalheVisitaTecnico.borda),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 35,
            child: Icon(icone, color: TelaDetalheVisitaTecnico.verde, size: 23),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: TelaDetalheVisitaTecnico.azulEscuro,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descricao,
                  style: const TextStyle(
                    color: TelaDetalheVisitaTecnico.azulTexto,
                    fontSize: 10,
                    height: 1.35,
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
