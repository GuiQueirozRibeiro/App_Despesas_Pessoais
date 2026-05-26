import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'components/task_form.dart';
import 'components/task_list.dart';
import 'models/task.dart';
import 'providers/task_provider.dart';

/// Key global do ScaffoldMessenger.
///
/// O SnackBar é disparado a partir de um callback do bottom sheet — naquele
/// momento o `context` original já pode ter sido reconstruído. Usar a key
/// global garante acesso direto ao ScaffoldMessenger do MaterialApp sem
/// depender da árvore de contextos atual.
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega símbolos de pt-BR para o intl.DateFormat funcionar offline.
  await initializeDateFormatting('pt_BR', null);
  runApp(const TarefasGeoApp());
}

class TarefasGeoApp extends StatelessWidget {
  const TarefasGeoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tema = ThemeData();

    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'Tarefas Geo',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: rootMessengerKey,

        // Locale pt-BR para os pickers nativos.
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        locale: const Locale('pt', 'BR'),

        theme: tema.copyWith(
          colorScheme: tema.colorScheme.copyWith(
            primary: Colors.purple,
            secondary: Colors.amber,
          ),
          textTheme: tema.textTheme.copyWith(
            titleLarge: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            labelLarge: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  /// Abre o bottom sheet de criação OU edição.
  /// Se `existing == null` é criação; caso contrário, edição.
  void _openTaskFormModal(BuildContext context, {Task? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return TaskForm(
          existing: existing,
          onSubmit: (name, dateTime, lat, lng, label) {
            final provider = context.read<TaskProvider>();
            if (existing == null) {
              provider.add(Task(
                name: name,
                dateTime: dateTime,
                latitude: lat,
                longitude: lng,
                locationLabel: label,
              ));
            } else {
              provider.update(existing.copyWith(
                name: name,
                dateTime: dateTime,
                latitude: lat,
                longitude: lng,
                locationLabel: label,
                clearLocation: lat == null,
              ));
            }
            Navigator.of(context).pop();
            rootMessengerKey.currentState
              ?..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    existing == null ? 'Tarefa criada!' : 'Tarefa atualizada!',
                    style: const TextStyle(fontFamily: 'OpenSans'),
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
          },
        );
      },
    );
  }

  /// Botão de ação adaptativo (mantém o padrão do projeto original).
  Widget _getIconButton(IconData icon, VoidCallback fn) {
    return Platform.isIOS
        ? GestureDetector(onTap: fn, child: Icon(icon))
        : IconButton(icon: Icon(icon), onPressed: fn);
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _getIconButton(
        Platform.isIOS ? CupertinoIcons.add : Icons.add,
        () => _openTaskFormModal(context),
      ),
    ];

    // CupertinoNavigationBar implementa ObstructingPreferredSizeWidget,
    // então cabe no slot `appBar` do Scaffold. Manter Scaffold como raiz
    // garante que ScaffoldMessenger encontre um ancestral para o SnackBar.
    final PreferredSizeWidget appBar;
    if (Platform.isIOS) {
      appBar = CupertinoNavigationBar(
        middle: const Text('Tarefas Geo'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      );
    } else {
      appBar = AppBar(
        title: const Text('Tarefas Geo'),
        actions: actions,
      );
    }

    final bodyPage = SafeArea(
      child: TaskList(
        onEdit: (task) => _openTaskFormModal(context, existing: task),
        onRemove: (id) => context.read<TaskProvider>().remove(id),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: bodyPage,
      // No iOS o botão "+" fica na nav bar; no Android usamos FAB.
      floatingActionButton: Platform.isIOS
          ? null
          : FloatingActionButton(
              onPressed: () => _openTaskFormModal(context),
              child: const Icon(Icons.add),
            ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }
}
