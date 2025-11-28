import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';
import 'detail_region_pdv.dart';

class PerformancePdv extends StatefulWidget {
  final Utilisateur utilisateur;
  final String statut_pdv;
  final Color color;
  final String total;
  const PerformancePdv({
    super.key,
    required this.utilisateur,
    required this.statut_pdv,
    required this.color,
    required this.total,
  });

  @override
  State<PerformancePdv> createState() => _PerformancePdvState();
}

class _PerformancePdvState extends State<PerformancePdv> {
  bool isLoading = true;
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final url = Uri.parse(API.getPdvSiteAll);
      final response = await http.post(
        url,
        body: {"total": widget.total, "statut_pdv": widget.statut_pdv},
      );

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);

          isLoading = false;
        });
      } else {
        throw Exception("Erreur serveur ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Erreur HTTP: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: widget.color,
        foregroundColor: whiteColor,
        centerTitle: true,
        title: Text(
          "PDV : ${widget.statut_pdv} : Région",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: widget.color))
          : data.isEmpty
          ? const Center(child: Text("Aucune donnée disponible"))
          : ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final item = data[index];
                final region = item['region'];
                final nombre = item['nombre'];
                final total = item['total'];
                final taux = (item['taux'] ?? 0).toDouble();

                final tauxColor = taux >= 50
                    ? Colors.green
                    : Colors.red; // ✅ ici

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.color.withOpacity(0.2),
                    child: Text(
                      region.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    region,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    "Nombre: $nombre / Total: $total",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      Text(
                        "${taux.toStringAsFixed(2)} %",
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailRegionPdv(
                          region: region,
                          data: item,
                          color: widget.color,
                          utilisateur: widget.utilisateur,
                          statut_pdv: widget.statut_pdv,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
