import 'package:flutter/material.dart';

import '../api/api.dart';

import 'formatos.dart';

import 'tela_detalhe_visita_tecnico.dart';
import 'tela_detalhes_familia.dart';
import 'tela_historico_visitas.dart';

const Color verdeVisita = Color(0xFF008577);
const Color azulVisita = Color(0xFF142A40);
const Color cinzaVisita = Color(0xFF647895);
const Color bordaVisita = Color(0xFFD9E2EC);
const Color fundoVisita = Color(0xFFF4F7FA);

class TelaInformacoesVisita extends StatefulWidget {
  final Visita visita;
  final Familia? familia;

  const TelaInformacoesVisita({
    super.key,
    required this.visita,
    this.familia,
  });

  @override
  State<TelaInformacoesVisita> createState() => _TelaInformacoesVisitaState();
}

class _TelaInformacoesVisitaState extends State<TelaInformacoesVisita> {
  bool _iniciando = false;

  /// Inicia o registro da visita na API (UC05) e abre a tela de execucao.
  Future<void> _iniciarVisita() async {
    setState(() => _iniciando = true);

    try {
      final registro = await RegistrosApi.iniciar(widget.visita.id);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TelaDetalheVisitaTecnico(
            visita: widget.visita,
            familia: widget.familia,
            registro: registro,
          ),
        ),
      );
    } on ExcecaoApi catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    } finally {
      if (mounted) setState(() => _iniciando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoVisita,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações da visita',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Resumo e próximos passos',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Família',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: azulVisita,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _cartaoFamilia(),

                    const SizedBox(height: 16),

                    const Text(
                      'Data e hora',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: azulVisita,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _cartaoData(),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _iniciando ? null : _iniciarVisita,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verdeVisita,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: _iniciando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Iniciar visita',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.chevron_right, size: 20),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      'Histórico de visitas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: azulVisita,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _cartaoHistorico(),
                  ],
                ),
              ),
            ),

            _barraNavegacao(),
          ],
        ),
      ),
    );
  }

  Widget _cartaoFamilia() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: widget.familia == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        TelaDetalhesFamilia(familia: widget.familia!),
                  ),
                );
              },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: bordaVisita),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F4F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: verdeVisita,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.familia?.nomeReferencia ?? 'Família',
                      style: const TextStyle(
                        color: azulVisita,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: cinzaVisita,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            widget.familia?.endereco ?? '',
                            style: const TextStyle(
                              color: cinzaVisita,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: verdeVisita),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartaoData() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: bordaVisita),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: verdeVisita,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                '${fmtData(widget.visita.dataVisita)} às '
                '${fmtHora(widget.visita.horario)}',
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Objetivo',
            style: TextStyle(fontSize: 9, color: Colors.black87),
          ),
          const SizedBox(height: 5),
          Text(
            widget.visita.objetivo,
            style: const TextStyle(fontSize: 9, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _cartaoHistorico() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  TelaHistoricoVisitas(idFamilia: widget.visita.idFamilia),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: bordaVisita),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: verdeVisita, size: 20),
              SizedBox(width: 30),
              Expanded(
                child: Text(
                  'Ver todas as visitas',
                  style: TextStyle(fontSize: 9, color: Colors.black87),
                ),
              ),
              Icon(Icons.chevron_right, color: azulVisita, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barraNavegacao() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: bordaVisita)),
      ),
      child: const SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ItemNavegacao(icone: Icons.home_outlined, titulo: 'Início'),
              _ItemNavegacao(
                icone: Icons.calendar_month_outlined,
                titulo: 'Agenda',
              ),
              _ItemNavegacao(
                icone: Icons.people_outline,
                titulo: 'Famílias',
                selecionado: true,
              ),
              _ItemNavegacao(icone: Icons.groups_outlined, titulo: 'Equipe'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNavegacao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;

  const _ItemNavegacao({
    required this.icone,
    required this.titulo,
    this.selecionado = false,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? verdeVisita : cinzaVisita;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, color: cor, size: 19),
        const SizedBox(height: 3),
        Text(
          titulo,
          style: TextStyle(
            color: cor,
            fontSize: 8,
            fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
