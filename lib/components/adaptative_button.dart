import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptativeButton extends StatelessWidget {
  final String label;
  final Function() onPressed;

  const AdaptativeButton(
    this.label,
    this.onPressed, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoButton(
            onPressed: onPressed,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Text(
              label,
              // CupertinoButton herda a cor do tema (roxo no nosso caso),
              // o que deixaria o texto invisível sobre o fundo roxo.
              // Força branco para garantir contraste.
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }
}
