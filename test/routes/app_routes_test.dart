import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tarefas_geo/models/task.dart';
import 'package:tarefas_geo/routes/app_routes.dart';

void main() {
  group('AppRouter.onGenerateRoute', () {
    test('gera rota para a home', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.home),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('gera rota para o formulário (criação, sem argumento)', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.taskForm, arguments: null),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('gera rota para o detalhe com a Task como argumento', () {
      final task = Task(id: '1', name: 'X', dateTime: DateTime(2026, 1, 1));
      final route = AppRouter.onGenerateRoute(
        RouteSettings(name: AppRoutes.taskDetail, arguments: task),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('gera rota para a tela Sobre', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: AppRoutes.about),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    test('rota desconhecida cai no fallback', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(name: '/inexistente'),
      );
      expect(route, isA<MaterialPageRoute>());
    });
  });
}
