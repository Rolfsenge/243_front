import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../creations/home_rlms.dart';
import '/class/utilisateur.dart';

import '../bdd/dbhelper.dart';
import '../menus/menu_all.dart';
import '../tools/color.dart';
import 'wallet_screen.dart';

class RlmsRemote extends StatefulWidget {
  final Utilisateur utilisateur;
  const RlmsRemote({super.key, required this.utilisateur});

  @override
  State<RlmsRemote> createState() => _RlmsRemoteState();
}

class _RlmsRemoteState extends State<RlmsRemote> {
  final _formKey = GlobalKey<FormState>();
  DatabaseHelper helper = DatabaseHelper.instance;

  final TextEditingController numeroCtrl = TextEditingController();

  // Fonction pour enregistrer dans SQLite
  Future<void> _saveRlms() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'rlms_idutilisateur': widget.utilisateur.idutilisateur,
        'numero': numeroCtrl.text,
      };

      await helper.inserer(data, 'rlms');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande RLMS enregistrée avec succès !')),
      );

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RLMS", style: TextStyle(color: whiteColor)),
        backgroundColor: primaryColor,
        actions: [MenuAll(utilisateur: widget.utilisateur)],
        leading: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) =>
                      WalletScreen(utilisateur: widget.utilisateur),
                ),
                (Route<dynamic> route) => false,
              );
            },
            icon: Icon(Icons.arrow_back, color: whiteColor),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: numeroCtrl,
                keyboardType: TextInputType.number,

                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly, // ✅ n'autorise que les chiffres
                  LengthLimitingTextInputFormatter(
                    9,
                  ), // ✅ limite à 9 caractères
                ],
                decoration: const InputDecoration(
                  labelText: "Numéro de téléphone",
                  prefixIcon: Icon(
                    Icons.phone_android,
                  ), // masque le compteur visuel
                ),
                validator: (value) {
                  print(value);

                  if (value == null || value.isEmpty) {
                    return "Ce champ est requis";
                  } else if (value.length < 1) {
                    return "Le numéro ne doit pas être vide";
                  } else if (value.length != 9) {
                    return "Le numéro doit contenir exactement 9 chiffres";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saveRlms,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.small(
        backgroundColor: blackColor,
        foregroundColor: primaryColor,
        onPressed: () {
          Get.to(() => HomeRlms(utilisateur: widget.utilisateur));
        },
        child: Icon(Icons.menu),
      ),
    );
  }

  // Fonction utilitaire pour créer un champ
  Widget buildTextField(
    String label,
    TextEditingController controller, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? "Champ requis" : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
