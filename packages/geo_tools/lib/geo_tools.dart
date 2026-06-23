/// geo_tools — utilitários de geolocalização para o app Tarefas Geo.
///
/// Expõe:
/// - [GeoPoint]: ponto geográfico imutável e validado;
/// - [haversineDistanceMeters]: distância entre dois pontos (fórmula de Haversine);
/// - [formatCoordinates] / [formatDistance]: formatação em pt-BR;
/// - [Weather] e [WeatherClient]: consumo da API REST de clima (OpenWeather).
library geo_tools;

export 'src/coordinate_format.dart';
export 'src/geo_point.dart';
export 'src/haversine.dart';
export 'src/weather.dart';
export 'src/weather_client.dart';
