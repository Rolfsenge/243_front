import 'package:flutter/material.dart';

class Commentaire extends StatelessWidget {
  final String contenu;
  const Commentaire({super.key, required this.contenu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(
        contenu,
        style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
      ),
    );
  }
}
