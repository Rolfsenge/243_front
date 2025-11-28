import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtm/tools/color.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../tools/circle_progress.dart';
import 'login_screen.dart';

class Contacter extends StatefulWidget {
  const Contacter({super.key});

  @override
  State<Contacter> createState() => _ContacterState();
}

class _ContacterState extends State<Contacter> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final commentaireController = TextEditingController();
  final phoneController = TextEditingController();

  String? completePhone;
  String? _selectedTitre;
  bool _isLoading = false;

  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simuler un délai d’envoi (par exemple un appel HTTP)
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Effacer le formulaire
    nameController.clear();
    commentaireController.clear();
    phoneController.clear();
    setState(() => _selectedTitre = null);

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Votre message a été envoyé avec succès ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: LayoutBuilder(
        builder: (context, cons) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    child: Image.asset("images/orange.jpg"),
                  ),

                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      "Nous contacter",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedTitre,
                                decoration: const InputDecoration(
                                  labelText: "Motif",
                                  prefixIcon: Icon(Icons.category),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "Mot de passe oublié",
                                    child: Text("Mot de passe oublié"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Changement de téléphone",
                                    child: Text("Changement de téléphone"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Les deux",
                                    child: Text("Les deux"),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _selectedTitre = value),
                                validator: (value) =>
                                    value == null ? "Choisir un motif" : null,
                              ),

                              IntlPhoneField(
                                controller: phoneController,
                                initialCountryCode: 'CD',
                                decoration: const InputDecoration(
                                  labelText: 'Numéro de téléphone',
                                ),
                                onChanged: (phone) =>
                                    completePhone = phone.completeNumber,
                                onSaved: (phone) =>
                                    completePhone = phone?.completeNumber,
                              ),

                              TextFormField(
                                controller: nameController,
                                validator: (val) =>
                                    val!.isEmpty ? "Nom réquis" : null,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  hintText: "Votre nom ...",
                                  filled: false,
                                ),
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller: commentaireController,
                                maxLines: 2,
                                validator: (val) =>
                                    val!.isEmpty ? "Commentaire réquis" : null,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.list),
                                  hintText: "Commentaire",
                                  filled: true,
                                ),
                              ),

                              const SizedBox(height: 15),

                              Material(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: _isLoading ? null : _soumettre,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 28,
                                    ),
                                    child: _isLoading
                                        ? const Circle()
                                        : const Text(
                                            "Soumettre",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Vous avez un compte ?",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () => Get.to(() => LoginScreen()),
                              child: const Text(
                                "Se connecter",
                                style: TextStyle(color: mColor, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
