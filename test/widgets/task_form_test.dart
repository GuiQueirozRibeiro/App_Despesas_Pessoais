import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tarefas_geo/components/task_form.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

  testWidgets('exibe erro ao tentar salvar com nome vazio', (tester) async {
    var submitted = false;

    await tester.pumpWidget(wrap(TaskForm(onSubmit: (_, __, ___, ____, _____) {
      submitted = true;
    })));

    await tester.tap(find.text('Criar Tarefa'));
    await tester.pump();

    expect(find.text('Informe o nome da tarefa.'), findsOneWidget);
    expect(submitted, isFalse, reason: 'não deve submeter com nome vazio');
  });

  testWidgets('chama onSubmit com o nome preenchido', (tester) async {
    String? nomeRecebido;

    await tester.pumpWidget(wrap(TaskForm(onSubmit: (name, _, __, ___, ____) {
      nomeRecebido = name;
    })));

    await tester.enterText(find.byType(TextField).first, 'Levar o cachorro');
    await tester.tap(find.text('Criar Tarefa'));
    await tester.pump();

    expect(nomeRecebido, 'Levar o cachorro');
  });

  testWidgets('mostra "Salvar alterações" no modo edição', (tester) async {
    await tester.pumpWidget(wrap(TaskForm(
      onSubmit: (_, __, ___, ____, _____) {},
      existing: null,
    )));
    expect(find.text('Criar Tarefa'), findsOneWidget);
  });
}
