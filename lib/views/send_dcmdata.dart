import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/class/creation.dart';
import '/class/utilisateur.dart';
import '/menus/menu_all.dart';
import '/tools/color.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../api_connection/api_connection.dart';
import '../bdd/dbhelper.dart';
import '../tools/circle_progress.dart';
import 'package:mime/mime.dart';

import 'wallet_screen.dart';

class SendDcmdata extends StatefulWidget {
  final Utilisateur utilisateur;

  const SendDcmdata({super.key, required this.utilisateur});

  @override
  State<SendDcmdata> createState() => _SendDcmdataState();
}

class _SendDcmdataState extends State<SendDcmdata> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  bool isLoadkaabu = false;
  int nbkaabu = 0;

  Future<void> getNbKaabu() async {
    int nombre = await dbHelper.getNbKaabu();

    setState(() {
      nbkaabu = nombre;
    });
  }

  @override
  void initState() {
    getNbKaabu();

    super.initState();
  }

  Future<void> uploadCreation() async {
    List<Creation> dataCreas = await dbHelper.getCreation();

    for (var datacrea in dataCreas) {
      String photoID = datacrea.photoID ?? "";

      // print("Photo : ${cico_photo},cico_nompostnom : ${cico.cico_nompostnom},cico_nom : ${cico.cico_nom},cico_idcampagne : ${cico.cico_idcampagne},cico_idgroupe : ${cico.cico_idgroupe},cico_idprestataire : ${cico.cico_idprestataire},cico_sexe : ${cico.cico_sexe},cico_adresse : ${cico.cico_adresse},cico_dateinscription : ${cico.cico_dateinscription},cico_datenaiss : ${cico.cico_datenaiss}, cico_telephone : ${cico.cico_telephone},cico_prenom : ${cico.cico_prenom},cico_idas : ${cico.cico_idas},codecico: ${cico.codecico},cico_sync :${cico.cico_sync}");

      if (photoID.isEmpty) {
      }
      // Les ménages qui ont des photos
      else {
        reqCreaWithPhoto(
          datacrea.idcreation.toString(),
          datacrea.infra_category ?? "",
          datacrea.agent_phone ?? "",
          datacrea.nom ?? "",
          datacrea.postnom ?? "",
          datacrea.prenom ?? "",
          datacrea.infra_phone ?? "",
          datacrea.login_infra ?? "",
          photoID,
        );
      }
    }
  }

  void reqCreaWithPhoto(
    String idcreation,
    String infra_category,
    String agent_phone,
    String nom,
    String postnom,
    String prenom,
    String infra_phone,
    String login_infra,
    String photoID,
  ) async {
    if (mounted) {
      setState(() {
        isLoadkaabu = true;
      });
    }

    try {
      var uri = Uri.parse(API.saveCreation); // Change avec ton URL

      var request = http.MultipartRequest('POST', uri);

      File imageFile = File(photoID);

      request.fields['creation_idutilisateur'] = widget
          .utilisateur
          .idutilisateur
          .toString();
      request.fields['infra_category'] = infra_category;
      request.fields['agent_phone'] = agent_phone;
      request.fields['nom'] = nom;
      request.fields['postnom'] = postnom;
      request.fields['prenom'] = prenom;
      request.fields['infra_phone'] = infra_phone;
      request.fields['login_infra'] = login_infra;
      request.fields['photo'] = photoID;

      // Détecter le type MIME du fichier
      String? mimeType = lookupMimeType(imageFile.path);

      //  print("Le fichier Image : ${imageFile.path}");

      request.files.add(
        await http.MultipartFile.fromPath(
          'photoID',
          imageFile.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (responseBody == "SUCCES") {
          await dbHelper.sentItem('creation', 'infra_phone', infra_phone);

          getNbKaabu();
        }

        print(responseBody);
      } else {
        Get.snackbar(
          "INTERNET INACTIF",
          "Veuillez vous connecter à l'internet pour envoyer des données !",
          backgroundColor: Colors.red,
          icon: Icon(Icons.wifi_off, color: whiteColor),
          duration: Duration(seconds: 5),
          colorText: whiteColor,
        );
      }
    } catch (e) {
      Get.snackbar(
        "INTERNET INACTIF",
        "Veuillez vous connecter à l'internet pour envoyer des données !",
        backgroundColor: Colors.red,
        icon: Icon(Icons.wifi_off, color: whiteColor),
        duration: Duration(seconds: 5),
        colorText: whiteColor,
      );
      if (mounted) {
        setState(() {
          {
            isLoadkaabu = false;
          }
        });
      }
    }

    if (mounted) {
      setState(() {
        {
          isLoadkaabu = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Téléversement"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.off(() => WalletScreen(utilisateur: widget.utilisateur));
          },
        ),
        actions: [MenuAll(utilisateur: widget.utilisateur)],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    color: primaryColor,
                    shadowColor: darcula,
                    elevation: 30,
                    child: InkWell(
                      onTap: () {
                        uploadCreation();
                      },
                      child: Column(
                        children: [
                          Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.3,
                                  height: 80,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.asset(
                                      "images/upload.png",
                                      color: blackColor,
                                    ),
                                  ),
                                ),
                                (isLoadkaabu)
                                    ? const Circle()
                                    : Text(
                                        "$nbkaabu Lignes",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 10),
                            child: const Text(
                              "Créations DSO",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
