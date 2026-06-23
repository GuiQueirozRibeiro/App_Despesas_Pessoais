import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geo_tools/geo_tools.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'firebase_options.dart';
import 'providers/task_provider.dart';
import 'repositories/firestore_task_repository.dart';
import 'repositories/task_repository.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega símbolos de pt-BR para o intl.DateFormat funcionar offline.
  await initializeDateFormatting('pt_BR', null);
  // Inicializa o Firebase com as opções geradas pelo flutterfire configure.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final taskRepository = FirestoreTaskRepository(FirebaseFirestore.instance);
  runApp(TarefasGeoApp(taskRepository: taskRepository));
}

class TarefasGeoApp extends StatelessWidget {
  final TaskRepository taskRepository;
  const TarefasGeoApp({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Cliente da API de clima (package interno geo_tools).
        Provider<WeatherClient>(
          create: (_) => WeatherClient(apiKey: AppConfig.openWeatherApiKey),
          dispose: (_, client) => client.close(),
        ),
        // Estado das tarefas, alimentado pelo repositório Firestore.
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(taskRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Tarefas Geo',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        locale: const Locale('pt', 'BR'),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData();
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.purple,
        secondary: Colors.amber,
      ),
      textTheme: base.textTheme.copyWith(
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
    );
  }
}
