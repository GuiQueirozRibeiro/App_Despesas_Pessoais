import 'dart:io' show Platform;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tarefas_geo/main.dart';
import 'package:tarefas_geo/repositories/firestore_task_repository.dart';

/// Teste de interface end-to-end.
///
/// Executa o app inteiro (rotas, Provider, telas) usando um Firestore em
/// memória — sem depender de rede nem de credenciais reais.
///
/// Os *finders* são **agnósticos de plataforma**: no iOS a UI usa widgets
/// Cupertino (sem FAB), no Android usa Material. Veja [_addButton]/[_aboutButton].
///
/// Rode com:
///   flutter test integration_test/app_test.dart   (com simulador/emulador)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => initializeDateFormatting('pt_BR'));

  // No iOS o botão de adicionar fica na CupertinoNavigationBar; no Android, no FAB.
  Finder addButton() => Platform.isIOS
      ? find.byIcon(CupertinoIcons.add)
      : find.byType(FloatingActionButton);

  Finder aboutButton() => Platform.isIOS
      ? find.byIcon(CupertinoIcons.info)
      : find.byIcon(Icons.info_outline);

  testWidgets('fluxo completo: criar → listar → abrir detalhe → excluir',
      (tester) async {
    final repo = FirestoreTaskRepository(FakeFirebaseFirestore());
    await tester.pumpWidget(TarefasGeoApp(taskRepository: repo));
    await tester.pumpAndSettle();

    // 1. Começa vazio.
    expect(find.text('Nenhuma tarefa cadastrada'), findsOneWidget);

    // 2. Abre o formulário.
    await tester.tap(addButton());
    await tester.pumpAndSettle();
    expect(find.text('Nova Tarefa'), findsOneWidget);

    // 3. Preenche o nome (EditableText cobre TextField e CupertinoTextField).
    await tester.enterText(find.byType(EditableText).first, 'Tarefa de integração');
    await tester.tap(find.text('Criar Tarefa'));
    await tester.pumpAndSettle();

    // 4. A tarefa aparece na lista (veio do stream do Firestore fake).
    expect(find.text('Tarefa de integração'), findsOneWidget);

    // 5. Abre o detalhe.
    await tester.tap(find.text('Tarefa de integração'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhe da Tarefa'), findsOneWidget);

    // 6. Exclui pela tela de detalhe (AppBar é Material em ambas plataformas).
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    // 7. Volta para a Home, novamente vazia.
    expect(find.text('Nenhuma tarefa cadastrada'), findsOneWidget);
  });

  testWidgets('navega para a tela Sobre', (tester) async {
    final repo = FirestoreTaskRepository(FakeFirebaseFirestore());
    await tester.pumpWidget(TarefasGeoApp(taskRepository: repo));
    await tester.pumpAndSettle();

    await tester.tap(aboutButton());
    await tester.pumpAndSettle();

    expect(find.text('Tarefas com localização e clima'), findsOneWidget);
  });
}
