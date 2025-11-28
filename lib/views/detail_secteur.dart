import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/views/revenusite.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';

class DetailSecteur extends StatefulWidget {
  final String secteur;
  final Map<String, dynamic> data;
  final Color color;
  final Utilisateur utilisateur;
  final String groupe_m_usd;
  const DetailSecteur({
    super.key,
    required this.secteur,
    required this.data,
    required this.color,
    required this.utilisateur,
    required this.groupe_m_usd,
  });

  @override
  State<DetailSecteur> createState() => _DetailSecteurState();
}

class _DetailSecteurState extends State<DetailSecteur> {
  bool loading = true;
  List<dynamic> zones = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // print("groupe_m_usd : ${widget.groupe_m_usd}, secteur : ${widget.secteur}");

    try {
      final url = Uri.parse(API.getRevenuSiteSecteur);
      final response = await http.post(
        url,
        body: {"groupe_m_usd": widget.groupe_m_usd, "secteur": widget.secteur},
      );

      if (response.statusCode == 200) {
        setState(() {
          zones = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors du chargement des zones.")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur réseau : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text("Secteur : ${widget.secteur}"),
        backgroundColor: widget.color,
        foregroundColor: whiteColor,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: zones.length,
              itemBuilder: (context, index) {
                final zone = zones[index];
                final taux = zone['taux']?.toDouble() ?? 0.0;
                final tauxColor = taux >= 40
                    ? Colors.green
                    : taux >= 20
                    ? Colors.orange
                    : Colors.red;

                return Card(
                  elevation: 20,
                  color: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      zone['site_name'] ?? 'Zone inconnue',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Site Key : ${zone['site_key']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Techno : ${zone['techno']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Partenaire : ${zone['partenaire']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Type de Transmission : ${zone['type_transmission']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: widget.color,
                    ),
                    onTap: () {
                      Get.to(
                        () => RevenusiteUnique(
                          site: zone,
                          color: widget.color,
                          utilisateur: widget.utilisateur,
                          groupe_m_usd: widget.groupe_m_usd,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
