import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:visita_mais/main.dart';

void main() {
  testWidgets('App abre na tela de abertura e chega ao login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VisitaMaisApp());

    // Tela de abertura exibe a logo.
    expect(find.byType(Image), findsWidgets);

    // Apos a animacao de abertura, a tela de login aparece.
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
  });
}
