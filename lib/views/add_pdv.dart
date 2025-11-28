import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/tools/color.dart';
import '/views/home.dart';
import '/views/home_tl.dart';
import '/views/wallet_screen.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import '../api_connection/api_connection.dart';
import '/class/utilisateur.dart';

class AddPdv extends StatefulWidget {
  final Utilisateur utilisateur;
  final Map<String, dynamic> data; // contient une seule map
  const AddPdv({super.key, required this.utilisateur, required this.data});

  @override
  State<AddPdv> createState() => _AddPdvState();
}

class _AddPdvState extends State<AddPdv> {
  late Map<String, dynamic> pdv;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pdv = widget.data; // récupère le premier élément
  }

  Future<void> affilier() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      var res = await http.post(
        Uri.parse(API.addPDV),
        body: {
          "retailer_phone": pdv["retailer_phone"],
          "retailer_name": pdv["retailer_name"],
          "site_name": pdv["site_name"],
          "secteur": pdv["secteur"],
          "zone": pdv["zone"],
          "region": pdv["region"],
          "role": pdv["role"],
          "latitude": pdv["latitude"],
          "longitude": pdv["longitude"],
          "tl_phone": pdv["tl_phone"],
          "tl_name": widget.utilisateur.nomutilisateur,
        },
      );

      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);

        if (resBody['message'] == 'SUCCES') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  WalletScreen(utilisateur: widget.utilisateur),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          Toast.show(
            "ERREUR \n ${resBody['message']}.",
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
      print("Error :: $error");
      Get.snackbar("Erreur", error.toString(), backgroundColor: Colors.red);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("AFFILIATION PDV"),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildInfoCard(Icons.area_chart, "Rôle", pdv["role"]),
              buildInfoCard(Icons.place, "Site", pdv["site_name"]),
              buildInfoCard(
                Icons.phone_android,
                "Téléphone TL",
                pdv["tl_phone"],
              ),
              buildInfoCard(
                Icons.phone_iphone,
                "Téléphone Retailer",
                pdv["retailer_phone"],
              ),
              buildInfoCard(Icons.person, "Nom TL", pdv["tl_name"]),
              buildInfoCard(
                Icons.person_outline,
                "Nom Retailer",
                pdv["retailer_name"],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      affilier();

                      // ici tu mets ton action (soumission, enregistrement, etc.)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("PDV soumis avec succès !"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      "SOUMETTRE",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>
                              WalletScreen(utilisateur: widget.utilisateur),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blackColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text(
                      "ANNULER",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard(IconData icon, String label, dynamic value) {
    return Card(
      elevation: 10,
      color: whiteColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor, size: 28),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value != null && value.toString().isNotEmpty
              ? value.toString()
              : "Non défini",
        ),
      ),
    );
  }
}
