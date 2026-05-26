import 'package:flutter/material.dart';

import '../models/task.dart';
import 'adaptative_button.dart';
import 'adaptative_date_time_picker.dart';
import 'adaptative_location_picker.dart';
import 'adaptative_text_field.dart';

/// Formulário compartilhado para **criar e editar** tarefas.
///
/// Quando recebe `existing == null`, está no modo criação.
/// Quando recebe uma Task em `existing`, mostra os dados preenchidos e
/// devolve a versão editada no callback. Mesma UI dos dois lados.
///
/// **Responsivo:** envolto em `SingleChildScrollView` e usa o `viewInsets`
/// pra não cobrir o conteúdo quando o teclado abre.
class TaskForm extends StatefulWidget {
  final Task? existing;
  final void Function(
    String name,
    DateTime dateTime,
    double? latitude,
    double? longitude,
    String? locationLabel,
  ) onSubmit;

  const TaskForm({
    Key? key,
    required this.onSubmit,
    this.existing,
  }) : super(key: key);

  bool get isEditing => existing != null;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late final TextEditingController _nameController;
  late DateTime _selectedDateTime;
  double? _latitude;
  double? _longitude;
  String? _locationLabel;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _selectedDateTime = e?.dateTime ?? _suggestedDateTime();
    _latitude = e?.latitude;
    _longitude = e?.longitude;
    _locationLabel = e?.locationLabel;
  }

  /// Sugestão razoável de horário: próxima hora cheia.
  DateTime _suggestedDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _validationError = 'Informe o nome da tarefa.');
      return;
    }
    if (name.length < 2) {
      setState(() => _validationError = 'Nome muito curto.');
      return;
    }

    widget.onSubmit(
      name,
      _selectedDateTime,
      _latitude,
      _longitude,
      _locationLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.only(
            top: 10,
            right: 10,
            left: 10,
            bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header com título ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Nome ─────────────────────────────────────────────────────
              AdaptativeTextField(
                label: 'Nome da tarefa',
                controller: _nameController,
                onSubmitted: (_) => _submitForm(),
              ),

              // ── Data + Hora ──────────────────────────────────────────────
              AdaptativeDateTimePicker(
                selectedDateTime: _selectedDateTime,
                onDateTimeChanged: (newDt) {
                  setState(() => _selectedDateTime = newDt);
                },
              ),

              const SizedBox(height: 4),
              const Divider(),

              // ── Geolocalização ───────────────────────────────────────────
              AdaptativeLocationPicker(
                latitude: _latitude,
                longitude: _longitude,
                locationLabel: _locationLabel,
                onChanged: ({
                  required latitude,
                  required longitude,
                  required label,
                }) {
                  setState(() {
                    _latitude = latitude;
                    _longitude = longitude;
                    _locationLabel = label;
                  });
                },
              ),

              // ── Erro de validação ────────────────────────────────────────
              if (_validationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    _validationError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                    ),
                  ),
                ),

              // ── Ações ───────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AdaptativeButton(
                    widget.isEditing ? 'Salvar alterações' : 'Criar Tarefa',
                    _submitForm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
