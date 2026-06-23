import 'package:geo_tools/geo_tools.dart';
import 'package:test/test.dart';

void main() {
  group('GeoPoint', () {
    test('cria ponto válido e expõe lat/lng', () {
      final p = GeoPoint(-23.5505, -46.6333);
      expect(p.latitude, -23.5505);
      expect(p.longitude, -46.6333);
    });

    test('aceita os limites extremos válidos', () {
      expect(() => GeoPoint(90, 180), returnsNormally);
      expect(() => GeoPoint(-90, -180), returnsNormally);
    });

    test('rejeita latitude fora de [-90, 90]', () {
      expect(() => GeoPoint(91, 0), throwsArgumentError);
      expect(() => GeoPoint(-90.1, 0), throwsArgumentError);
    });

    test('rejeita longitude fora de [-180, 180]', () {
      expect(() => GeoPoint(0, 181), throwsArgumentError);
      expect(() => GeoPoint(0, -180.5), throwsArgumentError);
    });

    test('igualdade por valor e hashCode consistente', () {
      final a = GeoPoint(10, 20);
      final b = GeoPoint(10, 20);
      final c = GeoPoint(10, 21);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
