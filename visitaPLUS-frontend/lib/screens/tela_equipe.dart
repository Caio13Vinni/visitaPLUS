import 'package:flutter/material.dart';

import '../api/api.dart';

import 'tela_novo_profissional.dart';

import 'tela_agenda_equipe.dart';
import 'tela_familias.dart';
import 'tela_home_coordenador.dart';

class TelaEquipe extends StatefulWidget {
  const TelaEquipe({super.key});

  @override
  State<TelaEquipe> createState() => _TelaEquipeState();
}

class _TelaEquipeState extends State<TelaEquipe> {
  static const verde = Color(0xFF008577);
  static const azulEscuro = Color(0xFF142A40);
  static const azulTexto = Color(0xFF647895);
  static const fundo = Color(0xFFF3F7FA);
  static const borda = Color(0xFFD9E2EC);

  final TextEditingController _pesquisaController = TextEditingController();

  String _filtro = 'Todos';

  late Future<List<Usuario>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = ProfissionaisApi.listar();
  }

  void _recarregar() {
    setState(() => _futuro = ProfissionaisApi.listar());
  }

  /// Rotulo legivel do perfil vindo da API ('Coordenador'/'Tecnico').
  static String rotuloPerfil(String perfil) =>
      perfil == PerfilUsuario.tecnico ? 'Técnico de referência' : perfil;

  /// Ativa/inativa a conta do profissional (RN04).
  Future<void> _alterarStatus(Usuario profissional) async {
    final ativo = profissional.status == StatusUsuario.ativo;
    final novoStatus = ativo ? StatusUsuario.inativo : StatusUsuario.ativo;

    try {
      await ProfissionaisApi.alterarStatus(profissional.id, novoStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${profissional.nome} agora está ${novoStatus.toLowerCase()}.',
          ),
        ),
      );
      _recarregar();
    } on ExcecaoApi catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    }
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = _pesquisaController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(17, 20, 17, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Equipe',
                                style: TextStyle(
                                  color: azulEscuro,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Profissionais cadastrados no sistema',
                                style: TextStyle(
                                  color: azulTexto,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TelaNovoProfissional(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add_alt_1, size: 15),
                            label: const Text(
                              'Cadastrar',
                              style: TextStyle(fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: verde,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Campo de pesquisa
                    TextField(
                      controller: _pesquisaController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Pesquisar por nome ou função',
                        hintStyle: const TextStyle(
                          color: azulTexto,
                          fontSize: 11,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: azulTexto,
                          size: 20,
                        ),
                        suffixIcon: _pesquisaController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _pesquisaController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 17,
                                  color: azulTexto,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borda),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borda),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: verde,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    // Filtros por perfil
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FiltroEquipe(
                            texto: 'Todos',
                            selecionado: _filtro == 'Todos',
                            aoTocar: () => setState(() {
                              _filtro = 'Todos';
                            }),
                          ),
                          const SizedBox(width: 7),
                          _FiltroEquipe(
                            texto: 'Coordenador',
                            selecionado: _filtro == 'Coordenador',
                            aoTocar: () => setState(() {
                              _filtro = 'Coordenador';
                            }),
                          ),
                          const SizedBox(width: 7),
                          _FiltroEquipe(
                            texto: 'Técnico de referência',
                            selecionado: _filtro == 'Técnico de referência',
                            aoTocar: () => setState(() {
                              _filtro = 'Técnico de referência';
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 23),

                    // Lista de profissionais
                    Expanded(
                      child: FutureBuilder<List<Usuario>>(
                        future: _futuro,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    snapshot.error is ExcecaoApi
                                        ? (snapshot.error as ExcecaoApi)
                                              .mensagem
                                        : 'Não foi possível carregar '
                                              'a equipe.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: azulTexto,
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _recarregar,
                                    child: const Text(
                                      'Tentar novamente',
                                      style: TextStyle(color: verde),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(color: verde),
                            );
                          }

                          final profissionaisFiltrados = snapshot.data!.where((
                            profissional,
                          ) {
                            final nome = profissional.nome.toLowerCase();
                            final perfil = rotuloPerfil(
                              profissional.perfil,
                            ).toLowerCase();

                            final correspondePesquisa =
                                nome.contains(termo) || perfil.contains(termo);

                            final correspondeFiltro =
                                _filtro == 'Todos' ||
                                rotuloPerfil(profissional.perfil) == _filtro;

                            return correspondePesquisa && correspondeFiltro;
                          }).toList();

                          if (profissionaisFiltrados.isEmpty) {
                            return const Center(
                              child: Text(
                                'Nenhum profissional encontrado.',
                                style: TextStyle(
                                  color: azulTexto,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            color: verde,
                            onRefresh: () async => _recarregar(),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: profissionaisFiltrados.length,
                              itemBuilder: (context, indice) {
                                final profissional =
                                    profissionaisFiltrados[indice];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 11),
                                  child: _CardProfissional(
                                    profissional: profissional,
                                    aoAlterarStatus: () =>
                                        _alterarStatus(profissional),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navegação inferior
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: borda)),
              ),
              padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ItemMenuEquipe(
                    icone: Icons.home_outlined,
                    titulo: 'Início',
                    aoTocar: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TelaHomeCoordenador(),
                        ),
                      );
                    },
                  ),

                  _ItemMenuEquipe(
                    icone: Icons.calendar_month_outlined,
                    titulo: 'Agenda',
                    aoTocar: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TelaAgendaEquipe(),
                        ),
                      );
                    },
                  ),

                  _ItemMenuEquipe(
                    icone: Icons.people_outline,
                    titulo: 'Famílias',
                    aoTocar: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => TelaFamilias()),
                      );
                    },
                  ),

                  _ItemMenuEquipe(
                    icone: Icons.groups_outlined,
                    titulo: 'Equipe',
                    selecionado: true,
                    aoTocar: () {},
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

class _CardProfissional extends StatelessWidget {
  final Usuario profissional;
  final VoidCallback aoAlterarStatus;

  const _CardProfissional({
    required this.profissional,
    required this.aoAlterarStatus,
  });

  @override
  Widget build(BuildContext context) {
    final nome = profissional.nome;
    final perfil = _TelaEquipeState.rotuloPerfil(profissional.perfil);
    final status = profissional.status;

    final iniciais = nome
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .take(2)
        .map((parte) => parte[0])
        .join()
        .toUpperCase();

    final ativo = status == StatusUsuario.ativo;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD9E2EC)),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: ativo
                    ? const Color(0xFF174A78)
                    : const Color(0xFF9AAEC7),
                child: Text(
                  iniciais,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(
                        color: Color(0xFF142A40),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      perfil,
                      style: const TextStyle(
                        color: Color(0xFF647895),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF647895),
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            profissional.email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF647895),
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: ativo
                          ? const Color(0xFFE4F5EF)
                          : const Color(0xFFEDF1F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 7,
                          color: ativo
                              ? const Color(0xFF168363)
                              : const Color(0xFF8193A8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: ativo
                                ? const Color(0xFF168363)
                                : const Color(0xFF647895),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  InkWell(
                    onTap: aoAlterarStatus,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        ativo ? 'Inativar' : 'Ativar',
                        style: TextStyle(
                          color: ativo
                              ? const Color(0xFFB23A3A)
                              : const Color(0xFF008577),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

class _FiltroEquipe extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _FiltroEquipe({
    required this.texto,
    required this.selecionado,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFF008577) : Colors.white,
          border: Border.all(
            color: selecionado
                ? const Color(0xFF008577)
                : const Color(0xFFD9E2EC),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: selecionado ? Colors.white : const Color(0xFF647895),
            fontSize: 9,
            fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ItemMenuEquipe extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _ItemMenuEquipe({
    required this.icone,
    required this.titulo,
    this.selecionado = false,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? const Color(0xFF008577) : const Color(0xFF647895);

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
