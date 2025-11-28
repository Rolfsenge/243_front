// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:toast/toast.dart';

import '../api_connection/api_connection.dart';
import '../class/utilisateur.dart';
import '../menus/menu_all.dart';
import '../tools/circle_progress.dart';
import '../tools/color.dart';
import 'add_pdv.dart';
import 'kpi_tl_home.dart';
import 'pdv_detail_tl.dart';

class HomeTl extends StatefulWidget {
  final Utilisateur utilisateur;
  const HomeTl({super.key, required this.utilisateur});

  @override
  State<HomeTl> createState() => _HomeTlState();
}

class _HomeTlState extends State<HomeTl> {
  late Future<Map<String, dynamic>> dashboardFuture;
  var formKey = GlobalKey<FormState>();
  var phoneController = TextEditingController();
  final nameController = TextEditingController();

  String? completePhone;
  bool _isLoading = false;

  String latitude = "";
  String longitude = "";
  String statut = "Appuyez pour obtenir la position";
  String opdate_ac = "";
  String opdate_rev = "";
  String opdate_per = "";
  String opdate_ch = "";

  @override
  void initState() {
    super.initState();
    dashboardFuture = fetchDashboard();
    getLocation();
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await http.post(
      Uri.parse(API.getAcquisitionSiteHomeTL),
      body: {
        'idsite': widget.utilisateur.idstructure.toString(),
        'site_name': widget.utilisateur.nomstructure,
        'num_tl': widget.utilisateur.telephone,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des données.');
    }
  }

  // ------------------ AFFILIATION ------------------
  Future<void> affilier(String selectedRole) async {
    try {
      setState(() => _isLoading = true);

      var res = await http.post(
        Uri.parse(API.checkPdv4add),
        body: {
          "retailer_phone": completePhone,
          "retailer_name": nameController.text,
          "latitude": latitude,
          "longitude": longitude,
          "tl_phone": widget.utilisateur.telephone,
          "tl_name": widget.utilisateur.nomutilisateur,
          "type_acteur": selectedRole,
          "idstructure": widget.utilisateur.idstructure.toString(),
        },
      );

      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);

        if (resBody['success'] == true) {
          final Map<String, dynamic> data = resBody['contenu'];

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  AddPdv(utilisateur: widget.utilisateur, data: data),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          Toast.show(
            "ERREUR : ${resBody['message']}.",
            duration: Toast.lengthLong,
            gravity: Toast.center,
            backgroundColor: Colors.red,
          );
        }
      } else {
        Get.snackbar(
          "Erreur",
          "Pas de connexion internet",
          backgroundColor: Colors.red,
        );
      }
    } catch (error) {
      Get.snackbar("Erreur", error.toString(), backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ------------------ GPS ------------------
  Future<void> getLocation() async {
    setState(() => statut = "Vérification des permissions...");

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      statut = "Activez le service GPS";
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        statut = "Permission refusée";
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      statut = "Permission refusée définitivement";
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
      statut = "Position obtenue !";
    });
  }

