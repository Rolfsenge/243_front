import 'dart:convert';

import 'package:flutter/material.dart';
import '../../api_connection/api_connection.dart';
import '../../authentication/login_screen.dart';
import '../../tools/circle_progress.dart';
import 'package:toast/toast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';

import '../tools/color.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  var isObsecure = true.obs;
  bool _isLoading = false;
  int identifiant = 0;

  String? completePhone; // pour stocker le numéro complet

  Future<void> inscription() async {
    setState(() {
      _isLoading = true;
    });
    String namabonne = nameController.text.trim();
    String email = emailController.text.trim();
    String motdepasse = passwordController.text.trim();
    String confirm = confirmController.text.trim();
    String telephone = phoneController.text.trim();

    if (motdepasse == confirm) {
      try {
        var res = await http.post(
          Uri.parse(API.signUp),
          body: {
            "nomabonne": namabonne,
            "email": email,
            "motdepasse": motdepasse,
            "telephone": completePhone,
          },
        );

        if (res.statusCode == 200) {
          var resBody = jsonDecode(res.body);
          if (resBody['success'] == true) {
            Toast.show("Compte créé avec succès");

            setState(() {
              nameController.clear();
              emailController.clear();
              phoneController.clear();
              passwordController.clear();
              confirmController.clear();
            });

            setState(() {
              _isLoading = false;
            });

            Get.to(LoginScreen());
          } else {
            setState(() {
              _isLoading = false;
            });
            Toast.show(
              resBody['userData'],
              duration: Toast.lengthLong,
              gravity: Toast.center,
              backgroundColor: const Color(0xffdc0808),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          Toast.show(
            "Pas de connexion internet",
            duration: Toast.lengthLong,
            gravity: Toast.center,
            backgroundColor: const Color(0xffdc0808),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print(e.toString());
        Toast.show(e.toString());
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      Toast.show(
        "Les deux mots de passe ne sont pas identiques",
        duration: Toast.lengthLong,
        gravity: Toast.center,
        backgroundColor: const Color(0xffdc0808),
      );
    }
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
                    height: 300,
                    child: Image.asset("images/orange.jpg"),
                  ),

                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      "INSCRIPTION",
                      style: TextStyle(
                        fontSize: 28.0,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 8),
                    child: Column(
                      children: [
                        Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                //name
                                TextFormField(
                                  controller: nameController,
                                  validator: (val) =>
                                      val == "" ? "Nom réquis" : null,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: Colors.black,
                                    ),
                                    hintText: "Votre nom ...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                //email
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.email,
                                      color: Colors.black,
                                    ),
                                    hintText: "email...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const SizedBox(height: 8),

                                /// 🔷 Champ téléphone avec intl_phone_field
                                IntlPhoneField(
                                  controller: phoneController,
                                  initialCountryCode: 'CD', // RDC par défaut
                                  decoration: const InputDecoration(
                                    labelText: 'Numéro de téléphone',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (phone) {
                                    completePhone = phone.completeNumber;
                                    print('Numéro complet : $completePhone');
                                  },
                                  onSaved: (phone) {
                                    completePhone = phone?.completeNumber;
                                  },
                                ),

                                const SizedBox(height: 8),
                                //password
                                Obx(
                                  () => TextFormField(
                                    controller: passwordController,
                                    obscureText: isObsecure.value,
                                    validator: (val) => val == ""
                                        ? "Mot de passe requis"
                                        : null,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.vpn_key_sharp,
                                        color: Colors.black,
                                      ),
                                      suffixIcon: Obx(
                                        () => GestureDetector(
                                          onTap: () {
                                            isObsecure.value =
                                                !isObsecure.value;
                                          },
                                          child: Icon(
                                            isObsecure.value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      hintText: "Mot de passe...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                //password
                                Obx(
                                  () => TextFormField(
                                    controller: confirmController,
                                    obscureText: isObsecure.value,
                                    validator: (val) => val == ""
                                        ? "Confirmation obligatoire"
                                        : null,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.vpn_key_sharp,
                                        color: Colors.black,
                                      ),
                                      suffixIcon: Obx(
                                        () => GestureDetector(
                                          onTap: () {
                                            isObsecure.value =
                                                !isObsecure.value;
                                          },
                                          child: Icon(
                                            isObsecure.value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      hintText: "Confirmer ...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const SizedBox(height: 8),

                                //button
                                Material(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        //validate the email
                                        inscription();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 28,
                                      ),
                                      child: (_isLoading)
                                          ? const Circle()
                                          : const Text(
                                              "S'inscrire",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),

                                /*
                               ElevatedButton(
                                 onPressed: () {
                                   if (formKey.currentState!.validate()) {
                                     formKey.currentState!.save();

                                     print('Nom : ${nameController.text}');
                                     print('Email : ${emailController.text}');
                                     print('Téléphone : $completePhone');
                                     print('Mot de passe : ${passwordController.text}');
                                     print('Confirmer : ${confirmController.text}');

                                     /// ici tu peux appeler ton API d'inscription
                                   }
                                 },
                                 child: const Text("S'inscrire"),
                               ),
                              */
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        //dont have an account button - button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Vous avez un compte ?",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.to(LoginScreen());
                              },
                              child: const Text(
                                "Se Connecter",
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
