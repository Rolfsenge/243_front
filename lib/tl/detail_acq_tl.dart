import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtm/class/utilisateur.dart';
import 'package:gtm/tl/contenu_tl.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../tools/color.dart';

class DetailAcqTl extends StatefulWidget {
  final Utilisateur utilisateur;
  final String secteur;
  const DetailAcqTl({
    super.key,
    required this.utilisateur,
    required this.secteur,
  });

  @override
  State<DetailAcqTl> createState() => _DetailAcqTlState();
}

class _DetailAcqTlState extends State<DetailAcqTl> {
  late Future<Map<String, dynamic>> dashboardFuture;
  String opdate_ch = "";

  @override
  void initState() {
    super.initState();
    dashboardFuture = fetchDashboard();
  }

  // ------------------ API ------------------
  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await http.post(
      Uri.parse(API.getCanalTlBySecteur),
      body: {'secteur': widget.secteur},
    );
    if (response.statusCode == 200) {
      // print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des données');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.secteur),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
          final canalTl = data['canalTl'] ?? [];

          Map<String, dynamic> maj = data['maj'][0];

          // parcourir maj
          maj.forEach((key, value) {
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
                  // Cartes premium par région
                  Column(
                    children: canalTl
                        .map<Widget>((r) => _buildCanalTlCard(r))
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static String _str(dynamic v) => v?.toString() ?? '0';

  // ------------------ Canal TL : Carte premium par région ------------------
  Widget _buildCanalTlCard(Map<String, dynamic> region) {
    final tl_name = _str(region['tl_name']);
    final tl_phone = _str(region['tl_phone']);
    final bonusFc = _str(region['bonus_fc']);
    final bonusFcq = _str(region['bonus_fcq']);
    final bonusGaOm = _str(region['bonus_ga_om']);
    final bonus50u = _str(region['bonus_50U']);

    return InkWell(
      onTap: () {
        Get.to(() => ContenuTl(tl_phone: tl_phone, tl_name: tl_name));
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
                    "$tl_name - $tl_phone",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
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
