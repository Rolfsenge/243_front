import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtm/views/dcm_performamnce.dart';
import 'cico_lite.dart';
import 'creation_page.dart';
import 'creation_page_dso.dart';
import 'home_dcm_data.dart';
import '/menus/menu_all.dart';
import 'home_dcm.dart';
import 'home_orange.dart';
import 'home_rzm.dart';
import 'home_tl.dart';
import '../class/utilisateur.dart';
import '/bdd/dbhelper.dart';
import '/tools/color.dart';
import '../../authentication/login_screen.dart';
import 'home_region.dart';
import 'reset_kabu_page.dart';
import 'reset_zebra_page.dart';
import 'rlms_remote.dart';
import 'send_dcmdata.dart';
import 'televerser.dart';
import 'zebra_page.dart';

class WalletScreen extends StatefulWidget {
  final Utilisateur utilisateur;
  const WalletScreen({super.key, required this.utilisateur});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  DatabaseHelper helper = DatabaseHelper.instance;

  var formKey = GlobalKey<FormState>();
  var montantController = TextEditingController();
  String? devise;

  late final bool _isLoading = false;

  // 🔹 Map qui associe les types de structure aux widgets correspondants
  final Map<String, Widget Function(Utilisateur)> _homeWidgets = {
    "orange": (u) => HomeOrange(utilisateur: u),
    "region": (u) => HomeRegion(utilisateur: u),
    "zone": (u) {
      if (u.idcategorie == 4) {
        return HomeRzm(utilisateur: u);
      } else {
        return HomeDcmData(utilisateur: u);
      }
    },
    "secteur": (u) => HomeDcm(utilisateur: u),
    "site": (u) => HomeTl(utilisateur: u),
  };

