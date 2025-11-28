import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../tools/color.dart';

class ContenuTl extends StatefulWidget {
  final String tl_phone;
  final String tl_name;
  const ContenuTl({super.key, required this.tl_phone, required this.tl_name});

  @override
  State<ContenuTl> createState() => _ContenuTlState();
}

class _ContenuTlState extends State<ContenuTl> {
  late Future<Map<String, dynamic>> dashboardFuture;
  bool _isLoading = false;
  String opdate_ch = "";

  @override
  void initState() {
    super.initState();
    dashboardFuture = fetchDashboard();
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await http.post(
      Uri.parse(API.getContenuCanalTl),
      body: {'tl_phone': widget.tl_phone},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des données.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.tl_name} : ${widget.tl_phone}",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingWidget(context);
          }

          if (snapshot.hasError) {
            return _errorWidget(context, snapshot.error.toString());
          }

          final data = snapshot.data ?? {};
          final acquisitions = data['acquisition'] ?? [];
          final revenus = data['revenus'] ?? [];
          final performances = data['performances'] ?? [];
          final challenges = data['challenges'] ?? [];

          Map<String, dynamic> maj = data['maj'][0];
          opdate_ch = maj["opdate_ch"] ?? "";

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----------------- CHALLENGES --------------------
                    _sectionTitle("Challenges", opdate_ch),
                    challenges.isNotEmpty
                        ? buildChallengeCard(challenges[0])
                        : _emptyText("Aucun challenge disponible."),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------ TITRES ------------------
  Widget _sectionTitle(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Date Op : $date",
              style: TextStyle(fontSize: 11, color: primaryColor),
            ),
          ],
        ),
        Divider(),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _sectionTitleWithButton(
    String title,
    String date,
    String btn,
    Function() onPress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: onPress,
              icon: Icon(Icons.add),
              label: Text(btn),
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(blackColor),
                foregroundColor: MaterialStatePropertyAll(whiteColor),
              ),
            ),
          ],
        ),
        Text(
          "Date Op : $date",
          style: TextStyle(fontSize: 11, color: primaryColor),
        ),
        Divider(),
        SizedBox(height: 8),
      ],
    );
  }

  // ------------------ MINI WIDGETS ------------------
  Widget _loadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 10),
          Text("Chargement des données..."),
        ],
      ),
    );
  }

  Widget _errorWidget(BuildContext context, String message) {
    return Center(
      child: Text("Erreur : $message", style: TextStyle(color: Colors.red)),
    );
  }

  Widget _emptyText(String msg) {
    return Text(msg, style: TextStyle(color: Colors.grey));
  }

  // ------------------ CHALLENGES ------------------
  Widget buildChallengeCard(Map<String, dynamic> item) {
    double fcAtteint =
        double.tryParse(item['fc_atteint'].toString().replaceAll(",", ".")) ??
        0;
    double fcqAtteint =
        double.tryParse(item['fcq_atteint'].toString().replaceAll(",", ".")) ??
        0;
    double gaAtteint =
        double.tryParse(item['ga_atteint'].toString().replaceAll(",", ".")) ??
        0;

    double fc1GbAtteint =
        double.tryParse(item['fc_1gb'].toString().replaceAll(",", ".")) ?? 0;

    return Card(
      elevation: 20,
      color: whiteColor,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "First Call",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 6),
            Divider(),

            // FC
            _challengeLine("Objectif (mois)", item['objectif_fc']),
            _challengeLine("Réalisé", item['fc_mtd']),
            _challengeLine("Taux (%)", "${fcAtteint.toStringAsFixed(2)} %"),
            _challengeBonus("Bonus (USD)", item['bonus_fc']),

            Divider(),

            Text(
              "First Call Qualité",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 6),
            Divider(),

            // FCQ
            _challengeLine("Objectif (mois)", item['objectif_fcq']),
            _challengeLine("Réalisé", item['fcq_mtd']),
            _challengeLine("Taux (%)", "${fcqAtteint.toStringAsFixed(2)} %"),
            _challengeBonus("Bonus (USD)", item['bonus_fcq']),

            SizedBox(height: 10),
            Divider(),
            Text(
              "GA / OM",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 6),
            Divider(),

            // GA
            _challengeLine("Objectif (mois)", item['objectif_ga_om']),
            _challengeLine("Réalisé", item['ga_om']),
            _challengeLine("Taux (%)", "${gaAtteint.toStringAsFixed(2)} %"),
            _challengeBonus("Bonus (USD)", item['bonus_ga_om']),

            SizedBox(height: 10),
            Divider(),
            Text(
              "First Call 1 GB (50U)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 6),
            Divider(),

            // 50U
            _challengeLine("Objectif (semaine)", item['objectif_50U']),
            _challengeLine("Réalisé", item['atteint_50U']),
            _challengeLine("Taux (%)", "${fc1GbAtteint.toStringAsFixed(2)} %"),
            _challengeBonus("Bonus (USD)", item['bonus_50U']),

            Divider(),

            // TOTAL
            _challengeTotal("Total Bonus", item['total']),
          ],
        ),
      ),
    );
  }

  Widget _challengeLine(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12)),
          Text(
            value.toString(),
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _challengeBonus(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "+$value",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _challengeTotal(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            "$value USD",
            style: TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
