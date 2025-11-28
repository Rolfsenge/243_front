import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/views/detail_secteur.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';

class DetailZonePage extends StatefulWidget {
  final String zone;
  final Map<String, dynamic> data;
  final Color color;
  final Utilisateur utilisateur;
  final String groupe_m_usd;

  const DetailZonePage({
    super.key,
    required this.zone,
    required this.data,
    required this.color,
    required this.utilisateur,
    required this.groupe_m_usd,
  });

  @override
  State<DetailZonePage> createState() => _DetailZonePageState();
}

class _DetailZonePageState extends State<DetailZonePage> {
  bool loading = true;
  List<dynamic> zones = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final url = Uri.parse(API.getRevenuSiteZone);
      final response = await http.post(
        url,
        body: {"groupe_m_usd": widget.groupe_m_usd, "zone": widget.zone},
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
        title: Text("Zone : ${widget.zone}"),
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
                      zone['secteur'] ?? 'Zone inconnue',
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
                              "Sites ${widget.groupe_m_usd}s : ${zone['nombre']}",
                            ),
                            Text("Total : ${zone['total']}"),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Taux : ${taux.toStringAsFixed(2)}%",
                              style: TextStyle(
                                color: widget.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Get.to(
                        () => DetailSecteur(
                          secteur: zone['secteur'],
                          data: zone,
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
