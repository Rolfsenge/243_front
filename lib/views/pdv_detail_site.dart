import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_connection/api_connection.dart';
import '../tools/color.dart';

class PdvDetailSite extends StatefulWidget {
  final Color color;
  final String statut_pdv;
  final String tl_phone;
  final String retailer_name;
  final String site_name;

  const PdvDetailSite({
    super.key,
    required this.color,
    required this.statut_pdv,
    required this.tl_phone,
    required this.retailer_name,
    required this.site_name,
  });

  @override
  State<PdvDetailSite> createState() => _PdvDetailSiteState();
}

class _PdvDetailSiteState extends State<PdvDetailSite> {
  bool loading = true;
  List<dynamic> sites = [];
  List<dynamic> filteredSites = [];

  String selectedSegment = "Tous";
  String selectedGrade = "Tous";

  List<String> segments = ["Tous"];
  List<String> grades = ["Tous"];

  String _arrondir(dynamic valeur) {
    // Convertit tout (int, string, null, double…)
    double v = double.tryParse(valeur.toString()) ?? 0;
    return v.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    fetchPDVSite();
  }

  Future<void> fetchPDVSite() async {
    try {
      final url = Uri.parse(API.getPdvBySitex);
      final response = await http.post(
        url,
        body: {
          "statut_pdv": widget.statut_pdv,
          "site_name": widget.site_name,
          "tl_phone": widget.tl_phone,
          "retailer_name": widget.retailer_name,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print(data);

        setState(() {
          sites = data;
          filteredSites = List.from(sites);

          // 🧠 Extraire dynamiquement les segments et grades
          segments.addAll({
            ...data.map((e) => e['segment']?.toString() ?? 'Inconnu'),
          });
          grades.addAll({
            ...data.map(
              (e) => e['grade_systeme_zebra']?.toString() ?? 'Inconnu',
            ),
          });

          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors du chargement des PDV.")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur réseau : $e")));

      print(e);
    }
  }

  /// 🔍 Filtrage combiné segment + grade
  void applyFilters() {
    setState(() {
      filteredSites = sites.where((pdv) {
        final segmentOk =
            selectedSegment == "Tous" ||
            (pdv['segment'] ?? '').toString().toLowerCase() ==
                selectedSegment.toLowerCase();
        final gradeOk =
            selectedGrade == "Tous" ||
            (pdv['grade_systeme_zebra'] ?? '').toString().toLowerCase() ==
                selectedGrade.toLowerCase();
        return segmentOk && gradeOk;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        foregroundColor: whiteColor,
        centerTitle: true,
        title: Text(
          "SITE : ${widget.site_name}",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: widget.color))
          : Column(
              children: [
                // 🔽 Filtres
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filtrer par segment :",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: selectedSegment,
                            underline: Container(),
                            dropdownColor: Colors.white,
                            iconEnabledColor: widget.color,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            items: segments.map((seg) {
                              return DropdownMenuItem(
                                value: seg,
                                child: Text(seg),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedSegment = value;
                                applyFilters();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Filtrer par grade :",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: selectedGrade,
                            underline: Container(),
                            dropdownColor: Colors.white,
                            iconEnabledColor: widget.color,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            items: grades.map((g) {
                              return DropdownMenuItem(value: g, child: Text(g));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedGrade = value;
                                applyFilters();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // 📋 Liste filtrée
                Expanded(
                  child: filteredSites.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucun PDV trouvé pour ces filtres.",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredSites.length,
                          itemBuilder: (context, index) {
                            final pdv = filteredSites[index];
                            return buildPdvCard(pdv);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  /// 🧩 Carte PDV
  Widget buildPdvCard(Map<String, dynamic> pdv) {
    return Card(
      color: whiteColor,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pdv['segment'] ?? 'Inconnu',
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    pdv['statut_pdv'] ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: widget.color,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 📍 Infos principales
            Text(
              "HP N° : ${pdv['hp_no'] ?? ''}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "Grade : ${pdv['grade_systeme_zebra'] ?? ''}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "Service Actif : ${pdv['services_actifs'] ?? ''}",
              style: const TextStyle(fontSize: 12),
            ),
            const Divider(),

            // 💰 Infos chiffrées
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildInfoItem("Balance", "${pdv['balance'] ?? '0'} \$"),
                buildInfoItem("Moy. jour", "${pdv['moy_jour'] ?? '0'} \$"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildInfoItem("Vente MTD", "${pdv['vte_pdv_mtd'] ?? '0'}"),
                buildInfoItem("Vente RLMS", _arrondir(pdv['vte_rlms'])),
              ],
            ),
            const SizedBox(height: 6),

            // 🔄 Statuts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildStatusTag("Activité", pdv['statut_activite']),
                buildStatusTag("Performance", pdv['statut_performance']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget buildStatusTag(String label, dynamic status) {
    Color color = Colors.grey;
    if (status == "Hausse") color = Colors.green;
    if (status == "Baisse") color = Colors.red;
    if (status == "Stable") color = Colors.orange;

    return Chip(
      label: Text("$label: ${status ?? '-'}"),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
  }
}
