import 'package:flutter/material.dart';

/// Tela "Sobre" — créditos e tecnologias usadas (acessada por rota nomeada).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.event_available_rounded,
              size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Center(
            child: Text('Tarefas Geo',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Center(
            child: Text('Tarefas com localização e clima',
                style: TextStyle(fontFamily: 'OpenSans')),
          ),
          const SizedBox(height: 24),
          const _Section(title: 'Aluno', body: 'Guilherme Queiroz Ribeiro'),
          const _Section(
            title: 'Disciplina',
            body: 'Desenvolvimento Mobile com Flutter — Pós-Graduação',
          ),
          const _Section(
            title: 'Tecnologias',
            body: 'Flutter • Provider • Cloud Firestore • OpenWeather (API REST) '
                '• Geolocator (GPS) • flutter_map (OpenStreetMap) • '
                'package interno geo_tools',
          ),
          const _Section(
            title: 'Como funciona',
            body: 'Crie tarefas com data, hora e localização. As tarefas são '
                'salvas no Cloud Firestore e sincronizam em tempo real. Na tela '
                'de detalhe, o app mostra o clima atual no local da tarefa e '
                'calcula a distância a partir da sua posição.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 4),
          Text(body,
              style: const TextStyle(
                  fontFamily: 'OpenSans', fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}
