import 'package:flutter/material.dart';

import '../tools/color.dart';
class NoApkUpdate extends StatelessWidget {
  final String currentVersion;
  const NoApkUpdate({super.key, required this.currentVersion});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check,
          size: 100,
          color: whiteColor,
        ),
        SizedBox(
          height: 40,
        ),
        const Text(
          "Vous utilisez +243 à jour !",
          style: TextStyle(color: whiteColor),
        ),
        SizedBox(
          height: 20,
        ),
        Text("Version : $currentVersion", style: TextStyle(color: whiteColor)),
      ],
    );
  }
}


