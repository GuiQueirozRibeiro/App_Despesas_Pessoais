/// Configurações de ambiente do app.
///
/// A chave da API do OpenWeather **não** fica no código-fonte. Ela é injetada
/// em tempo de compilação via `--dart-define`:
///
/// ```bash
/// flutter run --dart-define=OPENWEATHER_API_KEY=sua_chave_aqui
/// ```
///
/// Assim a chave nunca é commitada no repositório.
abstract final class AppConfig {
  static const String openWeatherApiKey =
      String.fromEnvironment('OPENWEATHER_API_KEY');

  /// `true` quando uma chave foi fornecida — a UI usa isso para exibir um aviso
  /// amigável quando o clima está indisponível por falta de configuração.
  static bool get hasWeatherApiKey => openWeatherApiKey.isNotEmpty;
}
