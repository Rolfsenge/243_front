import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../tools/color.dart';
import 'pdv_detail_site.dart';
import 'rupture_chart_sites_secteur.dart';

class PdvDetailSecteur extends StatefulWidget {
  final Color color;
  final String statut_pdv;
  final String secteur;

  const PdvDetailSecteur({
    super.key,
    required this.secteur,
    required this.color,
    required this.statut_pdv,
  });

  @override
  State<PdvDetailSecteur> createState() => _PdvDetailSecteurState();
}

class _PdvDetailSecteurState extends State<PdvDetailSecteur> {
  bool loading = true;
  List<dynamic> secteurs = [];

  @override
  void initState() {
    super.initState();
    fetchSecteur();
  }

  Future<void> fetchSecteur() async {
    try {
      final url = Uri.parse(API.getPerformanceSiteSecteur);
      final response = await http.post(
        url,
        body: {"statut_pdv": widget.statut_pdv, "secteur": widget.secteur},
      );

      if (response.statusCode == 200) {
        setState(() {
          secteurs = jsonDecode(response.body);
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
      appBar: AppBar(
        backgroundColor: widget.color,
        foregroundColor: whiteColor,
        centerTitle: true,
        title: Text(
          "SECTEUR : ${widget.secteur}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),

      body: loading
          ? Center(child: CircularProgressIndicator(color: widget.color))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: secteurs.length,
              itemBuilder: (context, index) {
                final secteur = secteurs[index];
                final taux = secteur['taux']?.toDouble() ?? 0.0;
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
                      secteur['site_name'] ?? 'Inconnu',
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
                              "PDV ${widget.statut_pdv}: ${secteur['nombre']}",
                            ),
                            Text("Total: ${secteur['total']}"),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Taux: ${taux.toStringAsFixed(2)}%",
                              style: TextStyle(
                                color: widget.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Site Key: ${secteur['site_key']}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: widget.color,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdvDetailSite(
                            site_name: secteur['site_name'],
                            color: widget.color,
                            statut_pdv: widget.statut_pdv,
                            tl_phone: '',
                            retailer_name: '',
                          ),
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
