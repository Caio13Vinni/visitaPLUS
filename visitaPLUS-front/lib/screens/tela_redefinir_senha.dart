import 'package:flutter/material.dart';

import '../services/api_excecao.dart';
import '../services/visita_api.dart';

import 'tela_senha_alterada.dart';

/// Redefinição de senha com o código enviado por e-mail
/// (POST /api/v1/auth/recuperar-senha/redefinir).
class TelaRedefinirSenha extends StatefulWidget {
  final String email;

  const TelaRedefinirSenha({super.key, required this.email});

  @override
  State<TelaRedefinirSenha> createState() => _TelaRedefinirSenhaState();
}

class _TelaRedefinirSenhaState extends State<TelaRedefinirSenha> {
  late final TextEditingController _emailController;
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  bool _mostrarSenha = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _redefinir() async {
    final email = _emailController.text.trim().toLowerCase();
    final codigo = _codigoController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || codigo.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail, código e nova senha.')),
      );
      return;
    }

    if (senha != _confirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      await VisitaApi.redefinirSenha(
        email: email,
        codigo: codigo,
        novaSenha: senha,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TelaSenhaAlterada()),
        (route) => false,
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

  InputDecoration _decoracao({
    required String dica,
    required IconData icone,
    Widget? sufixo,
  }) {
    const verde = Color(0xFF008577);
    const cinza = Color(0xFF647895);
    const borda = Color(0xFFD9E2EC);

    return InputDecoration(
      hintText: dica,
      hintStyle: const TextStyle(color: cinza, fontSize: 13),
      prefixIcon: Icon(icone, size: 20, color: cinza),
      suffixIcon: sufixo,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 17,
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
        borderSide: const BorderSide(color: verde, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF008577);
    const azulEscuro = Color(0xFF142A40);
    const cinza = Color(0xFF647895);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, size: 18, color: verde),
                label: const Text(
                  'Voltar',
                  style: TextStyle(color: verde, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'SEGURANÇA',
                style: TextStyle(
                  color: verde,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Redefinir senha',
                style: TextStyle(
                  color: azulEscuro,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Informe o código recebido por e-mail '
                'e escolha uma nova senha.',
                style: TextStyle(color: cinza, fontSize: 14, height: 1.4),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    _decoracao(dica: 'E-mail', icone: Icons.mail_outline),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                decoration: _decoracao(
                  dica: 'Código de recuperação',
                  icone: Icons.pin_outlined,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _senhaController,
                obscureText: !_mostrarSenha,
                decoration: _decoracao(
                  dica: 'Nova senha',
                  icone: Icons.lock_outline,
                  sufixo: IconButton(
                    onPressed: () =>
                        setState(() => _mostrarSenha = !_mostrarSenha),
                    icon: Icon(
                      _mostrarSenha
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: cinza,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _confirmarController,
                obscureText: !_mostrarSenha,
                decoration: _decoracao(
                  dica: 'Confirmar nova senha',
                  icone: Icons.lock_outline,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _redefinir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Redefinir senha',
                          style: TextStyle(fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
