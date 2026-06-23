import 'package:meta/meta.dart';

/// Um ponto geográfico imutável (latitude + longitude).
///
/// As invariantes são validadas no construtor: uma vez criado, um [GeoPoint]
/// está **sempre** dentro dos limites válidos do globo. Isso evita propagar
/// coordenadas inválidas para a API de clima ou para os cálculos de distância.
///
/// - Latitude válida: -90 a 90 graus.
/// - Longitude válida: -180 a 180 graus.
@immutable
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint(this.latitude, this.longitude) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError.value(
        latitude,
        'latitude',
        'A latitude deve estar entre -90 e 90 graus.',
      );
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError.value(
        longitude,
        'longitude',
        'A longitude deve estar entre -180 e 180 graus.',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}
