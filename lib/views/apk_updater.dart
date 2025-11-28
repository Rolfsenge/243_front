import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../api_connection/api_connection.dart';
import '/tools/color.dart';

class ApkUpdater extends StatefulWidget {
  const ApkUpdater({super.key});

  @override
  State<ApkUpdater> createState() => _ApkUpdaterState();
}

class _ApkUpdaterState extends State<ApkUpdater> {
  static const platform = MethodChannel('apk_installer_channel');

  double _progress = 0.0;
  bool _isDownloading = false;
  String? _apkPath;

  Future<void> _checkPermissions() async {
    if (!Platform.isAndroid) return;
    if (!await Permission.requestInstallPackages.isGranted) {
      await Permission.requestInstallPackages.request();
    }
    if (!await Permission.manageExternalStorage.isGranted &&
        !await Permission.storage.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _downloadApk() async {
    const apkUrl = API.android;
    const fileName = 'update.apk';

    try {
      setState(() {
        _isDownloading = true;
        _progress = 0.0;
      });

      await _checkPermissions();

      Directory dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory() ?? dir;
        await dir.create(recursive: true);
      }

      final file = File('${dir.path}/$fileName');

      // suppression sécurisée
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}

      print('📥 Téléchargement depuis $apkUrl');
      final response =
      await http.Client().send(http.Request('GET', Uri.parse(apkUrl)));

      if (response.statusCode != 200) {
        throw Exception("Échec du téléchargement (${response.statusCode})");
      }

      final total = response.contentLength ?? 0;
      int received = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (total > 0) {
          setState(() => _progress = received / total);
        }
      }

      await sink.flush();
      await sink.close();

      setState(() {
        _apkPath = file.path;
        _isDownloading = false;
      });

      print("✅ Téléchargement terminé : $_apkPath");
      await _installApk(_apkPath!);
    } catch (e) {
      print('❌ Erreur : $e');
      setState(() => _isDownloading = false);
    }
  }

  /// 🔹 Lancer l’installation via FileProvider natif
  Future<void> _installApk(String path) async {
    try {
      final result = await platform.invokeMethod('installApk', {'path': path});
      print('📦 Installation → $result');
    } on PlatformException catch (e) {
      print('❌ Erreur installation : ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur installation : ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isDownloading
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 8,
              color: whiteColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${(_progress * 100).toStringAsFixed(1)} %',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
          : ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _downloadApk,
        icon: const Icon(Icons.download, color: primaryColor),
        label: const Text(
          'Télécharger & Installer',
          style: TextStyle(fontSize: 16, color: primaryColor),
        ),
      ),
    );
  }
}
