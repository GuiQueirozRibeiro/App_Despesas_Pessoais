import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';

/// Widget adaptativo (iOS + Android) para capturar e mostrar a geolocalização
/// da tarefa.
///
/// - Botão "Usar minha localização atual" chama o GPS via [LocationService]
/// - Campo de texto opcional para nomear o local ("Casa", "Trabalho", etc.)
/// - Preview em mapa OpenStreetMap (sem necessidade de API key)
/// - Estado controlado externamente via [onChanged]
///
/// Segue o mesmo padrão dos demais `Adaptative*` do projeto: usa
/// `Platform.isIOS` para escolher widgets Cupertino vs Material.
class AdaptativeLocationPicker extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final void Function({
    required double? latitude,
    required double? longitude,
    required String? label,
  }) onChanged;

  const AdaptativeLocationPicker({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<AdaptativeLocationPicker> createState() =>
      _AdaptativeLocationPickerState();
}

class _AdaptativeLocationPickerState extends State<AdaptativeLocationPicker> {
  final _service = LocationService();
  late final TextEditingController _labelCtrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.locationLabel ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureGps() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _service.getCurrentPosition();
    if (!mounted) return;
    if (result.isSuccess) {
      final label = _labelCtrl.text.trim().isEmpty
          ? 'Localização atual'
          : _labelCtrl.text.trim();
      if (_labelCtrl.text.trim().isEmpty) _labelCtrl.text = label;
      widget.onChanged(
        latitude: result.latitude,
        longitude: result.longitude,
        label: label,
      );
    } else {
      setState(() => _error = result.error);
    }
    setState(() => _loading = false);
  }

  void _clear() {
    _labelCtrl.clear();
    widget.onChanged(latitude: null, longitude: null, label: null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLocation = widget.latitude != null && widget.longitude != null;
    final isIOS = Platform.isIOS;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Cabeçalho ────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                isIOS
                    ? CupertinoIcons.location_solid
                    : Icons.location_on_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Localização',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Rótulo opcional do local ────────────────────────────────────
          isIOS
              ? CupertinoTextField(
                  controller: _labelCtrl,
                  placeholder: 'Descrição do local (opcional)',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 12,
                  ),
                  onChanged: (v) => widget.onChanged(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    label: v.trim().isEmpty ? null : v.trim(),
                  ),
                )
              : TextField(
                  controller: _labelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do local (opcional)',
                    hintText: 'Ex.: Casa, Trabalho, Academia',
                  ),
                  onChanged: (v) => widget.onChanged(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    label: v.trim().isEmpty ? null : v.trim(),
                  ),
                ),
          const SizedBox(height: 10),

          // ── Ações: capturar GPS + limpar ────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AdaptativeActionButton(
                onPressed: _loading ? null : _captureGps,
                icon: isIOS
                    ? CupertinoIcons.location
                    : Icons.my_location_rounded,
                label: _loading
                    ? 'Capturando…'
                    : hasLocation
                        ? 'Atualizar via GPS'
                        : 'Usar minha localização',
                primary: true,
                loading: _loading,
              ),
              if (hasLocation)
                _AdaptativeActionButton(
                  onPressed: _loading ? null : _clear,
                  icon: isIOS
                      ? CupertinoIcons.clear_circled
                      : Icons.delete_outline,
                  label: 'Remover',
                  primary: false,
                ),
            ],
          ),

          // ── Erro (se houver) ────────────────────────────────────────────
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isIOS
                        ? CupertinoIcons.exclamationmark_triangle
                        : Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Preview do mapa + coords ────────────────────────────────────
          if (hasLocation) ...[
            const SizedBox(height: 12),
            _MapPreview(
              latitude: widget.latitude!,
              longitude: widget.longitude!,
            ),
            const SizedBox(height: 4),
            Text(
              'Lat ${widget.latitude!.toStringAsFixed(5)}, '
              'Lng ${widget.longitude!.toStringAsFixed(5)}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                color: theme.hintColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Botão adaptativo simples — Cupertino no iOS, Material no Android.
class _AdaptativeActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool primary;
  final bool loading;

  const _AdaptativeActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.primary = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: primary ? theme.colorScheme.primary : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            loading
                ? const CupertinoActivityIndicator()
                : Icon(icon, size: 18, color: primary ? Colors.white : null),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: primary ? Colors.white : null),
            ),
          ],
        ),
      );
    }
    return primary
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, size: 18),
            label: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
          );
  }
}

/// Preview do mapa OpenStreetMap centrado na coordenada.
/// Não precisa de API key — perfeito para projeto acadêmico.
class _MapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  const _MapPreview({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 160,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'br.com.guilhermeribeiro.tarefas_geo',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
