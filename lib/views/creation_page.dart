import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gtm/creations/home_kaabu.dart';
import '/class/utilisateur.dart';
import 'package:image_picker/image_picker.dart';

import '../bdd/dbhelper.dart';
import '../menus/menu_all.dart';
import '../tools/color.dart';
import 'wallet_screen.dart';

class CreationPage extends StatefulWidget {
  final Utilisateur utilisateur;
  const CreationPage({super.key, required this.utilisateur});

  @override
  State<CreationPage> createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  final _formKey = GlobalKey<FormState>();
  DatabaseHelper helper = DatabaseHelper.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // Contrôleurs pour chaque champ
  final TextEditingController idutilisateurCtrl = TextEditingController();
  final TextEditingController numeroCtrl = TextEditingController();
  final TextEditingController infraCategoryCtrl = TextEditingController();
  final TextEditingController agentPhoneCtrl = TextEditingController();
  final TextEditingController nomCtrl = TextEditingController();
  final TextEditingController postnomCtrl = TextEditingController();
  final TextEditingController prenomCtrl = TextEditingController();
  final TextEditingController infraPhoneCtrl = TextEditingController();
  final TextEditingController loginInfraCtrl = TextEditingController();
  final TextEditingController photoIDCtrl = TextEditingController();
  final TextEditingController plaintCtrl = TextEditingController();
  final TextEditingController statusCtrl = TextEditingController();
  final TextEditingController observationCtrl = TextEditingController();

  String? _selectedCategorieInfra;

  bool _isSaving = false;

  // Fonction pour enregistrer dans SQLite
  Future<void> _saveCreation() async {
    if (_formKey.currentState!.validate()) {
      String photoID = _imageFile?.path ?? "";

      if (photoID == "") {
        Get.snackbar(
          "ERREUR PIECE ID",
          "La pièce d'identité est obligatoire",
          backgroundColor: Colors.red,
          icon: Icon(Icons.photo_camera_front_outlined, color: whiteColor),
          duration: Duration(seconds: 5),
          colorText: whiteColor,
        );
      } else {
        try {
          setState(() => _isSaving = true);

          Map<String, dynamic> data = {
            'creation_idutilisateur': widget.utilisateur.idutilisateur,
            'infra_category': _selectedCategorieInfra,
            'agent_phone': widget.utilisateur.telephone,
            'nom': nomCtrl.text,
            'postnom': postnomCtrl.text,
            'prenom': prenomCtrl.text,
            'infra_phone': infraPhoneCtrl.text,
            'login_infra': 'RAS',
            'photoID': photoID,
            'plaint': 'RAS',
            'status': 'RAS',
            'observation': 'RAS',
          };

          await helper.inserer(data, 'creation');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Création Kaabu enregistrée avec succès"),
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    CreationPage(utilisateur: widget.utilisateur),
              ),
              (Route<dynamic> route) => false,
            );
          }

          _formKey.currentState!.reset();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur d’enregistrement : $e")),
          );
        } finally {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Création Kaabu", style: TextStyle(color: whiteColor)),
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
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategorieInfra,
                  decoration: const InputDecoration(
                    labelText: "Catégorie Infra",
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  items: const [
                    DropdownMenuItem(value: "WALKER", child: Text("WALKER")),
                    DropdownMenuItem(value: "SSO", child: Text("SSO")),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedCategorieInfra = value),
                  validator: (value) =>
                      value == null ? "Choisir la Catégorie Infra" : null,
                ),

                buildTextField("Nom", nomCtrl),
                buildTextField("Postnom", postnomCtrl),
                buildTextField("Prénom", prenomCtrl),

                TextFormField(
                  controller: infraPhoneCtrl,
                  keyboardType: TextInputType.number,

                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // ✅ n'autorise que les chiffres
                    LengthLimitingTextInputFormatter(
                      9,
                    ), // ✅ limite à 9 caractères
                  ],
                  decoration: const InputDecoration(
                    labelText: "Téléphone Infra",
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
                _buildImagePicker(),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveCreation,
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
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: blackColor,
        foregroundColor: primaryColor,
        onPressed: () {
          Get.to(() => HomeKaabu(utilisateur: widget.utilisateur));
        },
        child: Icon(Icons.menu),
      ),
    );
  }

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

  Widget _buildImagePicker() {
    return Column(
      children: [
        const Text(
          "Choisir la Carte ID",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: 250,
          height: 160,
          padding: const EdgeInsets.all(8), // 👈 marge interne du cadre
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(12), // coins arrondis
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_card_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt, color: primaryColor),
              label: Text("Capturer", style: TextStyle(color: primaryColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: primaryColor, width: 0.8),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image),
              label: Text("Galerie", style: TextStyle(color: darcula)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: darcula, width: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
