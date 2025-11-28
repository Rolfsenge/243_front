import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/class/creation.dart';
import '/class/reset_kaabu.dart';
import '/class/reset_zebra.dart';
import '/class/rlms_class.dart';
import '../class/zebra.dart';
import '/class/cicos.dart';
import '/class/utilisateur.dart';
import '/menus/menu_all.dart';
import '/tools/color.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../api_connection/api_connection.dart';
import '../bdd/dbhelper.dart';
import '../tools/circle_progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import 'wallet_screen.dart';

class Televerser extends StatefulWidget {
  final Utilisateur utilisateur;
  const Televerser({super.key, required this.utilisateur});

  @override
  State<Televerser> createState() => _TeleverserState();
}

class _TeleverserState extends State<Televerser> {
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  bool isLoadkaabu = false;
  bool isLoadZebra = false;
  bool isLoadCico = false;
  bool isLoadRlms = false;
  bool isLoadResetKaabu = false;
  bool isLoadResetZebra = false;

  int nbkaabu = 0;
  int nbCicos = 0;
  int nbZebra = 0;
  int nbRlms = 0;
  int nbResetZebra = 0;
  int nbResetKaabu = 0;

  Future<void> getNbCicos() async {
    int nombre = await dbHelper.getNbCicoNotSync();

    setState(() {
      nbCicos = nombre;
    });
  }

  Future<void> getNbKaabu() async {
    int nombre = await dbHelper.getNbKaabu();

    setState(() {
      nbkaabu = nombre;
    });
  }

  Future<void> getNbZebra() async {
    int nombre = await dbHelper.getNbZebra();

    setState(() {
      nbZebra = nombre;
    });
  }

  Future<void> getNbRlms() async {
    int nombre = await dbHelper.getNbRlms();

    setState(() {
      nbRlms = nombre;
    });
  }

  Future<void> getNbResetKaabu() async {
    int nombre = await dbHelper.getNbResetKaabu();

    setState(() {
      nbResetKaabu = nombre;
    });
  }

