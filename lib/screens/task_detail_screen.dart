import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geo_tools/geo_tools.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../routes/app_routes.dart';
import '../services/location_service.dart';

/// Tela de detalhe de uma tarefa: dados, mapa, clima (OpenWeather) e distância.
class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Future<Weather>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    // Dispara a busca do clima uma única vez (não no build).
    final t = widget.task;
    if (t.hasLocation && AppConfig.hasWeatherApiKey) {
      _weatherFuture = context
          .read<WeatherClient>()
          .getCurrentWeather(GeoPoint(t.latitude!, t.longitude!));
    }
  }

  Future<void> _confirmDelete() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text('"${widget.task.name}" será removida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await context.read<TaskProvider>().remove(widget.task.id);
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = Theme.of(context);
    final dateLabel = DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR')
        .format(task.dateTime);
    final timeLabel = DateFormat('HH:mm').format(task.dateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da Tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => Navigator.of(context)
                .pushNamed(AppRoutes.taskForm, arguments: task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(task.name,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: theme.hintColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$dateLabel · $timeLabel',
                    style: const TextStyle(fontFamily: 'OpenSans')),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!task.hasLocation)
            _Card(
              child: Row(
                children: [
                  Icon(Icons.location_off_outlined, color: theme.hintColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Esta tarefa não tem localização registrada.',
                        style: TextStyle(fontFamily: 'OpenSans')),
                  ),
                ],
              ),
            )
          else ...[
            _LocationCard(task: task),
            const SizedBox(height: 16),
            _WeatherSection(weatherFuture: _weatherFuture),
            const SizedBox(height: 16),
            _DistanceCard(task: task),
          ],
        ],
      ),
    );
  }
}

/// Card com o mapa + coordenadas formatadas (usa `formatCoordinates`).
class _LocationCard extends StatelessWidget {
  final Task task;
  const _LocationCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(task.latitude!, task.longitude!);
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(initialCenter: point, initialZoom: 15),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'br.com.guilhermeribeiro.tarefasgeo',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: point,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 36),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.place_outlined,
                    color: Theme.of(context).colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.locationLabel ??
                        formatCoordinates(
                            GeoPoint(task.latitude!, task.longitude!)),
                    style: const TextStyle(
                        fontFamily: 'OpenSans', fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Seção do clima — consome a API REST do OpenWeather via `WeatherClient`.
class _WeatherSection extends StatelessWidget {
  final Future<Weather>? weatherFuture;
  const _WeatherSection({required this.weatherFuture});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasWeatherApiKey) {
      return _Card(
        child: Row(
          children: [
            const Icon(Icons.key_off_outlined),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Clima indisponível: forneça a chave com '
                '--dart-define=OPENWEATHER_API_KEY=...',
                style: TextStyle(fontFamily: 'OpenSans', fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<Weather>(
      future: weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Card(
            child: Row(children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('Carregando o clima…',
                  style: TextStyle(fontFamily: 'OpenSans')),
            ]),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is WeatherException
              ? error.message
              : 'Não foi possível obter o clima.';
          return _Card(
            child: Row(children: [
              Icon(Icons.cloud_off, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message,
                    style: const TextStyle(fontFamily: 'OpenSans', fontSize: 13)),
              ),
            ]),
          );
        }
        final weather = snapshot.data!;
        return _Card(child: _WeatherContent(weather: weather));
      },
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final Weather weather;
  const _WeatherContent({required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (weather.iconUrl.isNotEmpty)
              Image.network(
                weather.iconUrl,
                width: 56,
                height: 56,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.wb_cloudy_outlined, size: 48),
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${weather.temperatureC.round()} °C',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  weather.description.isEmpty
                      ? weather.condition
                      : weather.description,
                  style: const TextStyle(fontFamily: 'OpenSans'),
                ),
              ],
            ),
            const Spacer(),
            if (weather.cityName.isNotEmpty)
              Flexible(
                child: Text(weather.cityName,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontFamily: 'OpenSans', color: theme.hintColor)),
              ),
          ],
        ),
        const Divider(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _WeatherChip(
                icon: Icons.thermostat,
                label: 'Sensação',
                value: '${weather.feelsLikeC.round()} °C'),
            _WeatherChip(
                icon: Icons.water_drop_outlined,
                label: 'Umidade',
                value: '${weather.humidity}%'),
            _WeatherChip(
                icon: Icons.air,
                label: 'Vento',
                value: '${weather.windSpeed.toStringAsFixed(1)} m/s'),
          ],
        ),
      ],
    );
  }
}

class _WeatherChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WeatherChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).hintColor),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(
                fontFamily: 'OpenSans', color: Theme.of(context).hintColor)),
        Text(value,
            style: const TextStyle(
                fontFamily: 'OpenSans', fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// Card que calcula a distância da posição atual do usuário até a tarefa,
/// usando GPS (device API) + Haversine + formatação (package geo_tools).
class _DistanceCard extends StatefulWidget {
  final Task task;
  const _DistanceCard({required this.task});

  @override
  State<_DistanceCard> createState() => _DistanceCardState();
}

class _DistanceCardState extends State<_DistanceCard> {
  final _location = LocationService();
  bool _loading = false;
  String? _result;
  String? _error;

  Future<void> _calculate() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    final pos = await _location.getCurrentPosition();
    if (!mounted) return;
    if (!pos.isSuccess) {
      setState(() {
        _loading = false;
        _error = pos.error;
      });
      return;
    }
    final from = GeoPoint(pos.latitude!, pos.longitude!);
    final to = GeoPoint(widget.task.latitude!, widget.task.longitude!);
    final meters = haversineDistanceMeters(from, to);
    setState(() {
      _loading = false;
      _result = formatDistance(meters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.straighten),
              const SizedBox(width: 8),
              const Text('Distância da minha posição',
                  style: TextStyle(
                      fontFamily: 'OpenSans', fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_loading)
                const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                TextButton(onPressed: _calculate, child: const Text('Calcular')),
            ],
          ),
          if (_result != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Aproximadamente $_result',
                  style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!,
                  style: const TextStyle(
                      fontFamily: 'OpenSans', color: Colors.red, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

/// Cartão padrão reutilizado na tela.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: padding, child: child),
    );
  }
}