  // ------------------ OPEN MENU ------------------
  void openMenu() {
    Get.dialog(
      Dialog(
        backgroundColor: whiteColor,
        child: MenuAll(utilisateur: widget.utilisateur),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return FutureBuilder<Map<String, dynamic>>(
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
        opdate_ac = maj["opdate_ac"] ?? "";
        opdate_rev = maj["opdate_rev"] ?? "";
        opdate_per = maj["opdate_per"] ?? "";
        opdate_ch = maj["opdate_ch"] ?? "";

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------------- ACQUISITIONS --------------------
                  _sectionTitle("Acquisitions", opdate_ac),
                  acquisitions.isNotEmpty
                      ? Column(children: buildAcquisitionWidgets(acquisitions))
                      : _emptyText("Aucune donnée d’acquisition."),

                  SizedBox(height: 30),

                  // ----------------- PERFORMANCE --------------------
                  _sectionTitleWithButton(
                    "Performance PDV",
                    opdate_per,
                    "AJOUTER",
                    remonter,
                  ),
                  performances.isNotEmpty
                      ? Column(children: buildPerformanceWidgets(performances))
                      : _emptyText("Aucune donnée de performance."),

                  SizedBox(height: 30),

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

  // ------------------ ACQUISITIONS ------------------
  List<Widget> buildAcquisitionWidgets(List acquisitions) {
    return acquisitions.map((item) {
      return Card(
        color: whiteColor,
        elevation: 10,
        margin: EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KpiTlHome(
                  utilisateur: widget.utilisateur,
                  kpi: item['kpi'],
                  mtd_site: item['total_mtd'],
                  pmtd_site: item['total_pmtd'],
                  num_tl: widget.utilisateur.telephone,
                  site_name: widget.utilisateur.nomstructure,
                ),
              ),
            );
          },
          child: ListTile(
            title: Text(
              item['kpi'] ?? '',
              style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "MTD : ${item['total_mtd']} | LMTD : ${item['total_pmtd']}",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      );
    }).toList();
  }

  // ------------------ PERFORMANCE ------------------
  List<Widget> buildPerformanceWidgets(List performances) {
    if (performances.isEmpty) return [];

    final item = performances[0];
    final baisse = num.tryParse(item['baisse'].toString()) ?? 0;

    List<Widget> widgets = [];

    if (baisse > 0) {
      widgets.add(
        buildRevenuCard(
          "Rupture de stock",
          baisse.toString(),
          primaryColor,
          item['taux_baisse'],
          item['total'],
          onTap: () => Get.to(
            () => PdvDetailTl(
              statut_pdv: "Rupture",
              color: primaryColor,
              tl_phone: widget.utilisateur.telephone,
              tl_name: widget.utilisateur.nomutilisateur,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget buildRevenuCard(
    String title,
    String value,
    Color color,
    dynamic pourcentage,
    dynamic total, {
    required Function() onTap,
  }) {
    return Card(
      elevation: 14,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      color: color,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Text(
            value,
            style: TextStyle(
              color: whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          title: Text(title, style: TextStyle(color: whiteColor)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${pourcentage.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Sur $total",
                style: TextStyle(color: darcula, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
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

  // ------------------ REMONTER ------------------
  Future<void> remonter() async {
    String? selectedRole;

    await Get.dialog(
      Dialog(
        backgroundColor: whiteColor,
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        "AFFILIER UN ACTEUR ?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),

                      SizedBox(height: 20),

                      // PHONE
                      IntlPhoneField(
                        controller: phoneController,
                        initialCountryCode: 'CD',
                        decoration: InputDecoration(
                          labelText: "Numéro Retailer",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (phone) =>
                            completePhone = phone.completeNumber,
                        onSaved: (phone) =>
                            completePhone = phone?.completeNumber,
                      ),

                      SizedBox(height: 10),

                      // NAME
                      TextFormField(
                        controller: nameController,
                        validator: (v) => v == "" ? "Nom réquis" : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          hintText: "Nom Retailer...",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 12),

                      // ROLE
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        items: [
                          DropdownMenuItem(
                            value: "Activateur",
                            child: Text("Activateur"),
                          ),
                          DropdownMenuItem(value: "PDV", child: Text("PDV")),
                        ],
                        decoration: InputDecoration(
                          labelText: "Rôle",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) =>
                            setStateDialog(() => selectedRole = v),
                        validator: (v) =>
                            v == null ? "Veuillez sélectionner un rôle" : null,
                      ),

                      SizedBox(height: 16),
                      Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              "NON",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                setStateDialog(() => _isLoading = true);
                                await affilier(selectedRole!);
                                setStateDialog(() => _isLoading = false);
                                Get.back();
                              }
                            },
                            child: _isLoading
                                ? CirclePimary()
                                : Text(
                                    "CONFIRMER",
                                    style: TextStyle(
                                      color: darcula,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }
}
