import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bdd/dbhelper.dart';
import '../menus/menu_all.dart';
import '../tools/color.dart';
import '/class/utilisateur.dart';
import 'wallet_screen.dart';

class ResetZebraPage extends StatefulWidget {
  final Utilisateur utilisateur;
  const ResetZebraPage({super.key, required this.utilisateur});

  @override
  State<ResetZebraPage> createState() => _ResetZebraPageState();
}

class _ResetZebraPageState extends State<ResetZebraPage> {
  final _formKey = GlobalKey<FormState>();
  DatabaseHelper helper = DatabaseHelper.instance;

  final TextEditingController numeroCtrl = TextEditingController();
  final TextEditingController soldeCtrl = TextEditingController();

  // Fonction pour enregistrer dans SQLite
  Future<void> _saveResetZebra() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'resetzebra_idutilisateur': widget.utilisateur.idutilisateur,
        'numero': numeroCtrl.text,
        'solde': soldeCtrl.text,
      };

      await helper.inserer(data, 'resetzebra');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande enregistrée avec succès !')),
      );

      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Pin Zebra", style: TextStyle(color: whiteColor)),
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
              buildField(soldeCtrl, "Solde", Icons.monetization_on),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saveResetZebra,
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
    );
  }

  Widget buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, icon: Icon(icon)),
        validator: (value) =>
            value == null || value.isEmpty ? "Champ requis" : null,
      ),
    );
  }
}
