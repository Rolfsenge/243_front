import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../authentication/login_screen.dart';
import '../bdd/dbhelper.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';

class DetailSite extends StatefulWidget {
  final Utilisateur utilisateur;
  final Map<String, dynamic> siteData;
  const DetailSite({
    super.key,
    required this.utilisateur,
    required this.siteData,
  });

  @override
  State<DetailSite> createState() => _DetailSiteState();
}

class _DetailSiteState extends State<DetailSite> {
  DatabaseHelper helper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.utilisateur.nomstructure,
          style: const TextStyle(color: whiteColor),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {},
            label: const Text("Action"),
            icon: const Icon(Icons.add, color: whiteColor),
            style: TextButton.styleFrom(
              foregroundColor: whiteColor,
              backgroundColor: blackColor, // Background Color
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: whiteColor),
            onPressed: () => signOutUser(),
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: blackColor),
            child: Text(
              "${widget.siteData["site_name"]} (${widget.siteData["site_key"]})",
              textAlign: TextAlign.center,
              style: const TextStyle(color: whiteColor),
            ),
          ),

          // Add more details about the site here
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
                "Détails du site",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  title: const Text(
                    "Nom du site",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(widget.siteData["site_name"] ?? "N/A"),
                ),
                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Clé du site",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(widget.siteData["site_key"] ?? "N/A"),
                ),
                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Type de site",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(widget.siteData["type"] ?? "N/A"),
                ),
                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Partenaire",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(widget.siteData["partenaire"] ?? "N/A"),
                ),
                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "First Call Qualité",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    widget.siteData["first_call_quali"]?.toString() ?? "N/A",
                  ),
                ),
                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "First Call",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    widget.siteData["first_call"]?.toString() ?? "N/A",
                  ),
                ),
                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Seuil Qualité",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(widget.siteData["total"]?.toString() ?? "N/A"),
                ),
                const Divider(),

                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Parc CICO 30 jours",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    widget.siteData["parc_cico_30d"]?.toString() ?? "N/A",
                  ),
                ),

                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Parc RLMS 30 jours",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    widget.siteData["parc_rlms_30d"]?.toString() ?? "N/A",
                  ),
                ),

                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Parc SA 30 jours",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    widget.siteData["parc_sa_30d"]?.toString() ?? "N/A",
                  ),
                ),

                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Parc SSO 30 jours",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    widget.siteData["parc_sso_30d"]?.toString() ?? "N/A",
                  ),
                ),

                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Parc Zebra 30 jours",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    widget.siteData["parc_zebra_30d"]?.toString() ?? "N/A",
                  ),
                ),

                ListTile(
                  dense: true, // réduit la hauteur
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                  title: const Text(
                    "Pourcentage",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    "${widget.siteData["pourcentage"]?.toStringAsFixed(2) ?? "N/A"}%",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> signOutUser() async {
    var resultResponse = await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black87,
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
      Get.off(() => LoginScreen());
    }
  }
}
