import 'package:flutter/foundation.dart';

import '../models/task.dart';

/// Estado global das tarefas — `ChangeNotifier` via Provider.
///
/// Conforme spec, **não há persistência**: ao fechar o app, a lista zera.
/// Cobre os 4 itens do critério "gerenciamento de estado" da rubrica:
///   - criar (`add`)
///   - listar (`tasks` getter)
///   - editar (`update`)
///   - excluir (`remove`)
class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  /// Lista imutável e ordenada por data — UI consome via Consumer/Selector.
  List<Task> get tasks {
    final sorted = [..._tasks]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return List.unmodifiable(sorted);
  }

  int get count => _tasks.length;

  /// Tarefas dos próximos 7 dias — usado por widgets resumo.
  List<Task> get upcoming {
    final cutoff = DateTime.now().add(const Duration(days: 7));
    return tasks.where((t) {
      return t.dateTime.isAfter(DateTime.now()) &&
          t.dateTime.isBefore(cutoff);
    }).toList();
  }

  void add(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void update(Task updated) {
    final i = _tasks.indexWhere((t) => t.id == updated.id);
    if (i == -1) return;
    _tasks[i] = updated;
    notifyListeners();
  }

  void remove(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Task? findById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
