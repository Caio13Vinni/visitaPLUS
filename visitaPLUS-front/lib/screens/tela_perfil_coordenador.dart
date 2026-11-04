import 'package:flutter/material.dart';

import '../services/api_excecao.dart';
import '../services/visita_api.dart';

import 'tela_login.dart';

class TelaPerfilCoordenador extends StatelessWidget {
  final String nome;
  final String matricula;
  final String unidade;
  final String funcao;
  final String email;
  final String telefone;
  final String visitas;
  final String acompanhamentos;

  const TelaPerfilCoordenador({
    super.key,
    this.nome = 'Renato Santos',
    this.matricula = '12345-6',
    this.unidade = 'CRAS Gama',
    this.funcao = 'Coordenador',
    this.email = 'renato.silva@instituicao.gov.br',
    this.telefone = '(61) 98324-9342',
    this.visitas = '128',
    this.acompanhamentos = '12',
  });

  static const verde = Color(0xFF008577);

  static const azulEscuro = Color(0xFF142A40);
  static const azulTexto = Color(0xFF647895);
  static const borda = Color(0xFFD9E2EC);
  static const fundo = Color(0xFFF4F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(17, 16, 17, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perfil do profissional',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Seus dados e configurações',
                      style: TextStyle(color: azulTexto, fontSize: 11),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF072C5C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF092D55),
                            child: Text(
                              _iniciais(nome),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Dados Profissionais',
                      style: TextStyle(
                        color: azulEscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _card([
                      _linha(Icons.badge_outlined, 'Matrícula:', matricula),
                      _divider(),
                      _linha(Icons.location_on_outlined, 'Unidade:', unidade),
                      _divider(),
                      _linha(Icons.work_outline, 'Função:', funcao),
                    ]),

                    const SizedBox(height: 16),

                    const Text(
                      'Contatos',
                      style: TextStyle(
                        color: azulEscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _card([
                      _linha(Icons.email_outlined, '', email),
                      _divider(),
                      _linha(Icons.phone_outlined, '', telefone),
                    ]),

                    const SizedBox(height: 16),

                    const Text(
                      'Visitas Concluídas',
                      style: TextStyle(
                        color: azulEscuro,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borda),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _IndicadorPerfil(
                              icone: Icons.check_circle_outline,
                              valor: visitas,
                              texto: 'Visitas concluídas',
                              cor: verde,
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                            child: VerticalDivider(color: borda),
                          ),
                          Expanded(
                            child: _IndicadorPerfil(
                              icone: Icons.people_outline,
                              valor: acompanhamentos,
                              texto: 'Profissionais ativos',
                              cor: verde,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _mostrarTrocaSenha(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: verde,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Alterar senha',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _sair(context),
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text(
                          'Sair da conta',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB3261E),
                          side: const BorderSide(color: Color(0xFFB3261E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: borda)),
              ),
              padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ItemMenu(Icons.home_outlined, 'Início', false),
                  _ItemMenu(Icons.calendar_month_outlined, 'Agenda', false),
                  _ItemMenu(Icons.people_outline, 'Famílias', false),
                  _ItemMenu(Icons.groups_outlined, 'Equipe', false),
                  _ItemMenu(Icons.more_horiz, 'Mais', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _iniciais(String nome) {
    final partes =
        nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  /// POST /auth/logout: encerra a sessão no servidor e volta ao login.
  static Future<void> _sair(BuildContext context) async {
    try {
      await VisitaApi.logout();
    } on ApiExcecao {
      // Mesmo se a chamada falhar, a sessão local já foi limpa.
    }
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const TelaLogin()),
      (route) => false,
    );
  }

  static void _mostrarTrocaSenha(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _DialogoTrocaSenha(),
    );
  }

  static Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borda),
      ),
      child: Column(children: children),
    );
  }

  static Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1),
  );

  static Widget _linha(IconData icone, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: verde, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (titulo.isNotEmpty)
                Text(
                  titulo,
                  style: const TextStyle(fontSize: 10, color: azulTexto),
                ),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 12,
                  color: azulEscuro,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IndicadorPerfil extends StatelessWidget {
  final IconData icone;
  final String valor;
  final String texto;
  final Color cor;

  const _IndicadorPerfil({
    required this.icone,
    required this.valor,
    required this.texto,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, color: cor, size: 26),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: TelaPerfilCoordenador.azulEscuro,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: TelaPerfilCoordenador.azulTexto,
          ),
        ),
      ],
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool ativo;

  const _ItemMenu(this.icone, this.titulo, this.ativo);

  @override
  Widget build(BuildContext context) {
    final cor = ativo
        ? TelaPerfilCoordenador.verde
        : TelaPerfilCoordenador.azulTexto;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, color: cor, size: 18),
        const SizedBox(height: 3),
        Text(
          titulo,
          style: TextStyle(
            color: cor,
            fontSize: 8,
            fontWeight: ativo ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Diálogo de troca de senha (POST /auth/trocar-senha).
class _DialogoTrocaSenha extends StatefulWidget {
  const _DialogoTrocaSenha();

  @override
  State<_DialogoTrocaSenha> createState() => _DialogoTrocaSenhaState();
}

class _DialogoTrocaSenhaState extends State<_DialogoTrocaSenha> {
  final _atualController = TextEditingController();
  final _novaController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _atualController.dispose();
    _novaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (_atualController.text.isEmpty || _novaController.text.isEmpty) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await VisitaApi.trocarSenha(
        senhaAtual: _atualController.text,
        novaSenha: _novaController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso.')),
      );
    } on ApiExcecao catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro.mensagem)),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alterar senha', style: TextStyle(fontSize: 15)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _atualController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha atual',
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _novaController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nova senha',
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _confirmar,
          child: _salvando
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
