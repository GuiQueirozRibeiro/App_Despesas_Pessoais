/// Modelo de uma tarefa em memória.
///
/// Atende à especificação do trabalho:
///   - [name] nome/título da tarefa
///   - [dateTime] data + hora marcada
///   - [latitude]/[longitude] geolocalização opcional (via GPS ou manual)
///   - [locationLabel] descrição amigável do local (ex.: "Casa", "Trabalho")
class Task {
  final String id;
  final String name;
  final DateTime dateTime;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;

  Task({
    String? id,
    required this.name,
    required this.dateTime,
    this.latitude,
    this.longitude,
    this.locationLabel,
  }) : id = id ?? _generateId();

  /// ID simples baseado em microsegundos + contador estático.
  /// Suficiente para tarefas em memória — sem dependência externa.
  static int _counter = 0;
  static String _generateId() {
    _counter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }

  bool get hasLocation => latitude != null && longitude != null;

  /// Cria uma cópia com campos alterados — usado pela edição.
  Task copyWith({
    String? name,
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    String? locationLabel,
    bool clearLocation = false,
  }) {
    return Task(
      id: id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      locationLabel:
          clearLocation ? null : (locationLabel ?? this.locationLabel),
    );
  }
}
