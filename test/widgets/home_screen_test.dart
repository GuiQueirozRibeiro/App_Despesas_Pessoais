import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_geo/models/task.dart';
import 'package:tarefas_geo/providers/task_provider.dart';
import 'package:tarefas_geo/repositories/firestore_task_repository.dart';
import 'package:tarefas_geo/screens/home_screen.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> pumpHome(WidgetTester tester, FirestoreTaskRepository repo) {
    return tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider(repo),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
  }

  testWidgets('mostra o título e o FAB de adicionar', (tester) async {
    await pumpHome(tester, FirestoreTaskRepository(FakeFirebaseFirestore()));
    await tester.pumpAndSettle();

    expect(find.text('Tarefas Geo'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('mostra o estado vazio sem tarefas', (tester) async {
    await pumpHome(tester, FirestoreTaskRepository(FakeFirebaseFirestore()));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma tarefa cadastrada'), findsOneWidget);
  });

  testWidgets('exibe a tarefa cadastrada após carregar', (tester) async {
    final repo = FirestoreTaskRepository(FakeFirebaseFirestore());
    await repo.add(Task(id: '1', name: 'Pagar conta', dateTime: DateTime(2026, 6, 22, 12)));

    await pumpHome(tester, repo);
    await tester.pumpAndSettle();

    expect(find.text('Pagar conta'), findsOneWidget);
  });
}
