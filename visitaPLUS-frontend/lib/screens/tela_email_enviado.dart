import 'package:flutter/material.dart';

import '../api/api.dart';

import 'tela_nova_senha.dart';

class TelaEmailEnviado extends StatelessWidget {
  const TelaEmailEnviado({super.key, required this.email});

  final String email;

  String get _emailMascarado {
    final partes = email.split('@');
    if (partes.length != 2 || partes[0].isEmpty) return email;
    return '${partes[0][0]}•••••••@${partes[1]}';
  }

  Future<void> _reenviar(BuildContext context) async {
    try {
      await AutenticacaoApi.recuperarSenha(email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('E-mail reenviado.')));
    } on ExcecaoApi catch (erro) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF008577);
    const azulEscuro = Color(0xFF142A40);
    const azulTexto = Color(0xFF647895);
    const azulPainel = Color(0xFFEAF1F8);
    const azulIcone = Color(0xFF174A78);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const Spacer(flex: 4),

              // Ícone de sucesso
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F6F0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFF168363),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 17),

              const Text(
                'Confira seu e-mail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: azulEscuro,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enviamos as orientações para\n'
                '$_emailMascarado. Verifique\n'
                'também a pasta de spam.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: azulTexto,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 17),

              // Painel de próximo passo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: azulPainel,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: azulIcone, size: 14),
                    SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Próximo passo',
                            style: TextStyle(
                              color: azulIcone,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'O link poderá ser usado uma única vez e '
                            'ficará disponível por tempo limitado.',
                            style: TextStyle(
                              color: azulIcone,
                              fontSize: 9,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              // Voltar ao login
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => TelaNovaSenha(email: email),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verde,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Voltar ao login',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),

              const SizedBox(height: 7),

              // Reenviar e-mail
              TextButton(
                onPressed: () => _reenviar(context),
                style: TextButton.styleFrom(foregroundColor: verde),
                child: const Text(
                  'Reenviar e-mail',
                  style: TextStyle(fontSize: 10),
                ),
              ),

              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }
}
