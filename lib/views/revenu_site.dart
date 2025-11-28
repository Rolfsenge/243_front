import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '/class/utilisateur.dart';
import '/views/detail_site.dart';

import '../api_connection/api_connection.dart';
import '../authentication/login_screen.dart';
import '../bdd/dbhelper.dart';
import '../tools/color.dart';

class RevenuSite extends StatefulWidget {
  final Utilisateur utilisateur;
  const RevenuSite({super.key, required this.utilisateur});

  @override
  State<RevenuSite> createState() => _RevenuSiteState();
}

class _RevenuSiteState extends State<RevenuSite> {
  List<Map<String, dynamic>> siteData = [];
  bool loading = true;
  String filter = "";
  DatabaseHelper helper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
    });

    try {
      // Mets ton vrai endpoint ici
      final res = await http.post(
        Uri.parse(API.getRevenuSiteBySecteur),
        body: {'idsecteur': widget.utilisateur.idstructure.toString()},
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        List<Map<String, dynamic>> temp = [];

        for (var site in data) {
          final total = 2000; // Valeur fixe pour le total des appels
          final valeur = int.tryParse(site["first_call_quali"].toString()) ?? 0;

          /*
          "site_name": "KAKONGO SONGO",
        "site_key": "27525_Tigo",
        "first_call_quali": "43",
        "first_call": "55",
        "parc_cico_30d": "30",
        "parc_rlms_30d": "2",
        "parc_sa_30d": "1",
        "parc_sso_30d": "2",
        "parc_zebra_30d": "2",
        "type": "Macro",
        "partenaire": "Helios",
        "techno": "2G_3G_FDD"
          */
          temp.add({
            "site_name": site["site_name"] ?? "",
            "site_key": site["site_key"] ?? "",
            "first_call": site["first_call"] ?? "0",
            "parc_cico_30d": site["parc_cico_30d"] ?? "0",
            "parc_rlms_30d": site["parc_rlms_30d"] ?? "0",
            "parc_sa_30d": site["parc_sa_30d"] ?? "0",
            "parc_sso_30d": site["parc_sso_30d"] ?? "0",
            "parc_zebra_30d": site["parc_zebra_30d"] ?? "0",
            "type": site["type"] ?? "",
            "partenaire": site["partenaire"] ?? "",
            "techno": site["techno"] ?? "",
            "first_call_quali": valeur,
            "total": 2000,
            "pourcentage": total == 0 ? 0 : (valeur / total) * 100,
          });
        }

        setState(() {
          siteData = temp;
          loading = false;
        });

        print("Sites chargés : ${siteData.length}");
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Erreur: $e");
      setState(() {
        loading = false;
      });
    }
  }

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
            child: const Text(
              "SITES NON RENTABLES",
              textAlign: TextAlign.center,
              style: TextStyle(color: whiteColor),
            ),
          ),
          // Champ filtre
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Rechercher un site...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  filter = val;
                });
              },
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : siteData.isEmpty
                ? const Center(child: Text("Aucun site trouvé."))
                : ListView.builder(
                    itemCount: siteData.length,
                    itemBuilder: (context, index) {
                      final site = siteData[index];
                      final percent = site["pourcentage"].toDouble();

                      return Card(
                        color: whiteColor,
                        elevation: 16,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            site["site_name"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Site Key : ${site["site_key"]}",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: blackColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percent / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                color: percent > 70
                                    ? Colors.green
                                    : (percent > 40
                                          ? Colors.orange
                                          : Colors.red),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${site["first_call_quali"]} sur ${site["total"]} soit ${percent.toStringAsFixed(1)} % First Call Qualité",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: blackColor,
                                ),
                              ),
                            ],
                          ),

                          trailing: IconButton(
                            onPressed: () {
                              Get.to(
                                () => DetailSite(
                                  utilisateur: widget.utilisateur,
                                  siteData: site,
                                ),
                              );
                            },
                            icon: Icon(Icons.open_in_full),
                          ),
                        ),
                      );
                    },
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
