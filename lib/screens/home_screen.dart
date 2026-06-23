import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/task_list.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../routes/app_routes.dart';

/// Tela inicial: lista das tarefas, com estados de carregamento e erro.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openForm(BuildContext context, {Task? existing}) {
    Navigator.of(context).pushNamed(AppRoutes.taskForm, arguments: existing);
  }

  void _openDetail(BuildContext context, Task task) {
    Navigator.of(context).pushNamed(AppRoutes.taskDetail, arguments: task);
  }

  Future<void> _remove(BuildContext context, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<TaskProvider>().remove(id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Tarefa excluída.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir a tarefa.')),
      );
    }
  }

  Widget _getIconButton(IconData icon, VoidCallback fn) {
    return Platform.isIOS
        ? GestureDetector(onTap: fn, child: Icon(icon))
        : IconButton(icon: Icon(icon), onPressed: fn);
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.info : Icons.info_outline,
        () => Navigator.of(context).pushNamed(AppRoutes.about),
      ),
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.add : Icons.add,
        () => _openForm(context),
      ),
    ];

    final PreferredSizeWidget appBar;
    if (Platform.isIOS) {
      appBar = CupertinoNavigationBar(
        middle: const Text('Tarefas Geo'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: actions),
      );
    } else {
      appBar = AppBar(title: const Text('Tarefas Geo'), actions: actions);
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return _ErrorState(message: provider.error!);
            }
            return TaskList(
              onOpen: (task) => _openDetail(context, task),
              onRemove: (id) => _remove(context, id),
            );
          },
        ),
      ),
      floatingActionButton: Platform.isIOS
          ? null
          : FloatingActionButton(
              onPressed: () => _openForm(context),
              child: const Icon(Icons.add),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'OpenSans', fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
