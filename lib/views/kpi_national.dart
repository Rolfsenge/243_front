import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/api_connection/api_connection.dart';
import '/class/utilisateur.dart';
import '/tools/color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'kpi_region.dart';

class KpiNational extends StatefulWidget {
  final Utilisateur utilisateur;
  final String kpi;
  final String total_mtd;
  final String total_pmtd;
  const KpiNational({
    super.key,
    required this.utilisateur,
    required this.kpi,
    required this.total_mtd,
    required this.total_pmtd,
  });

  @override
  State<KpiNational> createState() => _KpiNationalState();
}

class _KpiNationalState extends State<KpiNational> {
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
      final url = Uri.parse(API.getKpiNational);
      final response = await http.post(url, body: {'kpi': widget.kpi});

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
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.kpi,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
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
                      "REGIONS",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                            final String region = row['nomregion'];
                            final int mtd = row['mtd'];
                            final int pmtd = row['pmtd'];
                            final double diff = mtd - pmtd.toDouble();
                            final double pct = pmtd == 0
                                ? 0
                                : (diff / pmtd) * 100;

                            return InkWell(
                              onTap: () {
                                Get.to(
                                  () => KpiRegion(
                                    utilisateur: widget.utilisateur,
                                    region: region,
                                    mtd_region: mtd.toString(),
                                    pmtd_region: pmtd.toString(),
                                    kpi: widget.kpi,
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      region,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
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
                                          style: const TextStyle(fontSize: 10),
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
                                          style: const TextStyle(fontSize: 10),
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
                                        fontSize: 9,
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
                    "CUMUL : MTD ${widget.total_mtd} | LMTD ${widget.total_pmtd}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    widget.kpi,
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

  BarChartData _buildBarData() {
    final groups = <BarChartGroupData>[];

    for (var i = 0; i < data.length; i++) {
      final row = data[i];
      final double mtd = (row['mtd'] as num).toDouble();
      final double pmtd = (row['pmtd'] as num).toDouble();

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: pmtd,
              width: 4,
              borderRadius: BorderRadius.circular(2),
              color: colorPmtd,
            ),
            BarChartRodData(
              toY: mtd,
              width: 3,
              borderRadius: BorderRadius.circular(2),
              color: colorMtd,
            ),
          ],
          barsSpace: 4,
        ),
      );
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _calculateMaxY() * 1.12,
      barGroups: groups,
      groupsSpace: 18,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 56,
            getTitlesWidget: (v, m) => Text(v.toInt().toString()),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
              return SideTitleWidget(
                meta: meta,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    data[idx]['nomregion'],
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              );
            },
            reservedSize: 80,
            interval: 1,
          ),
        ),
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final row = data[group.x.toInt()];
            final mtd = row['mtd'];
            final pmtd = row['pmtd'];
            return BarTooltipItem(
              '${row['nomregion']}\n',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'PMTD: ${_formatNumber(pmtd)}\n',
                  style: const TextStyle(color: Colors.white70),
                ),
                TextSpan(
                  text: 'MTD: ${_formatNumber(mtd)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            );
          },
        ),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
    );
  }

  double _calculateMaxY() {
    double maxY = 0;
    for (var row in data) {
      final mtd = (row['mtd'] as num).toDouble();
      final pmtd = (row['pmtd'] as num).toDouble();
      if (mtd > maxY) maxY = mtd;
      if (pmtd > maxY) maxY = pmtd;
    }
    return maxY;
  }

  Widget _buildLegendDot(Color c, String label) => Row(
    children: [
      Container(width: 14, height: 12, color: c),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );

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
}
