import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gtm/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;

import 'package:gtm/class/utilisateur.dart';
import 'package:gtm/tools/color.dart';

class DetailKaabu extends StatefulWidget {
  final Utilisateur utilisateur;
  final String is_exported;
  final String libelle;
  final String category;
  final int cumul;

  const DetailKaabu({
    super.key,
    required this.utilisateur,
    required this.is_exported,
    required this.libelle,
    required this.cumul,
    required this.category,
  });

  @override
  State<DetailKaabu> createState() => _DetailKaabuState();
}

class _DetailKaabuState extends State<DetailKaabu> {
  List<dynamic> data = [];
  List<dynamic> filtered = [];

  bool isLoading = true;
  bool hasError = false;

  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // ----------------------------------------------------------
  // 🔥 FETCH VIA HTTP
  // ----------------------------------------------------------
  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse(API.getKaabuStatut),
        body: {
          "infra_category": widget.category,
          "is_exported": widget.is_exported,
          "tl_phone": widget.utilisateur.telephone,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["success"] == true) {
          setState(() {
            data = json["kaabu"];
            filtered = data;
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() => hasError = true);
        }
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    }
  }

  // ----------------------------------------------------------
  // 🔍 SEARCH FILTER
  // ----------------------------------------------------------
  void filterList(String text) {
    text = text.toLowerCase();

    setState(() {
      filtered = data.where((item) {
        final nom = item["nom"].toString().toLowerCase();
        final postnom = item["postnom"].toString().toLowerCase();
        final prenom = item["prenom"].toString().toLowerCase();
        final phone = item["infra_phone"].toString().toLowerCase();

        return nom.contains(text) ||
            postnom.contains(text) ||
            prenom.contains(text) ||
            phone.contains(text);
      }).toList();
    });
  }

  // ----------------------------------------------------------
  // 🔥 UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kaabu - ${widget.libelle} (${widget.cumul})"),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(
              child: Text(
                "Erreur de chargement des données",
                style: TextStyle(color: Colors.red),
              ),
            )
          : Column(
              children: [
                // 🔍 SEARCH BAR
                Container(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: filterList,
                    decoration: InputDecoration(
                      hintText: "Rechercher un numéro ou nom...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),

                // -------------------------------------------------------
                // 🔄 PULL-TO-REFRESH WRAPPER
                // -------------------------------------------------------
                Expanded(
                  child: RefreshIndicator.adaptive(
                    displacement: 25,
                    backgroundColor: whiteColor,
                    color: primaryColor,
                    strokeWidth: 3,
                    edgeOffset: 5,
                    onRefresh: () async {
                      await fetchData();
                    },

                    // LISTE RÉELLE
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];

                        return Card(
                          elevation: 12,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Text(
                                item["prenom"][0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),

                            title: Text(
                              "${item["nom"].toUpperCase()} ${item["postnom"].toUpperCase()}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Prénom : ${item["prenom"]}"),
                                Text("Téléphone : ${item["infra_phone"]}"),
                                Text("Login : ${item["login_infra"]}"),
                                Text("Date : ${item["created_at"]}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
