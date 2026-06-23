import 'dart:convert';

import 'package:geo_tools/geo_tools.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

/// Resposta JSON mínima de sucesso do OpenWeather, reutilizada nos testes.
const _okBody = '''
{
  "name": "São Paulo",
  "weather": [{"main": "Rain", "description": "chuva leve", "icon": "10d"}],
  "main": {"temp": 19.2, "feels_like": 19.0, "humidity": 88},
  "wind": {"speed": 4.1}
}
''';

void main() {
  final ponto = GeoPoint(-23.5505, -46.6333);

  group('WeatherClient.getCurrentWeather', () {
    test('HTTP 200: retorna Weather e monta a URL com os parâmetros certos',
        () async {
      late Uri capturada;
      final mock = MockClient((request) async {
        capturada = request.url;
        // bytes UTF-8, como o servidor real devolve.
        return http.Response.bytes(utf8.encode(_okBody), 200);
      });

      final client = WeatherClient(apiKey: 'CHAVE_TESTE', httpClient: mock);
      final weather = await client.getCurrentWeather(ponto);

      // Verifica o resultado.
      expect(weather.cityName, 'São Paulo');
      expect(weather.condition, 'Rain');
      expect(weather.temperatureC, 19.2);

      // Verifica que o consumo da API montou a query corretamente.
      expect(capturada.host, 'api.openweathermap.org');
      expect(capturada.path, '/data/2.5/weather');
      expect(capturada.queryParameters['lat'], '-23.5505');
      expect(capturada.queryParameters['lon'], '-46.6333');
      expect(capturada.queryParameters['appid'], 'CHAVE_TESTE');
      expect(capturada.queryParameters['units'], 'metric');
      expect(capturada.queryParameters['lang'], 'pt_br');
    });

    test('HTTP 401: lança WeatherAuthException', () {
      final mock = MockClient((_) async => http.Response('{}', 401));
      final client = WeatherClient(apiKey: 'INVALIDA', httpClient: mock);
      expect(
        () => client.getCurrentWeather(ponto),
        throwsA(isA<WeatherAuthException>()),
      );
    });

    test('HTTP 500: lança WeatherException com statusCode', () async {
      final mock = MockClient((_) async => http.Response('erro', 500));
      final client = WeatherClient(apiKey: 'X', httpClient: mock);
      await expectLater(
        () => client.getCurrentWeather(ponto),
        throwsA(
          isA<WeatherException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('falha de conexão: lança WeatherNetworkException', () {
      final mock = MockClient((_) async => throw http.ClientException('boom'));
      final client = WeatherClient(apiKey: 'X', httpClient: mock);
      expect(
        () => client.getCurrentWeather(ponto),
        throwsA(isA<WeatherNetworkException>()),
      );
    });

    test('decodifica acentos (UTF-8) mesmo sem header de charset', () async {
      // Corpo com acento, enviado como bytes e SEM content-type — é o caso em
      // que `.body` (latin1) quebraria "céu limpo".
      const corpoAcentuado =
          '{"name":"Goiânia","weather":[{"main":"Clear",'
          '"description":"céu limpo","icon":"01d"}],'
          '"main":{"temp":30.0,"feels_like":31.0,"humidity":40},'
          '"wind":{"speed":2.0}}';
      final mock = MockClient(
        (_) async => http.Response.bytes(utf8.encode(corpoAcentuado), 200),
      );
      final client = WeatherClient(apiKey: 'X', httpClient: mock);
      final weather = await client.getCurrentWeather(ponto);
      expect(weather.cityName, 'Goiânia');
      expect(weather.description, 'céu limpo');
    });
  });
}
