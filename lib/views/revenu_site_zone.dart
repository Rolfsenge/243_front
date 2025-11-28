import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';
import 'detail_zone_page.dart';

class RevenuSiteZone extends StatefulWidget {
  final Utilisateur utilisateur;
  final String groupe_m_usd;
  final String region;
  final Color color;
  final String total;

  const RevenuSiteZone({
    super.key,
    required this.utilisateur,
    required this.groupe_m_usd,
    required this.region,
    required this.color,
    required this.total,
  });

  @override
  State<RevenuSiteZone> createState() => _RevenuSiteZoneState();
}

class _RevenuSiteZoneState extends State<RevenuSiteZone> {
  bool isLoading = true;
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// 🔄 Récupération des données via HTTP
  Future<void> fetchData() async {
    try {
      final url = Uri.parse(API.getRevenuSiteRegion);
      final response = await http.post(
        url,
        body: {
          "total": widget.total,
          "region": widget.region,
          "groupe_m_usd": widget.groupe_m_usd,
        },
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
        title: Text(
          "Sites : ${widget.groupe_m_usd}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                final zone = item['zone'];
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
                      zone.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    zone,
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
                      /*
                      Icon(
                        taux >= 50 ? Icons.trending_up : Icons.trending_down,
                        color: tauxColor,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      */
                      Text(
                        "${taux.toStringAsFixed(2)} %",
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailZonePage(
                          zone: item['zone'],
                          data: item,
                          color: widget.color,
                          utilisateur: widget.utilisateur,
                          groupe_m_usd: widget.groupe_m_usd,
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
