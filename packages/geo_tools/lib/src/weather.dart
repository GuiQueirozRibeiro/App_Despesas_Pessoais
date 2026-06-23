import 'package:meta/meta.dart';

/// Representa o clima atual em um ponto, já normalizado a partir da resposta
/// crua da API do OpenWeather.
///
/// O parsing fica concentrado em [Weather.fromOpenWeatherJson], isolando o app
/// do formato específico do provedor: se um dia trocarmos de API, só este
/// arquivo muda.
@immutable
class Weather {
  /// Nome da cidade resolvida pela API (pode vir vazio em áreas remotas).
  final String cityName;

  /// Descrição amigável já localizada (ex.: "céu limpo", "chuva leve").
  final String description;

  /// Categoria principal em inglês da API (ex.: "Clear", "Rain", "Clouds").
  final String condition;

  /// Temperatura atual em graus Celsius.
  final double temperatureC;

  /// Sensação térmica em graus Celsius.
  final double feelsLikeC;

  /// Umidade relativa do ar em porcentagem (0–100).
  final int humidity;

  /// Velocidade do vento em m/s.
  final double windSpeed;

  /// Código do ícone do OpenWeather (ex.: "01d", "10n").
  final String iconCode;

  const Weather({
    required this.cityName,
    required this.description,
    required this.condition,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
  });

  /// URL pública do ícone correspondente (PNG 2x). Vazia se não houver ícone.
  String get iconUrl => iconCode.isEmpty
      ? ''
      : 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  /// Constrói um [Weather] a partir do JSON do endpoint
  /// `data/2.5/weather` do OpenWeather (com `units=metric`).
  ///
  /// Tolera campos ausentes usando valores padrão, para nunca lançar em runtime
  /// por causa de uma chave faltando — princípio importante para apps mobile.
  factory Weather.fromOpenWeatherJson(Map<String, dynamic> json) {
    final main = (json['main'] as Map<String, dynamic>?) ?? const {};
    final wind = (json['wind'] as Map<String, dynamic>?) ?? const {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? const [];
    final first = weatherList.isNotEmpty
        ? (weatherList.first as Map<String, dynamic>)
        : const <String, dynamic>{};

    return Weather(
      cityName: (json['name'] as String?) ?? '',
      description: (first['description'] as String?) ?? '',
      condition: (first['main'] as String?) ?? '',
      temperatureC: _toDouble(main['temp']),
      feelsLikeC: _toDouble(main['feels_like']),
      humidity: _toInt(main['humidity']),
      windSpeed: _toDouble(wind['speed']),
      iconCode: (first['icon'] as String?) ?? '',
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return 0.0;
  }

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    return 0;
  }
}
