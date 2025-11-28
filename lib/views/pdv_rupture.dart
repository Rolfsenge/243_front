import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../class/utilisateur.dart';

import '../api_connection/api_connection.dart';
import '../authentication/login_screen.dart';
import '../bdd/dbhelper.dart';
import '../tools/color.dart';

class PdvRupture extends StatefulWidget {
  final Utilisateur utilisateur;
  final String siteName;
  const PdvRupture({
    super.key,
    required this.utilisateur,
    required this.siteName,
  });

  @override
  State<PdvRupture> createState() => _PdvRuptureState();
}

class _PdvRuptureState extends State<PdvRupture> {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  bool _isLoading = false;
  String searchText = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var response = await http.post(
        Uri.parse(API.getPdvRuptureSite),
        body: {
          "nomsecteur": widget.utilisateur.nomstructure,
          "site_name": widget.siteName,
        },
      );

      if (response.statusCode == 200) {
        var donnees = json.decode(response.body);
        setState(() {
          data = donnees["dataresult"];
          filteredData = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        print("Erreur: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Erreur lors de la récupération : $e");
    }
  }

  // 🔹 Recherche
  void filterData(String query) {
    searchText = query;
    applyFilter();
  }

  // 🔹 Application des filtres
  void applyFilter() {
    List<dynamic> temp = data;

    // Filtre texte
    if (searchText.isNotEmpty) {
      temp = temp.where((item) {
        final siteName = item['site_name'].toString().toLowerCase();
        final categorie = item['categorie_pdv'].toString().toLowerCase();
        return siteName.contains(searchText.toLowerCase()) ||
            categorie.contains(searchText.toLowerCase());
      }).toList();
    }

    // Filtre avancé

    setState(() {
      filteredData = temp;
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
        displacement: 50,
        edgeOffset: 50,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: blackColor),
                      child: Text(
                        "PDV Site : ${widget.siteName}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: whiteColor),
                      ),
                    ),

                    const SizedBox(height: 8),
                    // 🔹 Champ recherche
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Rechercher",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) => filterData(value),
                      ),
                    ),

                    // 🔹 Liste des PDV
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final item = filteredData[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.store,
                                color: primaryColor,
                              ),
                              title: Text(
                                "${item['site_name']} - ${item['categorie_pdv']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Numéro: ${item['num_zebra']}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    "Moy Jour : ${item['moy_jour']}",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  Text(
                                    "Balance : ${item['balance']}",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              trailing: TextButton.icon(
                                onPressed: () {
                                  // Action spécifique
                                  showActivityForm(context, item);
                                },
                                icon: const Icon(
                                  Icons.open_in_browser,
                                  size: 20,
                                ),
                                label: const Text(
                                  "Action",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
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

  void showActivityForm(BuildContext context, dynamic pdvItem) {
    final TextEditingController commentController = TextEditingController();
    String? selectedActivity;
    TimeOfDay? selectedTime;
    bool isSubmitting = false;

    // Liste des activités possibles
    final List<String> activities = [
      "Approvisionner le PDV",
      "Recommander un Grossiste ou un Fournisseur",
      "Autre",
    ];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "Soumettre activité - ${pdvItem['site_name']}",
              style: TextStyle(fontSize: 11),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown pour l'activité
                DropdownButtonFormField<String>(
                  initialValue: selectedActivity,
                  hint: const Text(
                    "Sélectionnez une activité",
                    style: TextStyle(fontSize: 12),
                  ),
                  items: activities
                      .map(
                        (act) => DropdownMenuItem(
                          value: act,
                          child: Text(act, style: TextStyle(fontSize: 10)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedActivity = val),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Sélecteur d'heure
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedTime != null
                            ? "Heure: ${selectedTime!.format(context)}"
                            : "Sélectionnez l'heure",
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) setState(() => selectedTime = time);
                      },
                      child: const Text("Choisir"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Champ commentaire
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Commentaire",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  "ANNULER",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (selectedActivity == null) {
                          Get.snackbar(
                            "Erreur",
                            "Veuillez sélectionner une activité",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        if (selectedTime == null) {
                          Get.snackbar(
                            "Erreur",
                            "Veuillez sélectionner l'heure",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        if (commentController.text.trim().isEmpty) {
                          Get.snackbar(
                            "Erreur",
                            "Veuillez saisir un commentaire",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        setState(() => isSubmitting = true);

                        try {
                          var response = await http.post(
                            Uri.parse(API.submitActivity),
                            body: {
                              "site_name": pdvItem['site_name'],
                              "num_zebra": pdvItem['num_zebra'].toString(),
                              "activity": selectedActivity!,
                              "time":
                                  "${selectedTime!.hour}:${selectedTime!.minute}",
                              "comment": commentController.text.trim(),
                              "idstructure": widget.utilisateur.idstructure
                                  .toString(),
                              "idutilisateur": widget.utilisateur.idutilisateur
                                  .toString(),
                              "idtypestructure": widget
                                  .utilisateur
                                  .idtypestructure
                                  .toString(),
                            },
                          );

                          if (response.statusCode == 200) {
                            Get.back(); // fermer le popup
                            Get.snackbar(
                              "Succès",
                              "Activité soumise avec succès",
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } else {
                            setState(() => isSubmitting = false);
                            Get.snackbar(
                              "Erreur",
                              "Impossible de soumettre l'activité",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        } catch (e) {
                          setState(() => isSubmitting = false);
                          Get.snackbar(
                            "Erreur",
                            "Erreur réseau : $e",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        "SOUMETTRE",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }
}
