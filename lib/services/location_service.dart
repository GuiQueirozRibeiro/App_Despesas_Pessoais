import 'package:geolocator/geolocator.dart';

/// Resultado de uma tentativa de capturar a localização atual.
class LocationResult {
  final double? latitude;
  final double? longitude;
  final String? error;

  const LocationResult({this.latitude, this.longitude, this.error});

  bool get isSuccess => latitude != null && longitude != null;
}

/// Wrapper sobre [Geolocator] que centraliza o fluxo de:
///   1. verificar serviço de localização ligado
///   2. solicitar permissão ao usuário
///   3. capturar posição atual via GPS
///
/// Mensagens de erro em português, prontas para mostrar na UI.
class LocationService {
  Future<LocationResult> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(
        error: 'Serviço de localização desligado. '
            'Ative o GPS nas configurações do aparelho.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult(
          error: 'Permissão de localização negada pelo usuário.',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(
        error: 'Permissão de localização negada permanentemente. '
            'Abra as configurações do app e habilite manualmente.',
      );
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationResult(latitude: pos.latitude, longitude: pos.longitude);
    } catch (e) {
      return LocationResult(
        error: 'Falha ao obter localização: ${e.toString()}',
      );
    }
  }
}
