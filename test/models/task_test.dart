import 'package:flutter_test/flutter_test.dart';
import 'package:tarefas_geo/models/task.dart';

void main() {
  group('Task', () {
    test('gera um id automático quando não informado', () {
      final a = Task(name: 'A', dateTime: DateTime(2026, 1, 1));
      final b = Task(name: 'B', dateTime: DateTime(2026, 1, 1));
      expect(a.id, isNotEmpty);
      expect(a.id, isNot(equals(b.id)), reason: 'ids devem ser únicos');
    });

    test('mantém o id quando informado (ex.: vindo do Firestore)', () {
      final t = Task(id: 'doc-123', name: 'X', dateTime: DateTime(2026, 1, 1));
      expect(t.id, 'doc-123');
    });

    test('hasLocation reflete a presença de lat/lng', () {
      final semLocal = Task(name: 'A', dateTime: DateTime(2026, 1, 1));
      final comLocal = Task(
        name: 'B',
        dateTime: DateTime(2026, 1, 1),
        latitude: -23.5,
        longitude: -46.6,
      );
      expect(semLocal.hasLocation, isFalse);
      expect(comLocal.hasLocation, isTrue);
    });

    group('copyWith', () {
      final original = Task(
        id: 'fixo',
        name: 'Original',
        dateTime: DateTime(2026, 1, 1, 10),
        latitude: -23.5,
        longitude: -46.6,
        locationLabel: 'Casa',
      );

      test('altera apenas os campos informados e preserva o id', () {
        final editado = original.copyWith(name: 'Novo nome');
        expect(editado.id, 'fixo');
        expect(editado.name, 'Novo nome');
        expect(editado.latitude, -23.5);
        expect(editado.locationLabel, 'Casa');
      });

      test('clearLocation remove latitude, longitude e rótulo', () {
        final semLocal = original.copyWith(clearLocation: true);
        expect(semLocal.hasLocation, isFalse);
        expect(semLocal.latitude, isNull);
        expect(semLocal.longitude, isNull);
        expect(semLocal.locationLabel, isNull);
      });
    });
  });
}
