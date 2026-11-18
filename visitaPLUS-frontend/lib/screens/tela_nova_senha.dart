import 'package:flutter/material.dart';

import '../api/api.dart';

import 'tela_senha_alterada.dart';

class TelaNovaSenha extends StatefulWidget {
  const TelaNovaSenha({super.key, this.email, this.primeiroAcesso = false});

  /// E-mail da conta (fluxo de recuperacao — RF03).
  final String? email;

  /// `true` quando a troca e exigida no primeiro acesso (usa a senha
  /// provisoria em vez do codigo enviado por e-mail).
  final bool primeiroAcesso;

  @override
  State<TelaNovaSenha> createState() => _TelaNovaSenhaState();
}

class _TelaNovaSenhaState extends State<TelaNovaSenha> {
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final TextEditingController _confirmarController = TextEditingController();

  bool _mostrarSenha = false;
  bool _mostrarConfirmacao = false;
  bool _salvando = false;

  bool get _senhaValida {
    final senha = _senhaController.text;

    return senha.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(senha) &&
        RegExp(r'[0-9]').hasMatch(senha);
  }

  bool get _senhasCoincidem {
    return _senhaController.text.isNotEmpty &&
        _senhaController.text == _confirmarController.text;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_senhaValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Use pelo menos 8 caracteres, '
            'uma letra maiúscula e um número.',
          ),
        ),
      );
      return;
    }

    if (!_senhasCoincidem) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }

    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.primeiroAcesso
                ? 'Informe a senha provisória.'
                : 'Informe o código recebido por e-mail.',
          ),
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      if (widget.primeiroAcesso) {
        await AutenticacaoApi.trocarSenha(codigo, _senhaController.text);
      } else {
        await AutenticacaoApi.redefinirSenha(
          widget.email ?? '',
          codigo,
          _senhaController.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TelaSenhaAlterada()),
      );
    } on ExcecaoApi catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF008577);
    const azulEscuro = Color(0xFF142A40);
    const cinza = Color(0xFF647895);
    const borda = Color(0xFFD9E2EC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: verde,
                      ),
                      label: const Text(
                        'Cancelar',
                        style: TextStyle(color: verde, fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      widget.primeiroAcesso ? 'PRIMEIRO ACESSO' : 'RECUPERAÇÃO',
                      style: const TextStyle(
                        color: verde,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Crie uma nova senha',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      widget.primeiroAcesso
                          ? 'Para proteger sua conta, escolha uma senha '
                                'diferente da provisória enviada pelo '
                                'Coordenador.'
                          : 'Informe o código enviado para o seu e-mail '
                                'e escolha a nova senha.',
                      style: const TextStyle(
                        color: cinza,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      widget.primeiroAcesso
                          ? 'Senha provisória'
                          : 'Código de verificação',
                      style: const TextStyle(
                        color: azulEscuro,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: _codigoController,
                      obscureText: widget.primeiroAcesso,
                      keyboardType: widget.primeiroAcesso
                          ? TextInputType.visiblePassword
                          : TextInputType.number,
                      decoration: InputDecoration(
                        hintText: widget.primeiroAcesso
                            ? 'Senha enviada pelo Coordenador'
                            : 'Código recebido por e-mail',
                        hintStyle: const TextStyle(color: cinza, fontSize: 13),
                        prefixIcon: Icon(
                          widget.primeiroAcesso
                              ? Icons.lock_outline
                              : Icons.pin_outlined,
                          color: verde,
                          size: 20,
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
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Nova senha',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: _senhaController,
                      obscureText: !_mostrarSenha,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: verde,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _mostrarSenha = !_mostrarSenha;
                            });
                          },
                          icon: Icon(
                            _mostrarSenha
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: cinza,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borda),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _senhaController.text.isEmpty
                                ? borda
                                : verde,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: verde,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    const Text(
                      'Confirmar senha',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    TextField(
                      controller: _confirmarController,
                      obscureText: !_mostrarConfirmacao,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: cinza,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _mostrarConfirmacao = !_mostrarConfirmacao;
                            });
                          },
                          icon: Icon(
                            _mostrarConfirmacao
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: cinza,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borda),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                _confirmarController.text.isNotEmpty &&
                                    !_senhasCoincidem
                                ? Colors.red
                                : borda,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: verde,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: borda),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sua senha deve ter:',
                            style: TextStyle(
                              color: azulEscuro,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                _senhaController.text.length >= 8
                                    ? Icons.check
                                    : Icons.check,
                                color: verde,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '8 caracteres ou mais',
                                style: TextStyle(
                                  color: cinza,
                                  fontSize: 11,
                                  fontWeight: _senhaController.text.length >= 8
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(Icons.check, color: verde, size: 15),
                              const SizedBox(width: 6),
                              Text(
                                'Uma letra maiúscula e um número',
                                style: TextStyle(
                                  color: cinza,
                                  fontSize: 11,
                                  fontWeight: _senhaValida
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _salvando ? null : _salvar,
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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Salvar nova senha',
                                style: TextStyle(fontSize: 14),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
