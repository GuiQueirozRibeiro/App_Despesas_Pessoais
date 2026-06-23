import 'package:geo_tools/geo_tools.dart';
import 'package:test/test.dart';

void main() {
  group('haversineDistanceMeters', () {
    test('distância de um ponto até ele mesmo é zero', () {
      final p = GeoPoint(-23.5505, -46.6333);
      expect(haversineDistanceMeters(p, p), 0);
    });

    test('1 grau de longitude no equador ≈ 111,2 km', () {
      final d = haversineDistanceMeters(GeoPoint(0, 0), GeoPoint(0, 1));
      // Valor teórico ≈ 111194,9 m. Tolerância de 1 m.
      expect(d, closeTo(111194.9, 1));
    });

    test('1 grau de latitude ≈ 111,2 km', () {
      final d = haversineDistanceMeters(GeoPoint(0, 0), GeoPoint(1, 0));
      expect(d, closeTo(111194.9, 1));
    });

    test('São Paulo → Rio de Janeiro ≈ 360 km', () {
      final sp = GeoPoint(-23.5505, -46.6333);
      final rj = GeoPoint(-22.9068, -43.1729);
      final km = haversineDistanceMeters(sp, rj) / 1000;
      expect(km, closeTo(360, 10));
    });

    test('é simétrica (A→B == B→A)', () {
      final a = GeoPoint(-23.5505, -46.6333);
      final b = GeoPoint(-22.9068, -43.1729);
      expect(
        haversineDistanceMeters(a, b),
        closeTo(haversineDistanceMeters(b, a), 0.0001),
      );
    });
  });
}
