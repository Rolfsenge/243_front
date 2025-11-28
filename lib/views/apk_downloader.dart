import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../api_connection/api_connection.dart';
import '../tools/circle_progress.dart';
import '../tools/color.dart';
import 'apk_updater.dart';
import 'no_apk_update.dart';
import 'not_connected.dart';

class ApkDownloader extends StatefulWidget {
  const ApkDownloader({super.key});

  @override
  State<ApkDownloader> createState() => _ApkDownloaderState();
}

class _ApkDownloaderState extends State<ApkDownloader> {
  bool _isUpTodate = true;

  late String status = 'loading';

  late String currentVersion = "";
  late String latestVersion = "";
  late String buildNumber = "";

  // Obtention des versions encours

  Future<void> getCurrentVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      setState(() {
        currentVersion = packageInfo.version;
        buildNumber = packageInfo.buildNumber;

        print(packageInfo.version);
      });
    } catch (e) {
      print("Erreur lors de la vérification de mise à jour: $e");
    }
  }

  Future<void> checkForUpdate() async {
    setState(() {
      status = "waiting";
    });

    // Vérifier la connexion internet et récupérer la version serveur

    try {
      var response = await http.get(Uri.parse(API.apk_version));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          status = "connected";
        });

        if (data != null) {
          String latestVersion = data["version_code"];

          // String apkUrl = '${API.hostConnect}/' + data["apk_url"];

          if (latestVersion.isNotEmpty && currentVersion != latestVersion) {
            // une mise est disponible
            setState(() {
              status = "updateAvalable";
            });
          } else {
            setState(() {
              status = "updateUnAvalable";
            });
          }
        } else {
          setState(() {
            status = "notConnected";
          });
        }
      } else {
        setState(() {
          status = "notConnected";
        });
      }
    } on Exception catch (e) {
      setState(() {
        status = "notConnected";
      });
      print("Problème de connexion: $e");
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    getCurrentVersion();

    checkForUpdate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: switch (status) {
            'waiting' => const Circle(),
            'notConnected' => NotConnected(),
            'updateUnAvalable' => NoApkUpdate(currentVersion: currentVersion),
            'updateAvalable' => ApkUpdater(), // Cas par défaut
            // TODO: Handle this case.
            _ => Text(''),
          },
        ),
      ),
    );
  }
}
