import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_geo/components/task_list.dart';
import 'package:tarefas_geo/models/task.dart';
import 'package:tarefas_geo/providers/task_provider.dart';
import 'package:tarefas_geo/repositories/firestore_task_repository.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> pumpList(WidgetTester tester, FirestoreTaskRepository repo) {
    return tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider(repo),
        child: MaterialApp(
          home: Scaffold(
            body: TaskList(onOpen: (_) {}, onRemove: (_) {}),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra o estado vazio quando não há tarefas', (tester) async {
    final repo = FirestoreTaskRepository(FakeFirebaseFirestore());

    await pumpList(tester, repo);
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma tarefa cadastrada'), findsOneWidget);
  });

  testWidgets('lista as tarefas existentes', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final repo = FirestoreTaskRepository(firestore);
    await repo.add(Task(id: '1', name: 'Tarefa Um', dateTime: DateTime(2026, 6, 22, 10)));
    await repo.add(Task(id: '2', name: 'Tarefa Dois', dateTime: DateTime(2026, 6, 23, 10)));

    await pumpList(tester, repo);
    await tester.pumpAndSettle();

    expect(find.text('Tarefa Um'), findsOneWidget);
    expect(find.text('Tarefa Dois'), findsOneWidget);
    expect(find.text('Nenhuma tarefa cadastrada'), findsNothing);
  });
}
