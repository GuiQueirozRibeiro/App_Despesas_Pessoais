import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Versão adaptativa do `AdaptativeDatePicker` que coleta **data + hora**
/// — atendendo à especificação do trabalho que pede ambos.
///
/// - iOS: usa `CupertinoDatePicker` com modo `dateAndTime`
/// - Android: usa `showDatePicker` + `showTimePicker` nativos em sequência
///
/// A escolha de "spinner inline" no iOS e "diálogos modais" no Android
/// segue a convenção do projeto (`adaptative_date_picker.dart`).
class AdaptativeDateTimePicker extends StatelessWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime)? onDateTimeChanged;

  const AdaptativeDateTimePicker({
    this.selectedDateTime,
    this.onDateTimeChanged,
    Key? key,
  }) : super(key: key);

  Future<void> _showAndroidPickers(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedDateTime ?? DateTime.now(),
      ),
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    onDateTimeChanged?.call(combined);
  }

  @override
  Widget build(BuildContext context) {
    final initial = selectedDateTime ?? DateTime.now();

    return Platform.isIOS
        ? SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: initial,
              minimumDate: DateTime.now().subtract(const Duration(days: 365)),
              maximumDate:
                  DateTime.now().add(const Duration(days: 365 * 5)),
              onDateTimeChanged: (newDate) =>
                  onDateTimeChanged?.call(newDate),
              use24hFormat: true,
            ),
          )
        : SizedBox(
            height: 70,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    selectedDateTime == null
                        ? 'Nenhuma data/hora selecionada!'
                        : 'Selecionado: '
                            '${DateFormat("dd/MM/y 'às' HH:mm").format(selectedDateTime!)}',
                    style: const TextStyle(fontFamily: 'OpenSans'),
                  ),
                ),
                TextButton(
                  onPressed: () => _showAndroidPickers(context),
                  child: const Text(
                    'Data e Hora',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'OpenSans',
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
