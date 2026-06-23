import 'package:geo_tools/geo_tools.dart';
import 'package:test/test.dart';

void main() {
  group('formatCoordinates', () {
    test('usa hemisférios S e O para coordenadas negativas', () {
      final texto = formatCoordinates(GeoPoint(-23.5505, -46.6333), decimals: 4);
      expect(texto, '23.5505° S, 46.6333° O');
    });

    test('usa hemisférios N e L para coordenadas positivas', () {
      final texto = formatCoordinates(GeoPoint(23.5, 46.6), decimals: 1);
      expect(texto, '23.5° N, 46.6° L');
    });

    test('respeita o número de casas decimais', () {
      final texto = formatCoordinates(GeoPoint(0, 0), decimals: 3);
      expect(texto, '0.000° N, 0.000° L');
    });
  });

  group('formatDistance', () {
    test('abaixo de 1 km mostra metros inteiros', () {
      expect(formatDistance(0), '0 m');
      expect(formatDistance(350), '350 m');
      expect(formatDistance(999), '999 m');
    });

    test('a partir de 1 km mostra km com vírgula decimal', () {
      expect(formatDistance(1000), '1,0 km');
      expect(formatDistance(2400), '2,4 km');
      expect(formatDistance(15750), '15,8 km');
    });

    test('distância negativa é tratada como zero', () {
      expect(formatDistance(-42), '0 m');
    });
  });
}
