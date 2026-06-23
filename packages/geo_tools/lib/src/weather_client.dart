import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo_point.dart';
import 'weather.dart';

/// Erro base ao consultar o clima. A UI pode tratar [message] diretamente
/// (já em pt-BR) e usar os subtipos para reações específicas.
class WeatherException implements Exception {
  final String message;
  final int? statusCode;
  const WeatherException(this.message, {this.statusCode});

  @override
  String toString() => 'WeatherException($statusCode): $message';
}

/// Chave de API ausente ou inválida (HTTP 401).
class WeatherAuthException extends WeatherException {
  const WeatherAuthException()
      : super('Chave de API do OpenWeather inválida ou ausente.',
            statusCode: 401);
}

/// Falha de rede (sem conexão, timeout, DNS, etc.).
class WeatherNetworkException extends WeatherException {
  const WeatherNetworkException()
      : super('Não foi possível conectar ao serviço de clima. '
            'Verifique sua conexão com a internet.');
}

/// Cliente da API REST de clima do OpenWeather.
///
/// Consome o endpoint *Current Weather Data*:
/// `https://api.openweathermap.org/data/2.5/weather`.
///
/// O [http.Client] é injetado para permitir testes sem rede (com `MockClient`).
/// A chave de API nunca é embutida no código — ela chega pelo construtor,
/// tipicamente vinda de `--dart-define=OPENWEATHER_API_KEY=...`.
class WeatherClient {
  final http.Client _httpClient;
  final String apiKey;
  final String _host;

  WeatherClient({
    required this.apiKey,
    http.Client? httpClient,
    String host = 'api.openweathermap.org',
  })  : _httpClient = httpClient ?? http.Client(),
        _host = host;

  /// Busca o clima atual no ponto [point].
  ///
  /// Lança [WeatherAuthException] se a chave for inválida (401),
  /// [WeatherNetworkException] em falha de conexão e [WeatherException]
  /// genérica para outros status HTTP.
  Future<Weather> getCurrentWeather(GeoPoint point) async {
    final uri = Uri.https(_host, '/data/2.5/weather', {
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'appid': apiKey,
      'units': 'metric',
      'lang': 'pt_br',
    });

    final http.Response response;
    try {
      response = await _httpClient.get(uri);
    } catch (_) {
      throw const WeatherNetworkException();
    }

    switch (response.statusCode) {
      case 200:
        // Decodifica como UTF-8 explicitamente: as descrições do OpenWeather
        // vêm em português e `.body` cairia em latin1 sem o header de charset.
        final json =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return Weather.fromOpenWeatherJson(json);
      case 401:
        throw const WeatherAuthException();
      default:
        throw WeatherException(
          'Falha ao obter o clima (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
    }
  }

  /// Libera o [http.Client] interno. Chame ao descartar o cliente.
  void close() => _httpClient.close();
}
