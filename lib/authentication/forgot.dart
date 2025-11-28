import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../api_connection/api_connection.dart';
import '../../authentication/login_screen.dart';
import '../../authentication/reset_code.dart';
import '../../tools/circle_progress.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

import '../tools/color.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var isObsecure = true.obs;
  bool _isLoading = false;
  String? completePhone; // pour stocker le numéro complet
  var phoneController = TextEditingController();

  Future<void> resetCode() async {
    String email = emailController.text.trim();

    try {
      setState(() {
        _isLoading = true;
      });

      var res = await http.post(
        Uri.parse(API.getOTP),
        body: {"telephone": completePhone},
      );

      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);
        if (resBody['success'] == true) {
          setState(() {
            _isLoading = false;
          });

          Future.delayed(const Duration(milliseconds: 100), () {
            Get.to(ResetCode());
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          Toast.show(
            "Paramètres Incorrects.\n ${resBody['message']}",
            duration: Toast.lengthLong,
            gravity: Toast.center,
            backgroundColor: const Color(0xffdc0808),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        Toast.show("Pas de connexion internet", duration: Toast.lengthLong);
      }
    } catch (errorMsg) {
      setState(() {
        _isLoading = false;
      });
      print("Error :: $errorMsg");
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
                    const SizedBox(height: 40),

                    //login screen header
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Obtention du Code",
                        style: TextStyle(
                          fontSize: 25.0,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 18, right: 18),
                      child: Text(
                        "En validant ce formulaire, un code de réinitialisation sera envoyé à votre numéro de téléphone que vous allez renseigner pour une durée de 30 minutes",
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ),

                    //login screen sign-in form
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

                                const SizedBox(height: 18),

                                //dont have an account button - button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Get.to(ResetCode());
                                      },
                                      child: const Text(
                                        "Renseignez le code ?",
                                        style: TextStyle(
                                          color: mColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                //button
                                Material(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(25),
                                  child: InkWell(
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        resetCode();
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

                          //dont have an account button - button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  "Connectez-vous",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
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
            ),
          );
        },
      ),
    );
  }
}
