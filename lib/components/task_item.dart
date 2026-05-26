import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

/// Item visual de uma tarefa na listagem.
///
/// Mostra:
///   - Avatar circular com o dia do mês (mantém o estilo do projeto original)
///   - Nome da tarefa em destaque
///   - Data/hora formatada em pt-BR
///   - Localização (label ou Lat/Lng) quando disponível
///   - Botão de excluir (Material) ou TextButton "Excluir" em telas largas
///   - Tap no item abre a edição (via callback)
class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  Color _statusColor(BuildContext context) {
    final isPast = task.dateTime.isBefore(DateTime.now());
    if (isPast) return Theme.of(context).disabledColor;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPast = task.dateTime.isBefore(DateTime.now());
    final dayLabel = DateFormat('dd/MMM', 'pt_BR').format(task.dateTime);
    final timeLabel = DateFormat('HH:mm').format(task.dateTime);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _statusColor(context),
            radius: 30,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: FittedBox(
                child: Text(
                  dayLabel.replaceAll('.', '').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            task.name,
            style: theme.textTheme.titleLarge?.copyWith(
              decoration: isPast ? TextDecoration.lineThrough : null,
              color: isPast ? theme.disabledColor : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 13, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormat("EEE, d 'de' MMM", 'pt_BR').format(task.dateTime)} · $timeLabel',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (task.hasLocation) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        task.locationLabel ??
                            'Lat ${task.latitude!.toStringAsFixed(4)}, '
                                'Lng ${task.longitude!.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: MediaQuery.of(context).size.width > 480
              ? TextButton.icon(
                  onPressed: onRemove,
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                  label: Text(
                    'Excluir',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.delete),
                  color: theme.colorScheme.error,
                  onPressed: onRemove,
                ),
        ),
      ),
    );
  }
}
