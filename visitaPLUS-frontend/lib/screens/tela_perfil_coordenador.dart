import 'package:flutter/material.dart';

import '../api/api.dart';

import 'tela_login.dart';
import 'tela_nova_senha.dart';

/// Tela de perfil do usuario autenticado (coordenador ou tecnico).
class TelaPerfilCoordenador extends StatelessWidget {
  const TelaPerfilCoordenador({super.key});

  static const verde = Color(0xFF008577);

  static const azulEscuro = Color(0xFF142A40);
  static const azulTexto = Color(0xFF647895);
  static const borda = Color(0xFFD9E2EC);
  static const fundo = Color(0xFFF4F7FA);

  static String get _iniciais {
    final partes = (Sessao.usuario?.nome ?? '')
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[partes.length - 1][0]).toUpperCase();
  }

  Future<void> _sair(BuildContext context) async {
    await AutenticacaoApi.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const TelaLogin()),
      (rota) => false,
    );
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
                            radius: 22,
                            backgroundColor: const Color(0xFF092D55),
                            child: Text(
                              _iniciais,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            Sessao.usuario?.nome ?? '',
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
                      _linha(
                        Icons.work_outline,
                        'Função:',
                        Sessao.usuario?.perfil ?? '',
                      ),
                      _divider(),
                      _linha(
                        Icons.verified_user_outlined,
                        'Situação da conta:',
                        Sessao.usuario?.status ?? '',
                      ),
                      _divider(),
                      _linha(
                        Icons.location_on_outlined,
                        'Unidade (ID):',
                        Sessao.usuario?.idUnidade ?? '',
                      ),
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
                      _linha(
                        Icons.email_outlined,
                        '',
                        Sessao.usuario?.email ?? '',
                      ),
                    ]),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TelaNovaSenha(primeiroAcesso: true),
                            ),
                          );
                        },
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
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Edição do perfil será implementada depois.',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: verde,
                          side: const BorderSide(color: verde),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Editar perfil',
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
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text(
                          'Sair da conta',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB23A3A),
                          side: const BorderSide(color: Color(0xFFB23A3A)),
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
                ],
              ),
            ),
          ],
        ),
      ),
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