  Future<void> getNbResetZebra() async {
    int nombre = await dbHelper.getNbResetZebra();

    setState(() {
      nbResetZebra = nombre;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getNbCicos();
    getNbKaabu();
    getNbRlms();
    getNbZebra();
    getNbResetKaabu();
    getNbResetZebra();

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

  Future<void> uploadCicos() async {
    List<Cicos> dataCicos = await dbHelper.getCicoNotSync();

    for (var datacico in dataCicos) {
      String cico_photo = datacico.carteId ?? "";

      // print("Photo : ${cico_photo},cico_nompostnom : ${cico.cico_nompostnom},cico_nom : ${cico.cico_nom},cico_idcampagne : ${cico.cico_idcampagne},cico_idgroupe : ${cico.cico_idgroupe},cico_idprestataire : ${cico.cico_idprestataire},cico_sexe : ${cico.cico_sexe},cico_adresse : ${cico.cico_adresse},cico_dateinscription : ${cico.cico_dateinscription},cico_datenaiss : ${cico.cico_datenaiss}, cico_telephone : ${cico.cico_telephone},cico_prenom : ${cico.cico_prenom},cico_idas : ${cico.cico_idas},codecico: ${cico.codecico},cico_sync :${cico.cico_sync}");

      if (cico_photo.isEmpty) {
        reqWithOutPhoto(
          datacico.idcicos.toString(),
          datacico.msisdn,
          datacico.nom,
          datacico.postnom,
          datacico.prenom,
          datacico.numParent ?? "",
          widget.utilisateur.idutilisateur.toString(),
          datacico.adresse ?? "",
          datacico.sexe ?? "",
          datacico.nationalite ?? "",
          datacico.numeroId ?? "",
          datacico.lieuNaissance ?? "",
          datacico.dateNaissance ?? "",
          datacico.typeCarteId ?? "",
        );
      }
      // Les ménages qui ont des photos
      else {
        reqWithPhoto(
          datacico.idcicos.toString(),
          datacico.msisdn,
          datacico.nom,
          datacico.postnom,
          datacico.prenom,
          datacico.carteId ?? "",
          datacico.numParent ?? "",
          widget.utilisateur.idutilisateur.toString(),
          datacico.adresse ?? "",
          datacico.sexe ?? "",
          datacico.nationalite ?? "",
          datacico.numeroId ?? "",
          datacico.lieuNaissance ?? "",
          datacico.dateNaissance ?? "",
          datacico.typeCarteId ?? "",
        );
      }
    }
  }

  reqWithOutPhoto(
    String idcicos,
    String msisdn,
    String nom,
    String postnom,
    String prenom,
    String numParent,
    String userId,
    String adresse,
    String sexe,
    String nationalite,
    String numeroId,
    String lieuNaissance,
    String dateNaissance,
    String typeCarteId,
  ) async {
    final url = Uri.parse(API.saveCicoSansPhoto);
    if (mounted) {
      setState(() {
        isLoadCico = true;
      });
    }

    final response = await http.post(
      url,
      body: {
        "idcicos": idcicos,
        "msisdn": msisdn,
        "nom": nom,
        "postnom": postnom,
        "prenom": prenom,
        "num_parent": numParent,
        "user_id": userId,
        "adresse": adresse,
        "sexe": sexe,
        "nationalite": nationalite,
        "numero_id": numeroId,
        "lieu_naissance": lieuNaissance,
        "date_naissance": dateNaissance,
        "type_carte_id": typeCarteId,
      },
    );

    if (response.statusCode == 200) {
      // Si le serveur renvoie un code 201 Created
      final data = response.body;

      if (data == "SUCCES") {
        await dbHelper.sentItem('cicos', 'idcicos', idcicos);

        getNbCicos();
      }

      // Traitez les données ici
    } else {
      {
        Get.snackbar(
          "INTERNET INACTIF",
          "Veuillez vous connecter à l'internet pour envoyer des données !",
          backgroundColor: Colors.red,
          icon: Icon(Icons.wifi_off, color: whiteColor),
          duration: Duration(seconds: 5),
          colorText: whiteColor,
        );
      }
      if (mounted) {
        setState(() {
          isLoadCico = false;
        });
      }
    }
  }

  void reqWithPhoto(
    String idcicos,
    String msisdn,
    String nom,
    String postnom,
    String prenom,
    String carteId,
    String numParent,
    String userId,
    String adresse,
    String sexe,
    String nationalite,
    String numeroId,
    String lieuNaissance,
    String dateNaissance,
    String typeCarteId,
  ) async {
    if (mounted) {
      setState(() {
        isLoadCico = true;
      });
    }

    try {
      var uri = Uri.parse(API.saveCicoAvecPhoto); // Change avec ton URL

      var request = http.MultipartRequest('POST', uri);

      File imageFile = File(carteId);

      // request.fields['nom'] = nomController.text;
      request.fields['msisdn'] = msisdn;
      request.fields['nom'] = nom;
      request.fields['postnom'] = postnom;
      request.fields['prenom'] = prenom;
      request.fields['carte_id'] = carteId;
      request.fields['num_parent'] = numParent;
      request.fields['user_id'] = userId;
      request.fields['adresse'] = adresse;
      request.fields['sexe'] = sexe;
      request.fields['nationalite'] = nationalite;
      request.fields['numero_id'] = numeroId;
      request.fields['lieu_naissance'] = lieuNaissance;
      request.fields['date_naissance'] = dateNaissance;
      request.fields['type_carte_id'] = typeCarteId;

      // Détecter le type MIME du fichier
      String? mimeType = lookupMimeType(imageFile.path);

      //  print("Le fichier Image : ${imageFile.path}");

      request.files.add(
        await http.MultipartFile.fromPath(
          'cico_photo',
          imageFile.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print(responseBody);

      if (response.statusCode == 200) {
        if (responseBody == "SUCCES") {
          await dbHelper.sentItem('cicos', 'idcicos', idcicos);

          getNbCicos();
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
            isLoadCico = false;
          }
        });
      }
    }

    if (mounted) {
      setState(() {
        {
          isLoadCico = false;
        }
      });
    }
  }

  Future<void> uploadResetKaabu() async {
    List<ResetKaabu> resets = await dbHelper.getResetKaabu();
    // parourir le tableau avec for

    for (var reset in resets) {
      reqResetKaabu(reset.numero);
    }
  }

  reqResetKaabu(String numero) async {
    if (mounted) {
      setState(() {
        isLoadResetKaabu = true;
      });
    }

    try {
      setState(() {
        isLoadResetKaabu = true;
      });
      final url = Uri.parse(API.saveResetKaabu);
      final response = await http.post(
        url,
        body: {
          "idutilisateur": widget.utilisateur.idutilisateur.toString(),
          "tl_phone": widget.utilisateur.telephone,
          "numero": numero,
        },
      );

      if (response.statusCode == 200) {
        // Si le serveur renvoie un code 201 Created
        final data = response.body;

        if (data == "SUCCES") {
          await dbHelper.resetKaabuSent(numero);

          getNbResetKaabu();
        }

        if (mounted) {
          setState(() {
            isLoadResetKaabu = false;
          });
        }
      } else {
        {
          Get.snackbar(
            "INTERNET INACTIF",
            "Veuillez vous connecter à l'internet pour envoyer des données !",
            backgroundColor: redColor,
            icon: Icon(Icons.wifi_off, color: whiteColor),
            duration: Duration(seconds: 5),
            colorText: whiteColor,
          );

          if (mounted) {
            setState(() {
              isLoadResetKaabu = false;
            });
          }
        }
        if (mounted) {
          setState(() {
            isLoadResetKaabu = false;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        "INTERNET INACTIF",
        "Veuillez vous connecter à l'internet pour envoyer des données !",
        backgroundColor: redColor,
        icon: Icon(Icons.wifi_off, color: whiteColor),
        duration: Duration(seconds: 5),
        colorText: whiteColor,
      );
    }

    if (mounted) {
      setState(() {
        {
          isLoadResetKaabu = false;
        }
      });
    }
  }

  Future<void> uploadResetZebra() async {
    List<ResetZebra> resets = await dbHelper.getResetZebra();
    // parourir le tableau avec for

    for (var reset in resets) {
      reqResetZebra(reset.numero, reset.solde);
    }
  }

  reqResetZebra(String numero, String solde) async {
    if (mounted) {
      setState(() {
        isLoadResetZebra = true;
      });
    }

    try {
      setState(() {
        isLoadResetZebra = true;
      });
      final url = Uri.parse(API.saveResetZebra);
      final response = await http.post(
        url,
        body: {
          "idutilisateur": widget.utilisateur.idutilisateur.toString(),
          "tl_phone": widget.utilisateur.telephone,
          "numero": numero,
          "solde": solde,
        },
      );

      if (response.statusCode == 200) {
        // Si le serveur renvoie un code 201 Created
        final data = response.body;

        if (data == "SUCCES") {
          await dbHelper.resetZebra(numero);

          getNbResetZebra();
        }

        if (mounted) {
          setState(() {
            isLoadResetZebra = false;
          });
        }
      } else {
        {
          Get.snackbar(
            "INTERNET INACTIF",
            "Veuillez vous connecter à l'internet pour envoyer des données !",
            backgroundColor: redColor,
            icon: Icon(Icons.wifi_off, color: whiteColor),
            duration: Duration(seconds: 5),
            colorText: whiteColor,
          );

          if (mounted) {
            setState(() {
              isLoadResetZebra = false;
            });
          }
        }
        if (mounted) {
          setState(() {
            isLoadResetZebra = false;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        "INTERNET INACTIF",
        "Veuillez vous connecter à l'internet pour envoyer des données !",
        backgroundColor: redColor,
        icon: Icon(Icons.wifi_off, color: whiteColor),
        duration: Duration(seconds: 5),
        colorText: whiteColor,
      );
    }

    if (mounted) {
      setState(() {
        {
          isLoadResetZebra = false;
        }
      });
    }
  }

  // ---------------------------------RLMS

  Future<void> uploadRlms() async {
    List<RlmsClass> resets = await dbHelper.getRlms();
    // parourir le tableau avec for

    for (var reset in resets) {
      reqResetRlms(reset.numero);
    }
  }

  reqResetRlms(String numero) async {
    if (mounted) {
      setState(() {
        isLoadRlms = true;
      });
    }

    try {
      setState(() {
        isLoadRlms = true;
      });
      final url = Uri.parse(API.saveRlms);
      final response = await http.post(
        url,
        body: {
          "idutilisateur": widget.utilisateur.idutilisateur.toString(),
          "tl_phone": widget.utilisateur.telephone,
          "numero": numero,
        },
      );

      if (response.statusCode == 200) {
        // Si le serveur renvoie un code 201 Created
        final data = response.body;

        if (data == "SUCCES") {
          await dbHelper.resetRlmsSent(numero);

          getNbRlms();
        }

        if (mounted) {
          setState(() {
            isLoadRlms = false;
          });
        }
      } else {
        {
          Get.snackbar(
            "INTERNET INACTIF",
            "Veuillez vous connecter à l'internet pour envoyer des données !",
            backgroundColor: redColor,
            icon: Icon(Icons.wifi_off, color: whiteColor),
            duration: Duration(seconds: 5),
            colorText: whiteColor,
          );

          if (mounted) {
            setState(() {
              isLoadRlms = false;
            });
          }
        }
        if (mounted) {
          setState(() {
            isLoadRlms = false;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        "INTERNET INACTIF",
        "Veuillez vous connecter à l'internet pour envoyer des données !",
        backgroundColor: redColor,
        icon: Icon(Icons.wifi_off, color: whiteColor),
        duration: Duration(seconds: 5),
        colorText: whiteColor,
      );
    }

    if (mounted) {
      setState(() {
        {
          isLoadRlms = false;
        }
      });
    }
  }

  // ---------------------------------Zebra

  Future<void> uploadZebra() async {
    List<Zebra> resets = await dbHelper.getZebra();
    // parourir le tableau avec for

    for (var reset in resets) {
      reqZebra(
        reset.user_msisdn,
        reset.user_name,
        reset.geography,
        reset.category,
      );
    }
  }

  reqZebra(
    String user_msisdn,
    String user_name,
    String geography,
    String category,
  ) async {
    if (mounted) {
      setState(() {
        isLoadZebra = true;
      });
    }

    try {
      setState(() {
        isLoadZebra = true;
      });
      final url = Uri.parse(API.saveZebra);
      final response = await http.post(
        url,
        body: {
          "idutilisateur": widget.utilisateur.idutilisateur.toString(),
          "tl_phone": widget.utilisateur.telephone,
          "user_msisdn": user_msisdn,
          "user_name": user_name,
          "geography": geography,
          "category": category,
        },
      );

      if (response.statusCode == 200) {
        // Si le serveur renvoie un code 201 Created
        final data = response.body;

        if (data == "SUCCES") {
          await dbHelper.resetZebraSent(user_msisdn);

          getNbZebra();
        }

        if (mounted) {
          setState(() {
            isLoadZebra = false;
          });
        }
      } else {
        {
          Get.snackbar(
            "Erreur Réseau",
            "Veuillez vous connecter à l'internet pour envoyer des données !",
            backgroundColor: redColor,
            icon: Icon(Icons.wifi_off, color: whiteColor),
            duration: Duration(seconds: 5),
            colorText: whiteColor,
          );

          if (mounted) {
            setState(() {
              isLoadZebra = false;
            });
          }
        }
        if (mounted) {
          setState(() {
            isLoadZebra = false;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        "Erreur Reéseau",
        "",
        backgroundColor: redColor,
        icon: Icon(Icons.wifi_off, color: whiteColor),
        duration: Duration(seconds: 5),
        colorText: whiteColor,
      );
    }

    if (mounted) {
      setState(() {
        {
          isLoadZebra = false;
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
                              "Créations Kaabu",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // OM
                  Card(
                    color: primaryColor,
                    shadowColor: darcula,
                    elevation: 30,
                    child: InkWell(
                      onTap: () {
                        uploadZebra();
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
                                (isLoadZebra)
                                    ? const Circle()
                                    : Text(
                                        "$nbZebra Lignes",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 10),
                            child: const Text(
                              "Créations Zebra",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

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
                        uploadRlms();
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
                                (isLoadRlms)
                                    ? const Circle()
                                    : Text(
                                        "$nbRlms Lignes",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 10),
                            child: const Text(
                              "RLMS 395",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // OM
                  Card(
                    color: primaryColor,
                    shadowColor: darcula,
                    elevation: 30,
                    child: InkWell(
                      onTap: () {
                        uploadCicos();
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
                                (isLoadCico)
                                    ? const Circle()
                                    : Text(
                                        "$nbCicos Lignes",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 10),
                            child: const Text(
                              "CICOS Lite",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

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
                        uploadResetKaabu();
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
                                (isLoadResetKaabu)
                                    ? const Circle()
                                    : Text(
                                        "$nbResetKaabu Lignes",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 10),
                            child: const Text(
                              "Reset pin Kaabu",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Card(
                    color: primaryColor,
                    shadowColor: darcula,
                    elevation: 30,
                    child: InkWell(
                      onTap: () {
                        uploadResetZebra();
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
                                (isLoadResetZebra)
                                    ? const Circle()
                                    : Text(
                                        "$nbResetZebra Lignes",
                                        style: TextStyle(color: primaryColor),
                                      ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 10),
                            child: const Text(
                              "Reset pin Zebra",
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
