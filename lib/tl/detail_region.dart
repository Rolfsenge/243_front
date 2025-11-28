import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtm/tl/detail_zone.dart';
import 'package:gtm/tools/color.dart';
import 'package:http/http.dart' as http;
import '../api_connection/api_connection.dart';
import '../views/wallet_screen.dart';
import '/class/utilisateur.dart';

class DetailRegion extends StatefulWidget {
  final Utilisateur utilisateur;
  const DetailRegion({super.key, required this.utilisateur});

  @override
  State<DetailRegion> createState() => _DetailRegionState();
}

class _DetailRegionState extends State<DetailRegion> {
  late Future<Map<String, dynamic>> dashboardFuture;
  String opdate_ch = "";

  @override
  void initState() {
    super.initState();
    dashboardFuture = fetchDashboard();
  }

  // ------------------ API ------------------
  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await http.post(Uri.parse(API.getCanalTlRegion));
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
        title: Text("Régions"),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    WalletScreen(utilisateur: widget.utilisateur),
              ),
              (Route<dynamic> route) => false,
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
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
                  const SizedBox(height: 16),
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
        Get.to(
          () => DetailZone(utilisateur: widget.utilisateur, region: regionName),
        );
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
