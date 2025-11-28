import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';

class DetailRlms extends StatefulWidget {
  final Utilisateur utilisateur;
  final String is_exported;
  final String libelle;
  final int cumul;
  const DetailRlms({
    super.key,
    required this.utilisateur,
    required this.is_exported,
    required this.libelle,
    required this.cumul,
  });

  @override
  State<DetailRlms> createState() => _DetailRlmsState();
}

class _DetailRlmsState extends State<DetailRlms> {
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
        Uri.parse(API.getRlmsStatut),
        body: {
          "is_exported": widget.is_exported,
          "tl_phone": widget.utilisateur.telephone,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["success"] == true) {
          setState(() {
            data = json["rlms"];
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
        final phone = item["infra_phone"].toString().toLowerCase();

        return phone.contains(text);
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
        title: Text("RLMS - ${widget.libelle} (${widget.cumul})"),
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
                      hintText: "Rechercher un numéro...",
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
                            title: Text(
                              "${item["infra_phone"]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Region : ${item["region"]}",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "Date : ${item["created_at"]}",
                                  style: TextStyle(fontSize: 12),
                                ),
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
