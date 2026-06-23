import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_geo/models/task.dart';
import 'package:tarefas_geo/providers/task_provider.dart';
import 'package:tarefas_geo/repositories/firestore_task_repository.dart';
import 'package:tarefas_geo/screens/task_form_screen.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Widget wrap(FirestoreTaskRepository repo, {Task? existing}) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(repo),
      child: MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => TaskFormScreen(existing: existing),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('cria uma tarefa nova e salva no repositório', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final repo = FirestoreTaskRepository(firestore);

    await tester.pumpWidget(wrap(repo));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Nova Tarefa'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Tarefa via form');
    await tester.tap(find.text('Criar Tarefa'));
    await tester.pumpAndSettle();

    // Voltou para a tela anterior.
    expect(find.text('abrir'), findsOneWidget);
    // Persistiu no Firestore.
    final docs = await firestore.collection('tasks').get();
    expect(docs.docs, hasLength(1));
    expect(docs.docs.first['name'], 'Tarefa via form');
  });

  testWidgets('edita uma tarefa existente', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final repo = FirestoreTaskRepository(firestore);
    final existing =
        Task(id: 'e1', name: 'Antiga', dateTime: DateTime(2026, 6, 22, 10));
    await repo.add(existing);

    await tester.pumpWidget(wrap(repo, existing: existing));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Editar Tarefa'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Renomeada');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();

    final doc = await firestore.collection('tasks').doc('e1').get();
    expect(doc.data()!['name'], 'Renomeada');
  });
}
