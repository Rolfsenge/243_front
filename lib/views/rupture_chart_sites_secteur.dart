/*

import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../authentication/login_screen.dart';
import '../bdd/dbhelper.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';

class RuptureChartSitesSecteur extends StatefulWidget {
  final Utilisateur utilisateur;
  const RuptureChartSitesSecteur({super.key, required this.utilisateur});

  @override
  State<RuptureChartSitesSecteur> createState() =>
      _RuptureChartSitesSecteurState();
}

class _RuptureChartSitesSecteurState extends State<RuptureChartSitesSecteur> {
  bool loading = true;
  List<Map<String, dynamic>> siteData = [];
  DatabaseHelper helper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final res = await http.post(
        Uri.parse(API.getGraphSiteBySecteur),
        body: {'idsecteur': widget.utilisateur.idstructure.toString()},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<Map<String, dynamic>> temp = [];
        for (var site in data) {
          final total = site["total"] ?? 0;
          final rupture = site["rupture"] ?? 0;
          final pourcentage = total == 0 ? 0 : (rupture / total) * 100;
          temp.add({"site": site["site"], "pourcentage": pourcentage});
        }
        setState(() {
          siteData = temp;
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
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
            onPressed: () {
              signOutUser();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        color: primaryColor,
        backgroundColor: whiteColor,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal, // ✅ scroll horizontal
                child: SizedBox(
                  width: siteData.length * 80, // largeur dynamique
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: blackColor),
                        child: const Text(
                          "Points de vente en rupture par site",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: whiteColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 300,
                            child: PieChart(
                              PieChartData(
                                sections: siteData.map((site) {
                                  return PieChartSectionData(
                                    title:
                                        '${site["site"]}\n${site["pourcentage"].toStringAsFixed(1)}%',
                                    value: site["pourcentage"],
                                    color: site["pourcentage"] > 50
                                        ? Colors.red
                                        : Colors.green,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
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

  // 🔹 Gestion de déconnexion
  signOutUser() async {
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
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '/views/pdv_rupture.dart';

import '../api_connection/api_connection.dart';
import '../authentication/login_screen.dart';
import '../bdd/dbhelper.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';

class RuptureListSitesSecteur extends StatefulWidget {
  final Utilisateur utilisateur;
  const RuptureListSitesSecteur({super.key, required this.utilisateur});

  @override
  State<RuptureListSitesSecteur> createState() =>
      _RuptureListSitesSecteurState();
}

class _RuptureListSitesSecteurState extends State<RuptureListSitesSecteur> {
  bool loading = true;
  List<Map<String, dynamic>> siteData = [];
  List<Map<String, dynamic>> filteredData = [];
  String selectedFilter = "Tous"; // 🔹 Filtre sélectionné
  String searchText = ""; // 🔹 Texte recherché
  DatabaseHelper helper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final res = await http.post(
        Uri.parse(API.getGraphSiteBySecteur),
        body: {'idsecteur': widget.utilisateur.idstructure.toString()},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<Map<String, dynamic>> temp = [];
        for (var site in data) {
          final total = site["total"] ?? 0;
          final rupture = site["rupture"] ?? 0;
          final pourcentage = total == 0 ? 0 : (rupture / total) * 100;
          temp.add({
            "site": site["site"],
            "pourcentage": pourcentage,
            "total": total,
            "rupture": rupture,
          });
        }
        setState(() {
          siteData = temp;
          applyFilter(selectedFilter); // Applique le filtre et recherche
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      filteredData = siteData.where((site) {
        // 🔹 Filtre par dropdown
        bool filterMatch = true;
        final pourcentage = site["pourcentage"] ?? 0.0;
        if (filter == "Rupture > 50%") filterMatch = pourcentage > 50;
        if (filter == "Rupture <= 50%") filterMatch = pourcentage <= 50;

        // 🔹 Filtre par recherche
        bool searchMatch = site["site"].toString().toLowerCase().contains(
          searchText.toLowerCase(),
        );

        return filterMatch && searchMatch;
      }).toList();
    });
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

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              color: primaryColor,
              backgroundColor: whiteColor,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: blackColor),
                    child: const Text(
                      "Points de vente en rupture par site",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: whiteColor),
                    ),
                  ),

                  // 🔹 Barre de recherche
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Rechercher un point de vente...",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        searchText = value;
                        applyFilter(selectedFilter);
                      },
                    ),
                  ),

                  // 🔹 Dropdown Filtre
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: "Tous",
                          child: Text("Tous les sites"),
                        ),
                        DropdownMenuItem(
                          value: "Rupture > 50%",
                          child: Text("Sites en forte rupture (>50%)"),
                        ),
                        DropdownMenuItem(
                          value: "Rupture <= 50%",
                          child: Text("Sites en faible rupture (≤50%)"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) applyFilter(value);
                      },
                    ),
                  ),
                  const Divider(),
                  // 🔹 Liste avec jauges
                  Expanded(
                    child: filteredData.isEmpty
                        ? const Center(child: Text("Aucun site trouvé."))
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final site = filteredData[index];
                              final pourcentage =
                                  double.tryParse(
                                    site["pourcentage"].toString(),
                                  ) ??
                                  0;

                              return Card(
                                color: whiteColor,
                                elevation: 10,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 12,
                                ),
                                child: ListTile(
                                  title: Text(
                                    site["site"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rupture : ${site["rupture"]}/${site["total"]} soit ${pourcentage.toStringAsFixed(1)}%",
                                        style: TextStyle(color: blackColor),
                                      ),
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: pourcentage / 100,
                                        backgroundColor: Colors.grey[300],
                                        color: pourcentage > 50
                                            ? primaryColor
                                            : Colors.green,
                                        minHeight: 8,
                                      ),
                                    ],
                                  ),

                                  trailing: IconButton(
                                    onPressed: () {
                                      Get.to(
                                        () => PdvRupture(
                                          utilisateur: widget.utilisateur,
                                          siteName: site["site"],
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
            ),
    );
  }

  // 🔹 Gestion de déconnexion
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
