import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String? completePhone; // pour stocker le numéro complet
  String marque = '';
  String modele = '';
  String name = '';
  String? numeroSerie = '';

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  Future<void> getDeviceInfo() async {
    // Vous pouvez utiliser le package device_info_plus pour obtenir des informations sur l'appareil
    // Ajoutez device_info_plus à votre pubspec.yaml
    // import 'package:device_info_plus/device_info_plus.dart';
    // Voici un exemple simple :
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        var info = await deviceInfo.androidInfo;
        setState(() {
          marque = info.brand;
          modele = info.model;
          name = info.name;
          // numeroSerie = info.id; // Utilisation de l'ID comme numéro de série
        });
      } else if (Platform.isIOS) {
        var info = await deviceInfo.iosInfo;
        setState(() {
          marque = 'Apple';
          modele = info.utsname.machine;
          // numeroSerie = info.identifierForVendor;
        });
      }
    } catch (e) {
      debugPrint("Erreur device info: $e");
      setState(() {
        marque = 'Inconnue';
        modele = 'Inconnu';
        numeroSerie = 'Non disponible';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: Text("Performances Orange"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Marque : $marque et Modele : $modele")
          ],
        ),
      ),
    );
  }
}
