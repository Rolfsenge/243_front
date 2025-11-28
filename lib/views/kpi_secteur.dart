import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/views/kpi_tl.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';

class KpiSecteur extends StatefulWidget {
  final Utilisateur utilisateur;
  final String secteur;
  final String mtd_secteur;
  final String pmtd_secteur;
  final String kpi;

  const KpiSecteur({
    super.key,
    required this.utilisateur,
    required this.secteur,
    required this.mtd_secteur,
    required this.pmtd_secteur,
    required this.kpi,
  });

  @override
  State<KpiSecteur> createState() => _KpiSecteurState();
}

class _KpiSecteurState extends State<KpiSecteur> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  final Color colorMtd = Colors.blue.shade700;
  final Color colorPmtd = Colors.orange.shade700;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final url = Uri.parse(API.getKpiSecteur);
      final response = await http.post(
        url,
        body: {'kpi': widget.kpi, 'secteur': widget.secteur},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          data = List<Map<String, dynamic>>.from(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur HTTP: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        title: Text(
          ' ${widget.kpi}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
          ? const Center(child: Text('Aucune donnée disponible'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: blackColor),
                    child: Text(
                      "SITES SECTEUR :  ${widget.secteur}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendDot(colorMtd, 'MTD'),
                      const SizedBox(width: 16),
                      _buildLegendDot(colorPmtd, 'LMTD'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 4,
                    child: Card(
                      elevation: 4,
                      color: whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: ListView.separated(
                          itemCount: data.length,
                          separatorBuilder: (_, __) => const Divider(height: 8),
                          itemBuilder: (context, i) {
                            final row = data[i];
                            final String site_name = row['site_name'] ?? "";
                            final String num_tl = row['num_tl'] ?? "";
                            final int mtd = row['mtd'];
                            final int pmtd = row['pmtd'];
                            final double diff = mtd - pmtd.toDouble();
                            final double pct = pmtd == 0
                                ? 0
                                : (diff / pmtd) * 100;

                            return InkWell(
                              onTap: () {
                                Get.to(
                                  () => KpiTl(
                                    utilisateur: widget.utilisateur,
                                    kpi: widget.kpi,
                                    num_tl: num_tl,
                                    site_name: site_name,
                                    mtd_site: mtd.toString(),
                                    pmtd_site: pmtd.toString(),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      site_name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          color: colorMtd,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatNumber(mtd),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          color: colorPmtd,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatNumber(pmtd),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '${diff >= 0 ? '+' : ''}${_formatNumber(diff.toInt())} (${pct.toStringAsFixed(1)}%)',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: diff >= 0
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "CUMUL : MTD ${widget.mtd_secteur} | LMTD ${widget.pmtd_secteur}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "${widget.kpi} - ${widget.secteur}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(color: primaryColor),
                ],
              ),
            ),
    );
  }

  String _formatNumber(int? n) {
    if (n == null) return '-';
    final s = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buffer.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  Widget _buildLegendDot(Color c, String label) => Row(
    children: [
      Container(width: 14, height: 12, color: c),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
