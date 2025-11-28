import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtm/creations/home_cico.dart';
import '/class/utilisateur.dart';
import '/menus/menu_all.dart';
import '/views/wallet_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../bdd/dbhelper.dart';
import '../tools/color.dart';

class CicoLite extends StatefulWidget {
  final Utilisateur utilisateur;

  const CicoLite({super.key, required this.utilisateur});

  @override
  State<CicoLite> createState() => _CicoLiteState();
}

class _CicoLiteState extends State<CicoLite> {
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

  // --- Contrôleurs des champs ---
  final TextEditingController _msisdnCtrl = TextEditingController();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _postnomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _numParentCtrl = TextEditingController();
  final TextEditingController _adresseCtrl = TextEditingController();
  final TextEditingController _numeroIdCtrl = TextEditingController();
  final TextEditingController _lieuNaissanceCtrl = TextEditingController();
  final TextEditingController _dateNaissanceCtrl = TextEditingController();
  final TextEditingController _nationaliteCtrl = TextEditingController();
  final TextEditingController _typeCarteIdCtrl = TextEditingController();

  String? _selectedSexe;
  String? _selectedTypeCarte;
  String? _selectedNationalite;
  bool _isSaving = false;

  // --- Sélecteur de date ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'CD'),
    );
    if (picked != null) {
      setState(() {
        _dateNaissanceCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- Sauvegarde dans la BD ---
  Future<void> _saveCicos() async {
    if (!_formKey.currentState!.validate()) return;

    String carteId = _imageFile?.path ?? "";

    if (carteId == "") {
      Get.snackbar(
        "ERREUR PIECE ID",
        "La pièce d'identité est obligatoire",
        backgroundColor: Colors.red,
        icon: Icon(Icons.photo_camera_front_outlined, color: whiteColor),
        duration: Duration(seconds: 5),
        colorText: whiteColor,
      );
    } else {
      setState(() => _isSaving = true);

      final cicos = {
        "msisdn": _msisdnCtrl.text.trim(),
        "nom": _nomCtrl.text.trim(),
        "postnom": _postnomCtrl.text.trim(),
        "prenom": _prenomCtrl.text.trim(),
        "carte_id": carteId, //_carteIdCtrl.text.trim(),
        "num_parent": widget.utilisateur.telephone,
        "user_id": widget.utilisateur.idutilisateur,
        "adresse": _adresseCtrl.text.trim(),
        "sexe": _selectedSexe,
        "nationalite": _selectedNationalite, //_nationaliteCtrl.text.trim(),
        "numero_id": _numeroIdCtrl.text.trim(),
        "lieu_naissance": _lieuNaissanceCtrl.text.trim(),
        "date_naissance": _dateNaissanceCtrl.text.trim(),
        "type_carte_id": _selectedTypeCarte, // _typeCarteIdCtrl.text.trim(),
        "sync": "NON",
        "created_at": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      };

      try {
        await helper.inserer(cicos, 'cicos');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("CICOS enregistré avec succès")),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => CicoLite(utilisateur: widget.utilisateur),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur d’enregistrement : $e")));
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Création Cico Lite", style: TextStyle(color: whiteColor)),
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildField(_nomCtrl, "Nom"),

              buildField(_postnomCtrl, "Post-nom"),

              buildField(_prenomCtrl, "Prénom"),

              TextFormField(
                controller: _msisdnCtrl,
                keyboardType: TextInputType.number,

                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly, // ✅ n'autorise que les chiffres
                  LengthLimitingTextInputFormatter(
                    9,
                  ), // ✅ limite à 9 caractères
                ],
                decoration: const InputDecoration(
                  labelText: "MSISDN",
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

              buildField(_adresseCtrl, "Adresse"),

              buildField(_lieuNaissanceCtrl, "Lieu de naissance"),

              TextFormField(
                controller: _dateNaissanceCtrl,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: "Date de naissance",
                  prefixIcon: Icon(Icons.date_range),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Sélectionnez la date" : null,
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedTypeCarte,
                decoration: const InputDecoration(
                  labelText: "Type Carte d'identité",
                  prefixIcon: Icon(Icons.credit_card),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Carte d'électeur",
                    child: Text("Carte d'électeur"),
                  ),
                  DropdownMenuItem(
                    value: "Passeport",
                    child: Text("Passeport"),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _selectedTypeCarte = value),
                validator: (value) =>
                    value == null ? "Choisissez le type de carte" : null,
              ),

              buildField(_numeroIdCtrl, "Numéro de la carte d'identité"),
              DropdownButtonFormField<String>(
                value: _selectedNationalite,
                decoration: const InputDecoration(
                  labelText: "Natinalité",
                  prefixIcon: Icon(Icons.credit_card),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Rep. Dém. Congo",
                    child: Text("Rep. Dém. Congo"),
                  ),
                  DropdownMenuItem(value: "Autre", child: Text("Autre")),
                ],
                onChanged: (value) =>
                    setState(() => _selectedNationalite = value),
                validator: (value) =>
                    value == null ? "Choisissez la nationalité" : null,
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedSexe,
                decoration: const InputDecoration(
                  labelText: "Sexe",
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: "Masculin", child: Text("Masculin")),
                  DropdownMenuItem(value: "Féminin", child: Text("Féminin")),
                ],
                onChanged: (value) => setState(() => _selectedSexe = value),
                validator: (value) =>
                    value == null ? "Choisissez le sexe" : null,
              ),

              const SizedBox(height: 20),

              _buildImagePicker(),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, color: whiteColor),
                label: Text(
                  _isSaving ? "Enregistrement..." : "Enregistrer",
                  style: TextStyle(color: whiteColor),
                ),
                onPressed: _isSaving ? null : _saveCicos,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
          Get.to(() => HomeCico(utilisateur: widget.utilisateur));
        },
        child: Icon(Icons.menu),
      ),
    );
  }

  // --- Widget champ réutilisable ---
  Widget buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.isEmpty ? "Champ requis" : null,
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