  @override
  Widget build(BuildContext context) {
    String idcategorie = widget.utilisateur.idcategorie.toString();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Bienvenue", style: TextStyle(color: whiteColor)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: whiteColor),
            onPressed: () => signOutUser(),
          ),
          // 🔹 Menu principal
          MenuAll(utilisateur: widget.utilisateur),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          _buildHomeWidget();
        },
        color: primaryColor,
        backgroundColor: whiteColor,
        displacement: 50,
        edgeOffset: 50,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 En-tête utilisateur
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: blackColor),
                child: Text(
                  "${widget.utilisateur.nomutilisateur} - "
                  "${widget.utilisateur.nomcategorie} "
                  "(${widget.utilisateur.nomstructure})",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: whiteColor, fontSize: 12),
                ),
              ),
              // 🔹 Widget dynamique selon la structure
              _buildHomeWidget(),
            ],
          ),
        ),
      ),

      // 🔹 Bouton flottant conditionnel
      floatingActionButton: idcategorie == "6"
          ? FloatingActionButton.extended(
              backgroundColor: primaryColor,
              icon: const Icon(Icons.menu, color: whiteColor),
              label: const Text(
                "SD FOCUS",
                style: TextStyle(color: whiteColor),
              ),
              onPressed: () {
                // Affiche le menu de la page mère
                showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(
                    200,
                    600,
                    16,
                    0,
                  ), // Position du menu
                  items: const [
                    PopupMenuItem<String>(
                      value: 'plus',
                      child: Row(
                        children: const [
                          Icon(Icons.add_circle_outline, color: primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'SD FOCUS - CREATIONS',
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(thickness: 2, color: primaryColor),

                    PopupMenuItem<String>(
                      value: 'creation',
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Kaabu'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'zebra',
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Zebra'),
                        ],
                      ),
                    ),

                    PopupMenuItem<String>(
                      value: 'resetzebra',
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Reset pin Zebra'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'resetkaabu',
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Reset pin Kaabu'),
                        ],
                      ),
                    ),

                    PopupMenuItem<String>(
                      value: 'rlms',
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('RLMS 395'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'cico',
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('CICO Lite'),
                        ],
                      ),
                    ),

                    PopupMenuItem<String>(
                      value: 'televerser',
                      child: Row(
                        children: const [
                          Icon(Icons.cloud_upload),
                          SizedBox(width: 8),
                          Text('Envoyer les données'),
                        ],
                      ),
                    ),
                  ],
                ).then((value) {
                  if (value != null) {
                    /*
            PopupMenuItem<String>(if (value == 'cico') {
         
        } else if (value == 'telecharger') {
          
        } else if (value == '') {
        
        }
         */

                    switch (value) {
                      case 'resetkaabu':
                        Get.to(
                          () => ResetKabuPage(utilisateur: widget.utilisateur),
                        );
                        break;
                      case 'resetzebra':
                        Get.to(
                          () => ResetZebraPage(utilisateur: widget.utilisateur),
                        );
                        break;
                      case 'zebra':
                        Get.to(
                          () => ZebraPage(utilisateur: widget.utilisateur),
                        );
                        break;
                      case 'creation_dso':
                        Get.to(
                          () =>
                              CreationPageDso(utilisateur: widget.utilisateur),
                        );
                        break;
                      case 'creation':
                        Get.to(
                          () => CreationPage(utilisateur: widget.utilisateur),
                        );
                        break;
                      case 'rlms':
                        Get.to(
                          () => RlmsRemote(utilisateur: widget.utilisateur),
                        );
                        break;
                      case 'send_dcm_data':
                        Get.to(
                          () => SendDcmdata(utilisateur: widget.utilisateur),
                        );
                        break;
                      case 'televerser':
                        Get.to(
                          () => Televerser(utilisateur: widget.utilisateur),
                        );
                        break;
                      case 'cico':
                        Get.to(() => CicoLite(utilisateur: widget.utilisateur));
                        break;
                    }
                  }
                });
              },
            )
          : idcategorie == "10" || idcategorie == "5"
          ? FloatingActionButton.extended(
              backgroundColor: primaryColor,
              icon: const Icon(Icons.menu, color: whiteColor),
              label: const Text(
                "SD FOCUS",
                style: TextStyle(color: whiteColor),
              ),
              onPressed: () {
                // Affiche le menu de la page mère
                showMenu<String>(
                  context: context,
                  position: const RelativeRect.fromLTRB(
                    200,
                    600,
                    16,
                    0,
                  ), // Position du menu
                  items: const [
                    PopupMenuItem<String>(
                      value: 'plus',
                      child: Row(
                        children: const [
                          Icon(Icons.add_circle_outline, color: primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'SD FOCUS',
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(thickness: 2, color: primaryColor),

                    PopupMenuItem<String>(
                      value: 'creation_dso',
                      child: Row(
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('Création FDV'),
                        ],
                      ),
                    ),

                    PopupMenuItem<String>(
                      value: 'perofmance',
                      child: Row(
                        children: [
                          Icon(Icons.pie_chart),
                          SizedBox(width: 8),
                          Text('Votre performance'),
                        ],
                      ),
                    ),
                  ],
                ).then((value) {
                  if (value != null) {
                    switch (value) {
                      case 'creation_dso':
                        Get.to(
                          () =>
                              CreationPageDso(utilisateur: widget.utilisateur),
                        );
                        break;

                      case 'perofmance':
                        Get.to(
                          () =>
                              DcmPerformamnce(utilisateur: widget.utilisateur),
                        );
                        break;
                    }
                  }
                });
              },
            )
          : null,
    );
  }

  // 🔹 Déconnexion
  Future<void> signOutUser() async {
    var resultResponse = await Get.dialog(
      AlertDialog(
        backgroundColor: const Color.fromARGB(255, 5, 4, 4),
        title: const Text(
          "Déconnexion",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: const Text(
          "Êtes-vous sûr ?\nVoulez-vous quitter l'application ?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "NON",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: "loggedOut"),
            child: const Text(
              "OUI",
              style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (resultResponse == "loggedOut") {
      await helper.disconnectAll();
      Get.off(LoginScreen());
    }
  }

  // 🔹 Chargement du widget selon la structure
  Widget _buildHomeWidget() {
    final builder = _homeWidgets[widget.utilisateur.nomtypestructure];
    return builder != null
        ? builder(widget.utilisateur)
        : const Text("Structure non reconnue");
  }
}
