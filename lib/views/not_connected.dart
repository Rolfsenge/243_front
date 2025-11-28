import 'package:flutter/material.dart';

import '../tools/color.dart';

class NotConnected extends StatefulWidget {
  const NotConnected({super.key});

  @override
  State<NotConnected> createState() => _NotConnectedState();
}

class _NotConnectedState extends State<NotConnected> {
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              Icons.wifi_off,
              size: 100,
              color: whiteColor,
            ),
            Text(
              "Pas de connexion internet",
              style: TextStyle(color: whiteColor),
            )
          ],
        ),
      ),
    );
  }
}
