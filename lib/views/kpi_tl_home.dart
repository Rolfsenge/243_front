import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../tools/color.dart';

class KpiTlHome extends StatefulWidget {
  final Utilisateur utilisateur;
  final String site_name;
  final String mtd_site;
  final String pmtd_site;
  final String kpi;
  final String num_tl;

  const KpiTlHome({
    super.key,
    required this.utilisateur,
    required this.site_name,
    required this.mtd_site,
    required this.pmtd_site,
    required this.kpi,
    required this.num_tl,
  });

  @override
  State<KpiTlHome> createState() => _KpiTlHomeState();
}

class _KpiTlHomeState extends State<KpiTlHome> {
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
      final url = Uri.parse(API.getKpiByTlHome);
      final response = await http.post(
        url,
        body: {
          'kpi': widget.kpi,
          'site_name': widget.site_name,
          'tl_phone': widget.utilisateur.telephone,
        },
      );

      print(widget.utilisateur.telephone);

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
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
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
                      "${widget.utilisateur.nomutilisateur}  : TL ${widget.site_name}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: whiteColor, fontSize: 11),
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
                            final String num_activateur =
                                row['num_activateur'] ?? "";
                            final String tlName = row['retailer_name'] ?? "";
                            final int mtd = row['mtd'];
                            final int pmtd = row['pmtd'];
                            final double diff = mtd - pmtd.toDouble();
                            final double pct = pmtd == 0
                                ? 0
                                : (diff / pmtd) * 100;

                            return InkWell(
                              onTap: () {
                                /*
                          Get.to(
                                () => KpiActivateur(
                              utilisateur: widget.utilisateur,
                              kpi: widget.kpi,
                              tl_name: tlName,
                              num_tl: num_activateur,
                              site_name: widget.site_name,
                              mtd_tl: mtd.toString(),
                              pmtd_tl: pmtd.toString(),
                            ),
                          );
                          *
                          */
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      "$tlName ($num_activateur) ",
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
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
                    "CUMUL : MTD ${widget.mtd_site} | LMTD ${widget.pmtd_site}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    "${widget.kpi} - ${widget.site_name}",
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
