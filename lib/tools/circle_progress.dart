import 'package:flutter/material.dart';
import '/tools/color.dart';

class Circle extends StatelessWidget {
  const Circle({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, // Largeur souhaitée
      height: 20, // Hauteur souhaitée
      child: CircularProgressIndicator(
        strokeWidth: 2,
        value: null,
        backgroundColor: Colors.white,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).shadowColor,
        ), // Couleur de progression
      ),
    );
  }
}

class CirclePimary extends StatelessWidget {
  const CirclePimary({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, // Largeur souhaitée
      height: 20, // Hauteur souhaitée
      child: CircularProgressIndicator(
        strokeWidth: 2,
        value: null,
        backgroundColor: primaryColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).shadowColor,
        ), // Couleur de progression
      ),
    );
  }
}

class CircleBig extends StatelessWidget {
  const CircleBig({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50, // Largeur souhaitée
      height: 50, // Hauteur souhaitée
      child: CircularProgressIndicator(
        strokeWidth: 2,
        value: null,
        backgroundColor: Colors.white,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).shadowColor,
        ), // Couleur de progression
      ),
    );
  }
}
