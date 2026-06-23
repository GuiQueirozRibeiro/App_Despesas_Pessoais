import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarefas_geo/screens/about_screen.dart';

void main() {
  testWidgets('exibe título, autor e tecnologias', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));

    expect(find.text('Tarefas Geo'), findsOneWidget);
    expect(find.text('Guilherme Queiroz Ribeiro'), findsOneWidget);
    expect(find.textContaining('geo_tools'), findsOneWidget);
    // "Firestore" aparece tanto em "Tecnologias" quanto em "Como funciona".
    expect(find.textContaining('Firestore'), findsWidgets);
  });
}
