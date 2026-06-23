import 'dart:math' as math;

import 'geo_point.dart';

/// Raio médio da Terra em metros (modelo esférico WGS-84).
const double kEarthRadiusMeters = 6371000.0;

/// Calcula a distância em **metros** entre dois pontos geográficos usando a
/// fórmula de Haversine.
///
/// A fórmula de Haversine assume a Terra como uma esfera perfeita. O erro
/// resultante (< 0,5%) é irrelevante para distâncias urbanas, e a fórmula é
/// barata e estável numericamente — ideal para um app mobile.
///
/// ```
/// a = sin²(Δφ/2) + cos φ1 ⋅ cos φ2 ⋅ sin²(Δλ/2)
/// c = 2 ⋅ atan2(√a, √(1−a))
/// d = R ⋅ c
/// ```
double haversineDistanceMeters(GeoPoint from, GeoPoint to) {
  final lat1 = _degToRad(from.latitude);
  final lat2 = _degToRad(to.latitude);
  final dLat = _degToRad(to.latitude - from.latitude);
  final dLon = _degToRad(to.longitude - from.longitude);

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return kEarthRadiusMeters * c;
}

double _degToRad(double degrees) => degrees * math.pi / 180.0;
