import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarefas_geo/models/task.dart';
import 'package:tarefas_geo/repositories/firestore_task_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreTaskRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = FirestoreTaskRepository(firestore);
  });

  group('FirestoreTaskRepository', () {
    test('add grava o documento na coleção "tasks"', () async {
      final task = Task(
        id: 't1',
        name: 'Reunião',
        dateTime: DateTime(2026, 6, 22, 14, 30),
        latitude: -23.5,
        longitude: -46.6,
        locationLabel: 'Escritório',
      );

      await repo.add(task);

      final doc = await firestore.collection('tasks').doc('t1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'Reunião');
      expect(doc.data()!['locationLabel'], 'Escritório');
    });

    test('watchTasks emite as tarefas e preserva data/hora (round-trip)',
        () async {
      final task = Task(
        id: 't2',
        name: 'Consulta',
        dateTime: DateTime(2026, 6, 22, 9, 15),
        latitude: -22.9,
        longitude: -43.2,
      );
      await repo.add(task);

      final tasks = await repo.watchTasks().first;

      expect(tasks, hasLength(1));
      final lida = tasks.single;
      expect(lida.id, 't2');
      expect(lida.name, 'Consulta');
      expect(lida.dateTime, DateTime(2026, 6, 22, 9, 15));
      expect(lida.latitude, -22.9);
    });

    test('update modifica os campos do documento', () async {
      final task = Task(id: 't3', name: 'Antigo', dateTime: DateTime(2026, 1, 1));
      await repo.add(task);

      await repo.update(task.copyWith(name: 'Atualizado'));

      final doc = await firestore.collection('tasks').doc('t3').get();
      expect(doc.data()!['name'], 'Atualizado');
    });

    test('delete remove o documento', () async {
      final task = Task(id: 't4', name: 'Temp', dateTime: DateTime(2026, 1, 1));
      await repo.add(task);

      await repo.delete('t4');

      final doc = await firestore.collection('tasks').doc('t4').get();
      expect(doc.exists, isFalse);
    });

    test('watchTasks reflete múltiplas tarefas', () async {
      await repo.add(Task(id: 'a', name: 'A', dateTime: DateTime(2026, 1, 1)));
      await repo.add(Task(id: 'b', name: 'B', dateTime: DateTime(2026, 1, 2)));

      final tasks = await repo.watchTasks().first;
      expect(tasks, hasLength(2));
      expect(tasks.map((t) => t.id), containsAll(['a', 'b']));
    });
  });
}
