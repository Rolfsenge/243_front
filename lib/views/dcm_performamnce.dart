import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../class/utilisateur.dart';
import '../tools/color.dart';
import '../api_connection/api_connection.dart'; // si tu as ton fichier API centralisé

class DcmPerformamnce extends StatefulWidget {
  final Utilisateur utilisateur;
  const DcmPerformamnce({super.key, required this.utilisateur});

  @override
  State<DcmPerformamnce> createState() => _DcmPerformamnceState();
}

class _DcmPerformamnceState extends State<DcmPerformamnce> {
  DateTime? _selectedDate;

  /// 🔹 Requête HTTP vers ton API
  Future<List<dynamic>> fetchMarchands() async {
    try {
      // Remplace ici ton URL d’API
      final response = await http.post(
        Uri.parse(API.getDcmPerformance), // exemple : API.getDcmPerformance
        body: {
          "phone_dcm": widget.utilisateur.telephone,
          "region": widget.utilisateur.nomstructure,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Gère les deux formats possibles de réponse
        if (data is List) {
          return data;
        } else if (data['data'] != null) {
          return data['data'];
        } else {
          return [];
          //throw Exception("Format de données inattendu.");
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur réseau : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        title: const Text("Performances"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: "Filtrer par date",
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2026),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: "Réinitialiser le filtre",
              onPressed: () => setState(() => _selectedDate = null),
            ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchMarchands(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("❌ Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune donnée trouvée."));
          }

          final data = snapshot.data!;
          return _buildGroupedList(data);
        },
      ),
    );
  }

  Widget _buildGroupedList(List<dynamic> data) {
    // 🔹 Grouper les marchands par date
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    for (var item in data) {
      final dateStr = item['created_at'] ?? "";
      if (dateStr.isEmpty) continue;

      final dateKey = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.parse(dateStr.toString()));

      if (_selectedDate != null) {
        String filterDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        if (dateKey != filterDate) continue;
      }

      groupedByDate.putIfAbsent(dateKey, () => []);
      groupedByDate[dateKey]!.add(Map<String, dynamic>.from(item));
    }

    if (groupedByDate.isEmpty) {
      return const Center(
        child: Text("Aucun marchand trouvé pour cette date."),
      );
    }

    final List<Color> colors = [
      primaryColor,
      darcula,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.pink,
      Colors.amber,
    ];

    return ListView(
      padding: const EdgeInsets.all(10),
      children: groupedByDate.entries.map((entry) {
        final String date = entry.key;
        final List<Map<String, dynamic>> marchands = entry.value;

        // 🔹 Cumul par activité
        Map<String, int> cumulActivite = {};
        for (var m in marchands) {
          final activite = m['nomactivite'] ?? "Inconnue";
          cumulActivite[activite] = (cumulActivite[activite] ?? 0) + 1;
        }

        return Card(
          elevation: 10,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: const Icon(Icons.calendar_today, color: primaryColor),
            title: Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            subtitle: Text(
              "${marchands.length} marchands au total",
              style: const TextStyle(fontSize: 12),
            ),
            children: [
              // 📊 Graphique en camembert
              if (cumulActivite.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 30,
                      borderData: FlBorderData(show: false),
                      sections: List.generate(cumulActivite.length, (i) {
                        final key = cumulActivite.keys.elementAt(i);
                        final value = cumulActivite[key]!;
                        final total = marchands.length;
                        final pourcentage = ((value / total) * 100)
                            .toStringAsFixed(1);

                        return PieChartSectionData(
                          color: colors[i % colors.length],
                          value: value.toDouble(),
                          title: "$pourcentage%",
                          radius: 70,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),

              // 🔸 Légende
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cumulActivite.entries.mapIndexed((i, e) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: colors[i % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              e.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${e.value} marchands",
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const Divider(),

              // 🔹 Liste détaillée
              ...marchands.map((m) {
                return ListTile(
                  title: Text(
                    "${m['nom']} ${m['postnom']} ${m['prenom']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  subtitle: Text(
                    "${m['telephone']} | ${m['nomactivite']} (${m['secteur']})",
                    style: const TextStyle(fontSize: 10),
                  ),
                  trailing: Text(
                    DateFormat('HH:mm').format(DateTime.parse(m['created_at'])),
                    style: const TextStyle(fontSize: 11, color: darcula),
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }
}

extension _IndexedMap<K, V> on Iterable<MapEntry<K, V>> {
  Iterable<T> mapIndexed<T>(
    T Function(int index, MapEntry<K, V> entry) transform,
  ) sync* {
    int i = 0;
    for (final e in this) {
      yield transform(i++, e);
    }
  }
}
