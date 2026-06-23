import '../models/task.dart';

/// Contrato de persistência das tarefas (camada de domínio).
///
/// A interface não conhece o backend — pode ser implementada por Firestore,
/// Supabase, SQLite ou um fake em memória nos testes. Isso mantém o
/// [TaskProvider] e a UI desacoplados da tecnologia de armazenamento.
abstract class TaskRepository {
  /// Emite a lista de tarefas em tempo real. Cada alteração no backend
  /// dispara um novo evento.
  Stream<List<Task>> watchTasks();

  /// Cria (ou sobrescreve) uma tarefa.
  Future<void> add(Task task);

  /// Atualiza uma tarefa existente.
  Future<void> update(Task task);

  /// Remove a tarefa de [id].
  Future<void> delete(String id);
}
