import 'package:flutter/material.dart';

import '../api/api.dart';

import 'tela_informacoes_visita.dart';

class TelaDetalhesFamilia extends StatelessWidget {
  final Familia familia;
  final bool modoTecnico;

  const TelaDetalhesFamilia({
    super.key,
    required this.familia,
    this.modoTecnico = false,
  });

  static const verde = Color(0xFF008577);
  static const azulEscuro = Color(0xFF142A40);
  static const azulTexto = Color(0xFF647895);
  static const fundo = Color(0xFFF3F7FA);
  static const borda = Color(0xFFD9E2EC);

  /// Abre a proxima visita agendada da familia, quando existir.
  Future<void> _abrirVisita(BuildContext context) async {
    try {
      final visitas = await VisitasApi.listar(
        idFamilia: familia.id,
        status: StatusVisita.agendada,
      );
      if (!context.mounted) return;
      if (visitas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma visita agendada para esta família.'),
          ),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              TelaInformacoesVisita(visita: visitas.first, familia: familia),
        ),
      );
    } on ExcecaoApi catch (erro) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    }
  }

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
                      'Detalhes da família',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Informações da família',
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
                                  familia.nomeReferencia,
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
                                        familia.endereco,
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        color: verde,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        familia.status,
                                        style: const TextStyle(
                                          color: verde,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
                      'Dados da família',
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
                            icone: Icons.home,
                            titulo: 'Endereço',
                            descricao: familia.endereco,
                          ),
                          _InformacaoFamilia(
                            icone: Icons.call,
                            titulo: 'Contato',
                            descricao: familia.contato,
                          ),
                          _InformacaoFamilia(
                            icone: Icons.tag,
                            titulo: 'Código da família',
                            descricao: familia.codigo,
                          ),
                          _InformacaoFamilia(
                            icone: Icons.info,
                            titulo: 'Situação do cadastro',
                            descricao: familia.status,
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
                        onPressed: () => _abrirVisita(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'Informações da visita',
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
                bottom: BorderSide(color: TelaDetalhesFamilia.borda),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 35,
            child: Icon(icone, color: TelaDetalhesFamilia.verde, size: 23),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: TelaDetalhesFamilia.azulEscuro,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descricao,
                  style: const TextStyle(
                    color: TelaDetalhesFamilia.azulTexto,
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

class _ItemMenuDetalhes extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _ItemMenuDetalhes({
    required this.icone,
    required this.titulo,
    this.selecionado = false,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado
        ? TelaDetalhesFamilia.verde
        : TelaDetalhesFamilia.azulTexto;

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
