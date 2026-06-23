import 'package:geo_tools/geo_tools.dart';
import 'package:test/test.dart';

void main() {
  group('Weather.fromOpenWeatherJson', () {
    test('faz o parse de uma resposta completa', () {
      final json = {
        'name': 'São Paulo',
        'weather': [
          {'main': 'Clear', 'description': 'céu limpo', 'icon': '01d'}
        ],
        'main': {'temp': 24.5, 'feels_like': 25.1, 'humidity': 60},
        'wind': {'speed': 3.6},
      };

      final w = Weather.fromOpenWeatherJson(json);

      expect(w.cityName, 'São Paulo');
      expect(w.condition, 'Clear');
      expect(w.description, 'céu limpo');
      expect(w.temperatureC, 24.5);
      expect(w.feelsLikeC, 25.1);
      expect(w.humidity, 60);
      expect(w.windSpeed, 3.6);
      expect(w.iconCode, '01d');
      expect(w.iconUrl, 'https://openweathermap.org/img/wn/01d@2x.png');
    });

    test('não lança quando faltam campos — usa valores padrão', () {
      final w = Weather.fromOpenWeatherJson({});
      expect(w.cityName, '');
      expect(w.condition, '');
      expect(w.temperatureC, 0.0);
      expect(w.humidity, 0);
      expect(w.iconUrl, '');
    });

    test('converte inteiros para double na temperatura', () {
      final w = Weather.fromOpenWeatherJson({
        'main': {'temp': 25, 'feels_like': 25, 'humidity': 70},
      });
      expect(w.temperatureC, 25.0);
      expect(w.temperatureC, isA<double>());
    });
  });
}
