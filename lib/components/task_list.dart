import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import 'task_item.dart';

/// Lista reativa de tarefas — consome o estado via `Consumer<TaskProvider>`.
///
/// **Responsivo:**
///   - Em telas estreitas: lista em coluna única
///   - Em telas largas (>= 720): limita largura a 720px para leitura
///     confortável em tablets/web
///   - Estado vazio mostra ilustração centralizada
class TaskList extends StatelessWidget {
  /// Chamado ao tocar numa tarefa — abre a tela de detalhe.
  final void Function(Task) onOpen;
  final void Function(String) onRemove;

  const TaskList({
    Key? key,
    required this.onOpen,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasks = provider.tasks;

        if (tasks.isEmpty) {
          return _EmptyState();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsivo: limita a largura em tablets/web.
            final maxW =
                constraints.maxWidth >= 720 ? 720.0 : double.infinity;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: ListView.builder(
                  itemCount: tasks.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (ctx, i) {
                    final task = tasks[i];
                    return Dismissible(
                      key: ValueKey(task.id),
                      direction: DismissDirection.endToStart,
                      background: _DismissBackground(),
                      confirmDismiss: (_) => _confirmDelete(context, task),
                      onDismissed: (_) => onRemove(task.id),
                      child: TaskItem(
                        task: task,
                        onTap: () => onOpen(task),
                        onRemove: () async {
                          final ok = await _confirmDelete(context, task);
                          if (ok ?? false) onRemove(task.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Task task) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Excluir tarefa?',
          style: TextStyle(fontFamily: 'OpenSans', fontWeight: FontWeight.bold),
        ),
        content: Text(
          '"${task.name}" será removida da lista.',
          style: const TextStyle(fontFamily: 'OpenSans'),
        ),
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
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hint = Theme.of(context).hintColor;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 72,
                color: primary,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Nenhuma tarefa cadastrada',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Toque no botão "+" para criar sua primeira tarefa com data, hora e localização.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                height: 1.4,
                color: hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
