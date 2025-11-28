import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';
import 'zone_detail_pdv.dart';

class DetailRegionPdv extends StatefulWidget {
  final Utilisateur utilisateur;
  final Color color;
  final String statut_pdv;
  final String region;

  const DetailRegionPdv({
    super.key,
    required this.utilisateur,
    required this.color,
    required this.statut_pdv,
    required this.region,
    required data,
  });

  @override
  State<DetailRegionPdv> createState() => _DetailRegionPdvState();
}

class _DetailRegionPdvState extends State<DetailRegionPdv> {
  bool loading = true;
  List<dynamic> zones = [];

  @override
  void initState() {
    super.initState();
    fetchZones();
  }

  Future<void> fetchZones() async {
    try {
      final url = Uri.parse(API.getPerformanceSiteRegion);
      final response = await http.post(
        url,
        body: {
          "statut_pdv": widget.statut_pdv, 
          "region": widget.region},
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
        title: Text(
          "REGION ${widget.region}",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.color,
        centerTitle: true,
        foregroundColor: whiteColor,
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
                      zone['zone'] ?? 'Zone inconnue',
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
                          builder: (_) => ZoneDetailPdv(
                            data: zone,
                            color: widget.color,
                            statut_pdv: widget.statut_pdv,
                            region: widget.region,
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
