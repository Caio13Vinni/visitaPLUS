import 'package:flutter/material.dart';

import 'screens/tela_abertura.dart';
import 'screens/tela_login.dart';
import 'services/sessao.dart';

final GlobalKey<NavigatorState> navegadorGlobal = GlobalKey<NavigatorState>();

void main() {
  // Qualquer 401 da API (token/sessão mortos) derruba o app para o login.
  Sessao.instancia.aoExpirar = () {
    navegadorGlobal.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const TelaLogin()),
      (route) => false,
    );
  };

  runApp(const VisitaMaisApp());
}

class VisitaMaisApp extends StatelessWidget {
  const VisitaMaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navegadorGlobal,
      debugShowCheckedModeBanner: false,
      title: 'Visita+',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TelaAbertura(),
    );
  }
}
