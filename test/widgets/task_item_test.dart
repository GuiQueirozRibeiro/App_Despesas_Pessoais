import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tarefas_geo/components/task_item.dart';
import 'package:tarefas_geo/models/task.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('exibe o nome e o rótulo da localização', (tester) async {
    final task = Task(
      id: '1',
      name: 'Comprar pão',
      dateTime: DateTime(2026, 6, 22, 8, 0),
      latitude: -23.5,
      longitude: -46.6,
      locationLabel: 'Padaria',
    );

    await tester.pumpWidget(
      wrap(TaskItem(task: task, onTap: () {}, onRemove: () {})),
    );

    expect(find.text('Comprar pão'), findsOneWidget);
    expect(find.text('Padaria'), findsOneWidget);
  });

  testWidgets('tocar no item dispara onTap', (tester) async {
    var tapped = false;
    final task = Task(id: '2', name: 'Estudar', dateTime: DateTime(2026, 6, 22, 9));

    await tester.pumpWidget(
      wrap(TaskItem(task: task, onTap: () => tapped = true, onRemove: () {})),
    );
    await tester.tap(find.text('Estudar'));

    expect(tapped, isTrue);
  });

  testWidgets('tarefa sem localização não mostra ícone de local', (tester) async {
    final task = Task(id: '3', name: 'Sem local', dateTime: DateTime(2026, 6, 22, 9));

    await tester.pumpWidget(
      wrap(TaskItem(task: task, onTap: () {}, onRemove: () {})),
    );

    expect(find.byIcon(Icons.location_on_outlined), findsNothing);
  });
}
