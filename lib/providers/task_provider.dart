import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

/// Estado global das tarefas — `ChangeNotifier` (Provider).
///
/// Em vez de guardar as tarefas em memória, o provider **escuta** o
/// [TaskRepository] (Firestore em tempo real). Toda escrita vai para o
/// backend e a lista local é atualizada quando o stream emite — fonte única
/// de verdade na nuvem.
class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;
  StreamSubscription<List<Task>>? _subscription;

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  TaskProvider(this._repository) {
    _start();
  }

  /// Assina o stream de tarefas do repositório.
  void _start() {
    _subscription = _repository.watchTasks().listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        _isLoading = false;
        _error = 'Não foi possível carregar as tarefas. Verifique sua conexão.';
        notifyListeners();
      },
    );
  }

  /// Lista imutável e ordenada por data — UI consome via Consumer/Selector.
  List<Task> get tasks {
    final sorted = [..._tasks]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return List.unmodifiable(sorted);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _tasks.length;

  /// Tarefas dos próximos 7 dias — usado por widgets resumo.
  List<Task> get upcoming {
    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: 7));
    return tasks
        .where((t) => t.dateTime.isAfter(now) && t.dateTime.isBefore(cutoff))
        .toList();
  }

  Task? findById(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// As operações abaixo apenas delegam ao repositório. Não fazem
  /// `notifyListeners()`: a atualização chega pelo stream em [_start],
  /// evitando estado duplicado/divergente entre local e nuvem.
  Future<void> add(Task task) => _repository.add(task);

  Future<void> update(Task task) => _repository.update(task);

  Future<void> remove(String id) => _repository.delete(id);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
