import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../tools/color.dart';
import 'pdv_detail_secteur.dart';

class ZoneDetailPdv extends StatefulWidget {
  final Map<String, dynamic> data;
  final Color color;
  final String statut_pdv;

  const ZoneDetailPdv({
    super.key,
    required this.data,
    required this.statut_pdv,
    required this.color,
    required String region,
  });

  @override
  State<ZoneDetailPdv> createState() => _ZoneDetailPdvState();
}

class _ZoneDetailPdvState extends State<ZoneDetailPdv> {
  bool loading = true;
  List<dynamic> zones = [];

  @override
  void initState() {
    super.initState();
    fetchZones();
  }

  Future<void> fetchZones() async {
    try {
      final url = Uri.parse(API.getPerformanceSiteZone);
      final response = await http.post(
        url,
        body: {"statut_pdv": widget.statut_pdv, "zone": widget.data['zone']},
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
      appBar: AppBar(
        backgroundColor: widget.color,
        foregroundColor: whiteColor,
        centerTitle: true,
        title: Text(
          "ZONE : ${widget.data['zone']}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),

      body: loading
          ? Center(child: CircularProgressIndicator(color: widget.color))
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
                      zone['secteur'] ?? 'Inconnu',
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
                            Text("PDV ${widget.statut_pdv}: ${zone['nombre']}"),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdvDetailSecteur(
                            secteur: zone['secteur'],
                            color: widget.color,
                            statut_pdv: widget.statut_pdv,
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
