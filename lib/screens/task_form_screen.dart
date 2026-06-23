import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/task_form.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

/// Tela de criação/edição de tarefa (acessada por rota nomeada).
///
/// Recebe [existing] = null para criar; uma [Task] para editar. O salvamento
/// é assíncrono (Firestore) e trata erros mostrando um SnackBar.
class TaskFormScreen extends StatefulWidget {
  final Task? existing;
  const TaskFormScreen({super.key, this.existing});

  bool get isEditing => existing != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  bool _saving = false;

  Future<void> _onSubmit(
    String name,
    DateTime dateTime,
    double? lat,
    double? lng,
    String? label,
  ) async {
    final provider = context.read<TaskProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await provider.add(Task(
          name: name,
          dateTime: dateTime,
          latitude: lat,
          longitude: lng,
          locationLabel: label,
        ));
      } else {
        await provider.update(widget.existing!.copyWith(
          name: name,
          dateTime: dateTime,
          latitude: lat,
          longitude: lng,
          locationLabel: label,
          clearLocation: lat == null,
        ));
      }
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.existing == null ? 'Tarefa criada!' : 'Tarefa atualizada!',
          ),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Erro ao salvar. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: TaskForm(existing: widget.existing, onSubmit: _onSubmit),
          ),
          if (_saving)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
