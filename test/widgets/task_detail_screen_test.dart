import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_tools/geo_tools.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_geo/models/task.dart';
import 'package:tarefas_geo/providers/task_provider.dart';
import 'package:tarefas_geo/repositories/firestore_task_repository.dart';
import 'package:tarefas_geo/routes/app_routes.dart';
import 'package:tarefas_geo/screens/task_detail_screen.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Widget wrap(Task task, FirestoreTaskRepository repo) {
    return MultiProvider(
      providers: [
        Provider<WeatherClient>(
          create: (_) => WeatherClient(apiKey: ''),
          dispose: (_, c) => c.close(),
        ),
        ChangeNotifierProvider(create: (_) => TaskProvider(repo)),
      ],
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: TaskDetailScreen(task: task),
      ),
    );
  }

  testWidgets('mostra nome, data e aviso de ausência de localização',
      (tester) async {
    final repo = FirestoreTaskRepository(FakeFirebaseFirestore());
    final task =
        Task(id: '1', name: 'Tarefa simples', dateTime: DateTime(2026, 6, 22, 10));

    await tester.pumpWidget(wrap(task, repo));
    await tester.pump();

    expect(find.text('Detalhe da Tarefa'), findsOneWidget);
    expect(find.text('Tarefa simples'), findsOneWidget);
    expect(find.textContaining('não tem localização'), findsOneWidget);
  });

  testWidgets('abre e cancela o diálogo de exclusão', (tester) async {
    final repo = FirestoreTaskRepository(FakeFirebaseFirestore());
    final task =
        Task(id: '2', name: 'Para excluir', dateTime: DateTime(2026, 6, 22, 10));

    await tester.pumpWidget(wrap(task, repo));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Excluir tarefa?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir tarefa?'), findsNothing);
  });
}
