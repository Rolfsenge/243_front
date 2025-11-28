import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gtm/class/utilisateur.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../api_connection/api_connection.dart';
import '../bdd/dbhelper.dart';
import '../menus/menu_all.dart';
import '../tools/color.dart';
import 'wallet_screen.dart';

class CreationPageDso extends StatefulWidget {
  final Utilisateur utilisateur;

  const CreationPageDso({super.key, required this.utilisateur});

  @override
  State<CreationPageDso> createState() => _CreationPageDsoState();
}

class _CreationPageDsoState extends State<CreationPageDso> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper helper = DatabaseHelper.instance;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;

  List<dynamic> activites = [];
  List<dynamic> fdvs = [];
  List<dynamic> secteurs = [];

  int? _selectedActivite;
  int? _selectedFdv;
  int? _selectedSecteur;

  bool _isSaving = false;

  // Contrôleurs de texte
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
  final TextEditingController observationCtrl = TextEditingController();

  String? _selectedCategorieInfra;

  @override
  void initState() {
    super.initState();
    fetchFdv();
    fetchActivites();
    fetchSecteur();
  }

  @override
  void dispose() {
    // 🔹 Libérer tous les contrôleurs pour éviter les fuites mémoire
    idutilisateurCtrl.dispose();
    numeroCtrl.dispose();
    infraCategoryCtrl.dispose();
    agentPhoneCtrl.dispose();
    nomCtrl.dispose();
    postnomCtrl.dispose();
    prenomCtrl.dispose();
    infraPhoneCtrl.dispose();
    loginInfraCtrl.dispose();
    photoIDCtrl.dispose();
    observationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && mounted) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    nomCtrl.clear();
    postnomCtrl.clear();
    prenomCtrl.clear();
    infraPhoneCtrl.clear();
    observationCtrl.clear();
    loginInfraCtrl.clear();
    agentPhoneCtrl.clear();
    numeroCtrl.clear();

    if (!mounted) return;
    setState(() {
      _selectedActivite = null;
      _selectedCategorieInfra = null;
      _imageFile = null;
    });
  }

  // 🔹 Charger les activités
  Future<void> fetchActivites() async {
    try {
      final url = Uri.parse(API.getActivite);
      final response = await http.post(
        url,
        body: {'idcategorie': widget.utilisateur.idcategorie.toString()},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          activites = json.decode(response.body);
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Erreur fetchActivites: $e");
    }
  }

  // 🔹 Charger les secteurs
  Future<void> fetchSecteur() async {
    try {
      final url = Uri.parse(API.getSecteur);
      final response = await http.post(
        url,
        body: {'idzone': widget.utilisateur.idstructure.toString()},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          secteurs = json.decode(response.body);
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Erreur fetchSecteur: $e");
    }
  }

  // 🔹 Charger les FDV
  Future<void> fetchFdv() async {
    try {
      final url = Uri.parse(API.getFdv);
      final response = await http.post(
        url,
        body: {
          'idcategorie': widget.utilisateur.idcategorie.toString(),
          'idzone': widget.utilisateur.idstructure.toString(),
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          fdvs = json.decode(response.body);
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Erreur fetchFdv: $e");
    }
  }

  // 🔹 Sauvegarde de la création
  Future<void> _saveCreation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      Get.snackbar(
        "ERREUR",
        "La pièce d'identité est obligatoire",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      final uri = Uri.parse(API.saveCreationMarchand);
      var request = http.MultipartRequest('POST', uri);

      request.fields['idutilisateur'] = widget.utilisateur.idutilisateur
          .toString();
      request.fields['idcategorie'] = widget.utilisateur.idcategorie.toString();
      request.fields['idzone'] = widget.utilisateur.idstructure.toString();
      request.fields['zone'] = widget.utilisateur.nomstructure;
      request.fields['dcm_name'] = widget.utilisateur.nomutilisateur;
      request.fields['phone_dcm'] = widget.utilisateur.telephone;
      request.fields['marchand_idfdv'] = _selectedFdv.toString();
      request.fields['marchand_idactivite'] = _selectedActivite.toString();
      request.fields['nom'] = nomCtrl.text;
      request.fields['postnom'] = postnomCtrl.text;
      request.fields['prenom'] = prenomCtrl.text;
      request.fields['telephone'] = infraPhoneCtrl.text;
      request.fields['idsecteur'] =
          (widget.utilisateur.idcategorie.toString() == "10")
          ? _selectedSecteur.toString()
          : widget.utilisateur.idstructure.toString();
      request.fields['observation'] = observationCtrl.text;

      var imageFile = await http.MultipartFile.fromPath(
        'cardID',
        _imageFile!.path,
        filename: _imageFile!.path.split('/').last,
      );
      request.files.add(imageFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        final resBody = await response.stream.bytesToString();
        final data = jsonDecode(resBody);

        if (data['success'] == true) {
          if (!mounted) return;
          Get.snackbar(
            "Succès",
            "Création enregistrée avec succès",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
          _resetForm();
        } else {
          if (!mounted) return;
          Get.snackbar(
            "Erreur",
            data['message'] ?? "Une erreur est survenue.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        if (!mounted) return;
        Get.snackbar(
          "Erreur serveur",
          "Code : ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        "Exception",
        "Erreur : $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  // 🔹 Construction de l'UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Création FDV", style: TextStyle(color: whiteColor)),
        backgroundColor: primaryColor,
        actions: [MenuAll(utilisateur: widget.utilisateur)],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    WalletScreen(utilisateur: widget.utilisateur),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                fdvs.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: "FDV"),
                        value: _selectedFdv,
                        items: fdvs.map((fdv) {
                          return DropdownMenuItem<int>(
                            value: fdv["idfdv"],
                            child: Text(fdv["nomfdv"]),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedFdv = val),
                      ),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Activité"),
                  value: _selectedActivite,
                  items: activites.map((act) {
                    return DropdownMenuItem<int>(
                      value: act["idactivite"],
                      child: Text(act["nomactivite"]),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedActivite = val),
                ),
                if (widget.utilisateur.idcategorie == 10)
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Secteur"),
                    value: _selectedSecteur,
                    items: secteurs.map((act) {
                      return DropdownMenuItem<int>(
                        value: act["idsecteur"],
                        child: Text(act["nomsecteur"]),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSecteur = val),
                  ),
                TextFormField(
                  controller: infraPhoneCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Téléphone Infra",
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ce champ est requis";
                    } else if (value.length != 9) {
                      return "Le numéro doit contenir exactement 9 chiffres";
                    }
                    return null;
                  },
                ),
                buildTextField("Nom", nomCtrl),
                buildTextField("Postnom", postnomCtrl),
                buildTextField("Prénom", prenomCtrl),
                TextFormField(
                  controller: observationCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Observation",
                    prefixIcon: Icon(Icons.text_snippet),
                  ),
                ),
                const SizedBox(height: 20),
                _buildImagePicker(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCreation,
                  icon: const Icon(Icons.save),
                  label: Text(_isSaving ? "Enregistrement..." : "Enregistrer"),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(12),
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
                  child: const Icon(
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
              icon: const Icon(Icons.camera_alt, color: primaryColor),
              label: const Text(
                "Capturer",
                style: TextStyle(color: primaryColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: primaryColor, width: 0.8),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image, color: darcula),
              label: const Text("Galerie", style: TextStyle(color: darcula)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: darcula, width: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
