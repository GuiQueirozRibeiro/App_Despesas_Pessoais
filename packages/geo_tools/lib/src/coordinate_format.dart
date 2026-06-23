import 'geo_point.dart';

/// Funções de formatação de coordenadas e distâncias, com saída em pt-BR
/// (vírgula como separador decimal, hemisférios N/S/L/O).
///
/// São funções puras (sem efeitos colaterais), o que as torna triviais de
/// testar de forma determinística.

/// Formata um [GeoPoint] como texto legível com hemisférios.
///
/// Exemplo: `GeoPoint(-23.5505, -46.6333)` → `"23.55050° S, 46.63330° O"`.
///
/// [decimals] controla a precisão (padrão 5 casas ≈ 1 metro de resolução).
String formatCoordinates(GeoPoint point, {int decimals = 5}) {
  final latHemisphere = point.latitude >= 0 ? 'N' : 'S';
  final lonHemisphere = point.longitude >= 0 ? 'L' : 'O';
  final lat = point.latitude.abs().toStringAsFixed(decimals);
  final lon = point.longitude.abs().toStringAsFixed(decimals);
  return '$lat° $latHemisphere, $lon° $lonHemisphere';
}

/// Formata uma distância em metros para texto legível em pt-BR.
///
/// Regra de negócio (passível de ajuste conforme a necessidade do app):
/// - abaixo de 1 km: mostra em metros inteiros — ex.: `"350 m"`;
/// - a partir de 1 km: mostra em km com 1 casa decimal e vírgula — ex.: `"2,4 km"`.
///
/// Distâncias negativas não fazem sentido e são tratadas como zero.
String formatDistance(double meters) {
  final value = meters < 0 ? 0.0 : meters;
  if (value < 1000) {
    return '${value.round()} m';
  }
  final km = value / 1000.0;
  // Troca o ponto pela vírgula para seguir a convenção numérica do pt-BR.
  final kmText = km.toStringAsFixed(1).replaceAll('.', ',');
  return '$kmText km';
}
