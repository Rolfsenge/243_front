import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gtm/creations/home_zebra.dart';
import '/class/utilisateur.dart';

import '../bdd/dbhelper.dart';
import '../menus/menu_all.dart';
import '../tools/color.dart';
import 'wallet_screen.dart';

class ZebraPage extends StatefulWidget {
  final Utilisateur utilisateur;
  const ZebraPage({super.key, required this.utilisateur});

  @override
  State<ZebraPage> createState() => _ZebraPageState();
}

class _ZebraPageState extends State<ZebraPage> {
  final _formKey = GlobalKey<FormState>();
  DatabaseHelper helper = DatabaseHelper.instance;

  // Contrôleurs pour les champs
  final TextEditingController idutilisateurCtrl = TextEditingController();
  final TextEditingController numeroCtrl = TextEditingController();
  final TextEditingController userMsisdnCtrl = TextEditingController();
  final TextEditingController userNameCtrl = TextEditingController();
  final TextEditingController geographyCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();
  final TextEditingController statusCtrl = TextEditingController();
  final TextEditingController plaintCtrl = TextEditingController();
  final TextEditingController parentMsisdnCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  String? _selectedCategorie;

  // Fonction pour enregistrer dans SQLite
  Future<void> _saveZebra() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'zebra_idutilisateur': widget.utilisateur.idutilisateur,
        'numero': 'RAS',
        'user_msisdn': userMsisdnCtrl.text,
        'user_name': userNameCtrl.text,
        'geography': geographyCtrl.text,
        'category': _selectedCategorie,
        'status': 'RAS',
        'plaint': 'RAS',
        'parent_msisdn': 'RAS',
        'email': 'RAS',
      };

      await helper.inserer(data, 'zebra');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande Zebra enregistrée avec succès !'),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ZebraPage(utilisateur: widget.utilisateur),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Création Zebra", style: TextStyle(color: whiteColor)),
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
              buildTextField("Nom Utilisateur", userNameCtrl),
              TextFormField(
                controller: userMsisdnCtrl,
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

              DropdownButtonFormField<String>(
                value: _selectedCategorie,
                decoration: const InputDecoration(
                  labelText: "Catégorie",
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "SHOP DISTRIBUTOR",
                    child: Text("SHOP DISTRIBUTOR"),
                  ),
                  DropdownMenuItem(value: "RETAILER", child: Text("RETAILER")),
                ],
                onChanged: (value) =>
                    setState(() => _selectedCategorie = value),
                validator: (value) =>
                    value == null ? "Choisir la Catégorie" : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saveZebra,
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
          Get.to(() => HomeZebra(utilisateur: widget.utilisateur));
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
