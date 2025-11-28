import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '/authentication/login_screen.dart';
import '/tools/color.dart';

import '../tools/circle_progress.dart';

class DelierDevice extends StatefulWidget {
  const DelierDevice({super.key});

  @override
  State<DelierDevice> createState() => _DelierDeviceState();
}

class _DelierDeviceState extends State<DelierDevice> {
  var formKey = GlobalKey<FormState>();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var isObsecure = true.obs;
  final bool _isLoading = false;
  int identifiant = 0;

  String? completePhone; // pour stocker le numéro complet

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blackColor),
          onPressed: () {
            Get.to(() => LoginScreen());
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, cons) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: cons.maxHeight),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: Image.asset(
                        "images/orange.jpg",
                      ),
                    ),
                    /*
                    const Text(
                      "SMS",
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Text(
                      "Site Monitoring System",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    */
                    //login screen header
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "DEMANDE DE DÉLIER VOTRE COMPTE",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 30, 30, 8),
                      child: Column(
                        children: [
                          //code-password-login button
                          Form(
                            key: formKey,
                            child: Column(
                              children: [
                                //code
                                IntlPhoneField(
                                  languageCode: 'fr',
                                  searchText: 'Rechercher un pays',
                                  dropdownIcon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: darcula,
                                  ),
                                  controller: phoneController,
                                  initialCountryCode: 'CD',
                                  dropdownTextStyle: TextStyle(
                                    fontSize: 12, // taille du texte des pays
                                    height: 1.0, // réduit la hauteur des lignes
                                  ), // RDC par défaut
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(
                                      Icons.phone_android,
                                      color: darcula,
                                    ),
                                    labelText: 'Numéro de téléphone',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  onChanged: (phone) {
                                    completePhone = phone.completeNumber;
                                  },
                                  onSaved: (phone) {
                                    completePhone = phone?.completeNumber;
                                  },
                                ),

                                //button
                                Material(
                                  color: blackColor,
                                  borderRadius: BorderRadius.circular(25),
                                  child: InkWell(
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        // resetCode();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 28,
                                      ),
                                      child: (_isLoading)
                                          ? const Circle()
                                          : const Text(
                                              "Obtenir OTP",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const Divider(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          //code
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: passwordController,
                            maxLength: 5,
                            decoration: InputDecoration(
                              labelText: 'Code OTP',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le code OTP';
                              }
                              if (value.length != 6) {
                                return 'Le code OTP doit contenir 6 chiffres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          //button
                          Material(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(25),
                            child: InkWell(
                              onTap: () {
                                if (formKey.currentState!.validate()) {
                                  //  resetCode();
                                }
                              },
                              borderRadius: BorderRadius.circular(25),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 28,
                                ),
                                child: (_isLoading)
                                    ? const Circle()
                                    : const Text(
                                        "Soumettre",
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
