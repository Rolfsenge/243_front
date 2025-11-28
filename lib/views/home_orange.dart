import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtm/tl/detail_region.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '/tools/color.dart';
import '/views/performance_pdv.dart';
import '/views/revenu_site_all.dart';
import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import 'kpi_national.dart';

// 56794b075e2dbd52e6380844db2a6b46f5ad032d

class HomeOrange extends StatefulWidget {
  final Utilisateur utilisateur;
  const HomeOrange({super.key, required this.utilisateur});

  @override
  State<HomeOrange> createState() => _HomeOrangeState();
}

class _HomeOrangeState extends State<HomeOrange> {
  late Future<Map<String, dynamic>> dashboardFuture;

  String opdate_ac = "";
  String opdate_rev = "";
  String opdate_per = "";
  String opdate_ch = "";

  @override
  void initState() {
    super.initState();
    dashboardFuture = fetchDashboard();
  }

  // ------------------ API ------------------
  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await http.post(Uri.parse(API.getAcquisitionNational));
    if (response.statusCode == 200) {
      // print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des données');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 24),
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 12),
                Text('Chargement des données...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        final revenus = data['revenus'][0];
        final perf = data['performances'][0];
        final canalTl = data['canalTl'] ?? [];

        Map<String, dynamic> maj = data['maj'][0];

        // parcourir maj
        maj.forEach((key, value) {
          if (key == "opdate_ac") {
            opdate_ac = value;
          }
          if (key == "opdate_rev") {
            opdate_rev = value;
          }
          if (key == "opdate_per") {
            opdate_per = value;
          }
          if (key == "opdate_ch") {
            opdate_ch = value;
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------ Acquisition ------------------
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Acquisitions Globales",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    "Date Op: $opdate_ac",
                    style: const TextStyle(fontSize: 11, color: primaryColor),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              ...buildAcquisitionWidgets(data['acquisition']),
              const SizedBox(height: 24),

              // ------------------ Canal TL (NOUVELLE SECTION) ------------------
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Acquisition Canal TL",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    "Date Op: $opdate_ch",
                    style: const TextStyle(fontSize: 11, color: primaryColor),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              if (canalTl.isEmpty)
                const Text(
                  "Aucune donnée Canal TL disponible.",
                  style: TextStyle(color: Colors.grey),
                )
              else ...[
                const SizedBox(height: 16),
                // Cartes premium par région
                Column(
                  children: canalTl
                      .map<Widget>((r) => _buildCanalTlCard(r))
                      .toList(),
                ),
              ],

              const SizedBox(height: 24),

              // ------------------ Revenus des Sites ------------------
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Revenus des Sites",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    "Date Op: $opdate_rev",
                    style: const TextStyle(fontSize: 11, color: primaryColor),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              InkWell(
                onTap: () => Get.to(
                  () => RevenuSiteAll(
                    utilisateur: widget.utilisateur,
                    groupe_m_usd: "Rentable",
                    color: Colors.green,
                    total: _str(revenus['total_sites']),
                  ),
                ),
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 48,
                              sections: [
                                PieChartSectionData(
                                  value: _toDouble(revenus['rentables']),
                                  color: Colors.green,
                                  title: '${_str(revenus['taux_rentables'])}%',
                                  radius: 70,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: _toDouble(revenus['non_rentables']),
                                  color: primaryColor,
                                  title:
                                      '${_str(revenus['taux_non_rentables'])}%',
                                  radius: 70,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: _toDouble(revenus['superformer']),
                                  color: Colors.blue,
                                  title:
                                      '${_str(revenus['taux_superformer'])}%',
                                  radius: 70,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  if (response?.touchedSection != null) {
                                    final idx = response!
                                        .touchedSection!
                                        .touchedSectionIndex;
                                    if (idx == 0) {
                                      Get.to(
                                        () => RevenuSiteAll(
                                          utilisateur: widget.utilisateur,
                                          groupe_m_usd: "Rentable",
                                          color: Colors.green,
                                          total: _str(revenus['total_sites']),
                                        ),
                                      );
                                    } else if (idx == 1) {
                                      Get.to(
                                        () => RevenuSiteAll(
                                          utilisateur: widget.utilisateur,
                                          groupe_m_usd: "Non Rentable",
                                          color: primaryColor,
                                          total: _str(revenus['total_sites']),
                                        ),
                                      );
                                    } else if (idx == 2) {
                                      Get.to(
                                        () => RevenuSiteAll(
                                          utilisateur: widget.utilisateur,
                                          groupe_m_usd: "superformer",
                                          color: Colors.blue,
                                          total: _str(revenus['total_sites']),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Legend(
                          entries: [
                            LegendEntry(
                              color: Colors.green,
                              label: "Rentables",
                              value: _str(revenus['rentables']),
                              percent: _str(revenus['taux_rentables']),
                            ),
                            LegendEntry(
                              color: primaryColor,
                              label: "Non rentables",
                              value: _str(revenus['non_rentables']),
                              percent: _str(revenus['taux_non_rentables']),
                            ),
                            LegendEntry(
                              color: Colors.blue,
                              label: "Superformer",
                              value: _str(revenus['superformer']),
                              percent: _str(revenus['taux_superformer']),
                            ),
                          ],
                          trailingNote:
                              "Total sites : ${_str(revenus['total_sites'])}",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------------------ Performance PDV ------------------
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Performance PDV",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    "Date Op: $opdate_per",
                    style: const TextStyle(fontSize: 11, color: primaryColor),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              InkWell(
                onTap: () => Get.to(
                  () => PerformancePdv(
                    utilisateur: widget.utilisateur,
                    statut_pdv: "Rupture",
                    color: primaryColor,
                    total: _str(perf['total']),
                  ),
                ),
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _toDouble(perf['hausse']),
                                      color: Colors.green,
                                      width: 40,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _toDouble(perf['baisse']),
                                      color: primaryColor,
                                      width: 40,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                ),
                              ],
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchCallback: (event, response) {
                                  final idx =
                                      response?.spot?.touchedBarGroupIndex;
                                  if (idx == 0) {
                                    Get.to(
                                      () => PerformancePdv(
                                        utilisateur: widget.utilisateur,
                                        statut_pdv: "Stock Exist",
                                        color: Colors.green,
                                        total: _str(perf['total']),
                                      ),
                                    );
                                  } else if (idx == 1) {
                                    Get.to(
                                      () => PerformancePdv(
                                        utilisateur: widget.utilisateur,
                                        statut_pdv: "Rupture",
                                        color: primaryColor,
                                        total: _str(perf['total']),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Legend(
                          entries: [
                            LegendEntry(
                              color: Colors.green,
                              label: "Sans rupture",
                              value: _str(perf['hausse']),
                              percent: _str(perf['taux_hausse']),
                            ),
                            LegendEntry(
                              color: primaryColor,
                              label: "Rupture de stock",
                              value: _str(perf['baisse']),
                              percent: _str(perf['taux_baisse']),
                            ),
                          ],
                          trailingNote: "Total PDV : ${_str(perf['total'])}",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ------------------ Fonctions auxiliaires ------------------
  List<Widget> buildAcquisitionWidgets(List acquisitions) {
    return acquisitions.map((item) {
      return Card(
        color: whiteColor,
        elevation: 20,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KpiNational(
                  utilisateur: widget.utilisateur,
                  kpi: item['kpi'],
                  total_mtd: item['total_mtd'],
                  total_pmtd: item['total_pmtd'],
                ),
              ),
            );
          },
          child: ListTile(
            title: Text(
              _str(item['kpi']),
              style: const TextStyle(
                color: blackColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              'MTD : ${_str(item['total_mtd'])} | LMTD : ${_str(item['total_pmtd'])}',
              style: const TextStyle(
                color: blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static String _str(dynamic v) => v?.toString() ?? '0';

  // ------------------ Canal TL : Carte premium par région ------------------
  Widget _buildCanalTlCard(Map<String, dynamic> region) {
    final regionName = _str(region['region']);
    final fcMtd = _str(region['fc_mtd']);
    final fcqMtd = _str(region['fcq_mtd']);
    final gaOm = _str(region['ga_om']);
    final fc1Gb = _str(region['fc_1gb']);
    final tlPro = _str(region['tl_pro']);
    final totTl = _str(region['tot_tl']);
    final tlActifs = _str(region['tl']);
    final bonusFc = _str(region['bonus_fc']);
    final bonusFcq = _str(region['bonus_fcq']);
    final bonusGaOm = _str(region['bonus_ga_om']);
    final bonus50u = _str(region['bonus_50U']);
    final gagnant = _str(region['gagnant']);

    final bool hasWinner = gagnant != "0" && gagnant != "";

    // Calcul du taux TL Actifs
    final double tlActifsNum = double.tryParse(tlActifs) ?? 0;
    final double totTlNum = double.tryParse(totTl) ?? 0;
    final double tlRate = totTlNum == 0 ? 0 : (tlActifsNum / totTlNum) * 100;

    return InkWell(
      onTap: () {
        Get.to(() => DetailRegion(utilisateur: widget.utilisateur));
      },
      child: Card(
        elevation: 20,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header : Région + gagnants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    regionName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  if (hasWinner)
                    Chip(
                      label: Text(
                        "Gagnants : $gagnant",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      backgroundColor: primaryColor,
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(),

              // Ligne 1 : FC / FCQ / GA-OM
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _canalInfoBlock("FC", fcMtd),
                  _canalInfoBlock("FCQ", fcqMtd),
                  _canalInfoBlock("GA/OM", gaOm),
                  _canalInfoBlock("FC 50U", fc1Gb),
                ],
              ),
              const SizedBox(height: 8),

              // Ligne 2 : TL Pro / TL total / TL actifs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _canalInfoBlock("TL Total", totTl),
                  _canalInfoBlock("TL Pro", tlPro),

                  _canalInfoBlock("TL Actifs", tlActifs),
                  _canalInfoBlock(
                    "% TL Actifs",
                    "${tlRate.toStringAsFixed(2)}%",
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Ligne 3 : Bonus
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _canalBonusChip("FC", bonusFc),
                  _canalBonusChip("FCQ", bonusFcq),
                  _canalBonusChip("GA/OM", bonusGaOm),
                  if (bonus50u != "null" && bonus50u != "0")
                    _canalBonusChip("1GB 50U", bonus50u),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _canalInfoBlock(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _canalBonusChip(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: blackColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              "$value \$",
              style: const TextStyle(
                fontSize: 8,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ Légendes alignées à gauche ------------------

class _Legend extends StatelessWidget {
  final List<LegendEntry> entries;
  final String? trailingNote;
  const _Legend({super.key, required this.entries, this.trailingNote});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...entries.map(
          (e) => GestureDetector(
            onTap: () {
              if (e.label.contains("Rupture")) {
                Get.to(
                  () => PerformancePdv(
                    utilisateur: Get.arguments['utilisateur'],
                    statut_pdv: e.label,
                    color: e.color,
                    total: e.value,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _LegendItem(entry: e),
            ),
          ),
        ),
        if (trailingNote != null) ...[
          const SizedBox(height: 8),
          Text(
            trailingNote!,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ],
    );
  }
}

class LegendEntry {
  final Color color;
  final String label;
  final String value;
  final String? percent;
  LegendEntry({
    required this.color,
    required this.label,
    required this.value,
    this.percent,
  });
}

class _LegendItem extends StatelessWidget {
  final LegendEntry entry;
  const _LegendItem({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          entry.percent == null
              ? '${entry.label}: ${entry.value}'
              : '${entry.label}: ${entry.value} (${entry.percent}%)',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
