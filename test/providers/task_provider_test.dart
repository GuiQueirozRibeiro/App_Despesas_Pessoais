import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tarefas_geo/models/task.dart';
import 'package:tarefas_geo/providers/task_provider.dart';
import 'package:tarefas_geo/repositories/task_repository.dart';

/// Repositório falso controlado pelo teste: emitimos eventos manualmente no
/// [controller] e registramos as chamadas de escrita.
class FakeTaskRepository implements TaskRepository {
  final controller = StreamController<List<Task>>.broadcast();
  final List<String> calls = [];
  bool throwOnWrite = false;

  @override
  Stream<List<Task>> watchTasks() => controller.stream;

  @override
  Future<void> add(Task task) async {
    if (throwOnWrite) throw Exception('falha');
    calls.add('add:${task.id}');
  }

  @override
  Future<void> update(Task task) async => calls.add('update:${task.id}');

  @override
  Future<void> delete(String id) async => calls.add('delete:$id');
}

void main() {
  late FakeTaskRepository repo;
  late TaskProvider provider;

  setUp(() {
    repo = FakeTaskRepository();
    provider = TaskProvider(repo);
  });

  tearDown(() {
    provider.dispose();
    repo.controller.close();
  });

  test('começa em estado de carregamento', () {
    expect(provider.isLoading, isTrue);
    expect(provider.tasks, isEmpty);
  });

  test('ao receber dados do stream, sai do loading e popula a lista', () async {
    repo.controller.add([
      Task(id: '1', name: 'A', dateTime: DateTime(2026, 1, 1)),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.isLoading, isFalse);
    expect(provider.count, 1);
    expect(provider.error, isNull);
  });

  test('ordena as tarefas por data crescente', () async {
    repo.controller.add([
      Task(id: 'tarde', name: 'Tarde', dateTime: DateTime(2026, 5, 10)),
      Task(id: 'cedo', name: 'Cedo', dateTime: DateTime(2026, 1, 5)),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.tasks.first.id, 'cedo');
    expect(provider.tasks.last.id, 'tarde');
  });

  test('expõe mensagem de erro quando o stream falha', () async {
    repo.controller.addError(Exception('sem conexão'));
    await Future<void>.delayed(Duration.zero);

    expect(provider.isLoading, isFalse);
    expect(provider.error, isNotNull);
  });

  test('upcoming retorna apenas tarefas dos próximos 7 dias', () async {
    final agora = DateTime.now();
    repo.controller.add([
      Task(id: 'amanha', name: 'Amanhã', dateTime: agora.add(const Duration(days: 1))),
      Task(id: 'longe', name: 'Longe', dateTime: agora.add(const Duration(days: 30))),
      Task(id: 'passado', name: 'Passado', dateTime: agora.subtract(const Duration(days: 1))),
    ]);
    await Future<void>.delayed(Duration.zero);

    final ids = provider.upcoming.map((t) => t.id);
    expect(ids, contains('amanha'));
    expect(ids, isNot(contains('longe')));
    expect(ids, isNot(contains('passado')));
  });

  test('findById encontra ou retorna null', () async {
    repo.controller.add([Task(id: 'x', name: 'X', dateTime: DateTime(2026, 1, 1))]);
    await Future<void>.delayed(Duration.zero);

    expect(provider.findById('x'), isNotNull);
    expect(provider.findById('inexistente'), isNull);
  });

  test('add/update/remove delegam ao repositório', () async {
    final task = Task(id: 'y', name: 'Y', dateTime: DateTime(2026, 1, 1));
    await provider.add(task);
    await provider.update(task);
    await provider.remove('y');

    expect(repo.calls, ['add:y', 'update:y', 'delete:y']);
  });

  test('propaga exceção quando a escrita falha', () async {
    repo.throwOnWrite = true;
    expect(
      () => provider.add(Task(id: 'z', name: 'Z', dateTime: DateTime(2026, 1, 1))),
      throwsException,
    );
  });
}
