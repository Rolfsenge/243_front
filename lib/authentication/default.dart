import 'dart:convert';

import 'package:flutter/material.dart';
import '../api_connection/api_connection.dart';
import '../bdd/dbhelper.dart';
import '../class/utilisateur.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:toast/toast.dart';

import '../tools/circle_progress.dart';
import '../tools/color.dart';
import 'login_screen.dart';

class Default extends StatefulWidget {
  final Utilisateur utilisateur;
  const Default({super.key, required this.utilisateur});

  @override
  State<Default> createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  var formKey = GlobalKey<FormState>();
  var codeController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmController = TextEditingController();
  var isObsecure = true.obs;
  bool _isLoading = false;

  DatabaseHelper helper = DatabaseHelper.instance;

  Future<void> editerPwd(String idutilisateur) async {
    String motdepasse = passwordController.text.trim();
    String confirm = confirmController.text.trim();

    if (confirm == motdepasse) {
      try {
        setState(() {
          _isLoading = true;
        });

        var res = await http.post(
          Uri.parse(API.resetdefault),
          body: {"idutilisateur": idutilisateur, "motdepasse": motdepasse},
        );

        if (res.statusCode == 200) {
          var resBody = jsonDecode(res.body);
          if (resBody['success'] == true) {
            setState(() {
              _isLoading = false;
            });

            Toast.show(
              "Mot de passe modifié avec succès",
              duration: Toast.lengthLong,
              gravity: Toast.top,
              backgroundColor: Color.fromARGB(255, 49, 202, 2),
            );

            Future.delayed(const Duration(milliseconds: 100), () {
              Get.to(LoginScreen());
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            Toast.show(
              "Code Incorrect.\n ${resBody['message']}",
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
                height: 150,
                child: Image.asset(
                  "images/orange.jpg",
                ),
              ),

                const Text(
                  "+243",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Edition Mot de passe par défaut",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
                                      hintText: "Nouveau mot de passe...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
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
                                      hintText: "confirmer ...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
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

                                //button
                                Material(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(25),
                                  child: InkWell(
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        editerPwd(
                                          widget.utilisateur.idutilisateur
                                              .toString(),
                                        );
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
                                              "Modifier",
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
                              const Text(
                                "Retourner à l'acceuil ?",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(LoginScreen());
                                },
                                child: Text(
                                  "Se connecter",
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
