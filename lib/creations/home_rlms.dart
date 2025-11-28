import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';
import 'detail_rlms.dart';

class HomeRlms extends StatefulWidget {
  final Utilisateur utilisateur;
  const HomeRlms({super.key, required this.utilisateur});

  @override
  State<HomeRlms> createState() => _HomeRlmsState();
}

class _HomeRlmsState extends State<HomeRlms> {
  bool isLoading = true;
  bool hasError = false;
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // ---------------------------------------------------------
  // 🔥 RÉCUPÉRATION DES DONNÉES VIA HTTP
  // ---------------------------------------------------------
  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse(API.getHomeRlms),
        body: {"telephone": widget.utilisateur.telephone},
      );

      // print("Réponse brute = ${response.body}");

      if (response.statusCode == 200) {
        final map = jsonDecode(response.body);

        if (map["success"] == true) {
          setState(() {
            data = map["rlms"];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
          });
        }
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      print("Erreur : $e");
      setState(() => hasError = true);
    }
  }

  // ---------------------------------------------------------
  // 🔥 UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cumul RLMS"),
        foregroundColor: whiteColor,
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(
              child: Text(
                "Erreur de chargement des données",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : buildDashboard(),
    );
  }

  // ---------------------------------------------------------
  // 🔥 DASHBOARD WIDGET
  // ---------------------------------------------------------
  Widget buildDashboard() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // HEADER
                Text(
                  item["infra_category"],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(),

                const SizedBox(height: 10),

                // BADGES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    badge("Attente", item["attente"], Colors.orange, () {
                      Get.to(
                        () => DetailRlms(
                          utilisateur: widget.utilisateur,
                          is_exported: "0",
                          libelle: 'En Attente',
                          cumul: item["attente"],
                        ),
                      );
                    }),
                    badge("En cours", item["encours"], Colors.blue, () {
                      Get.to(
                        () => DetailRlms(
                          utilisateur: widget.utilisateur,
                          is_exported: "1",
                          libelle: 'En cours',
                          cumul: item["encours"],
                        ),
                      );
                    }),
                    badge("Créés", item["cree"], Colors.green, () {
                      Get.to(
                        () => DetailRlms(
                          utilisateur: widget.utilisateur,
                          is_exported: "2",
                          libelle: 'Créés',
                          cumul: item["cree"],
                        ),
                      );
                    }),
                    badge("Rejetés", item["rejete"], Colors.red, () {
                      Get.to(
                        () => DetailRlms(
                          utilisateur: widget.utilisateur,
                          is_exported: "3",
                          libelle: 'Rejetés',
                          cumul: item["rejete"],
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 12),

                // TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Total : ${item["total"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // 🔥 BADGE WIDGET
  // ---------------------------------------------------------
  Widget badge(String title, int value, Color color, onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "$value",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
