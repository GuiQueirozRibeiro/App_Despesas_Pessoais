# geo_tools

Pacote **interno** (Dart puro) desenvolvido para o app **Tarefas Geo**. Reúne os
utilitários de geolocalização do projeto em um módulo reutilizável e testável de
forma isolada.

> Atende ao item de rubrica **"Desenvolver plugins Flutter / package desenvolvido
> pelo aluno"**. Por ser Dart puro (sem dependência de Flutter), pode ser usado em
> qualquer projeto Dart — inclusive backend.

## O que o pacote oferece

| Símbolo | Responsabilidade |
|---|---|
| `GeoPoint` | Ponto geográfico imutável com validação de limites (lat ∈ [-90,90], lng ∈ [-180,180]) |
| `haversineDistanceMeters(a, b)` | Distância em metros entre dois pontos (fórmula de Haversine) |
| `formatCoordinates(point)` | Coordenadas legíveis em pt-BR (ex.: `23.55050° S, 46.63330° O`) |
| `formatDistance(meters)` | Distância legível em pt-BR (ex.: `350 m`, `2,4 km`) |
| `Weather` | Modelo do clima já normalizado a partir do JSON do OpenWeather |
| `WeatherClient` | Cliente da **API REST** do OpenWeather (consome `data/2.5/weather`) |

## Uso

```dart
import 'package:geo_tools/geo_tools.dart';

// Distância e formatação (funções puras)
final sp = GeoPoint(-23.5505, -46.6333);
final rj = GeoPoint(-22.9068, -43.1729);
final metros = haversineDistanceMeters(sp, rj);
print(formatDistance(metros)); // ~360 km

// Consumo da API de clima (injete a chave via --dart-define)
final client = WeatherClient(apiKey: const String.fromEnvironment('OPENWEATHER_API_KEY'));
final clima = await client.getCurrentWeather(sp);
print('${clima.cityName}: ${clima.temperatureC} °C, ${clima.description}');
```

## Como testar este pacote

Os testes ficam em [`test/`](test/) e **não dependem de rede** — o `WeatherClient`
recebe um `http.Client` injetado, substituído por um `MockClient` nos testes.

```bash
cd packages/geo_tools
dart pub get
dart test                 # roda os 24 testes
dart test --coverage=coverage   # com cobertura
```

Cobertura por arquivo:

| Arquivo | Como é coberto |
|---|---|
| `geo_point.dart` | Limites válidos/inválidos, igualdade por valor |
| `haversine.dart` | Distâncias conhecidas (equador, SP→RJ), simetria, distância zero |
| `coordinate_format.dart` | Hemisférios, casas decimais, limiar m↔km, valor negativo |
| `weather.dart` | Parse completo, campos ausentes, coerção int→double |
| `weather_client.dart` | HTTP 200/401/500, falha de rede, decodificação UTF-8, montagem da query |

## Estrutura

```
geo_tools/
├── lib/
│   ├── geo_tools.dart          # API pública (barrel)
│   └── src/
│       ├── geo_point.dart
│       ├── haversine.dart
│       ├── coordinate_format.dart
│       ├── weather.dart
│       └── weather_client.dart
└── test/                       # 1 arquivo de teste por módulo
```
