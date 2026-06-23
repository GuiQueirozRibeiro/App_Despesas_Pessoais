import 'package:flutter/material.dart';

import '../models/task.dart';
import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../screens/task_detail_screen.dart';
import '../screens/task_form_screen.dart';

/// Nomes das rotas do app, centralizados para evitar strings soltas.
abstract final class AppRoutes {
  static const String home = '/';
  static const String taskForm = '/task-form';
  static const String taskDetail = '/task-detail';
  static const String about = '/about';
}

/// Roteador central do app.
///
/// Usamos [onGenerateRoute] (em vez do mapa estático `routes:`) porque algumas
/// telas recebem **argumentos tipados** — a tarefa a editar ou detalhar. O
/// roteador faz o cast do `settings.arguments` e constrói a tela certa.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _build(const HomeScreen(), settings);

      case AppRoutes.taskForm:
        // Argumento opcional: a Task a editar (null = criação).
        final task = settings.arguments as Task?;
        return _build(TaskFormScreen(existing: task), settings);

      case AppRoutes.taskDetail:
        final task = settings.arguments as Task;
        return _build(TaskDetailScreen(task: task), settings);

      case AppRoutes.about:
        return _build(const AboutScreen(), settings);

      default:
        return _build(
          Scaffold(
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _build(Widget page, RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}
