import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
//import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../tools/color.dart';
import 'apk_downloader.dart';

class UpdateChecker extends StatefulWidget {
  const UpdateChecker({super.key});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
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
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Icon(Icons.system_update, size: 150, color: whiteColor),
                const SizedBox(height: 30),
                Text(
                  "Mise à jour +243",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: whiteColor),
                ),
                const SizedBox(height: 30),
                Text(
                  "Cliquer sur le bouton ci-dessous pour rechercher des mises à jour en ligne et les installer",
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: whiteColor),
                ),

                const SizedBox(height: 30),

                //button
                Material(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(25),
                  child: InkWell(
                    onTap: () {
                      Get.to(() => ApkDownloader());
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 28,
                      ),
                      child: const Text(
                        "RECHERCHER",
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
