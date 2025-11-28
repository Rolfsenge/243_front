import 'dart:convert';
import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gtm/authentication/contacter.dart';
import '/authentication/delier_device.dart';
import '../class/utilisateur.dart';
import '/tools/color.dart';
import '../../api_connection/api_connection.dart';
import '../../authentication/forgot.dart';
import '../../bdd/dbhelper.dart';
import '../../tools/circle_progress.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../views/wallet_screen.dart';
import 'default.dart';
import 'terms_condition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var isObsecure = true.obs;
  bool _isLoading = false;
  int identifiant = 0;

  DatabaseHelper helper = DatabaseHelper.instance;

  String? completePhone; // pour stocker le numéro complet
  String marque = '';
  String modele = '';
  String name = '';
  String? numeroSerie = '';

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  Future<void> getDeviceInfo() async {
    // Vous pouvez utiliser le package device_info_plus pour obtenir des informations sur l'appareil
    // Ajoutez device_info_plus à votre pubspec.yaml
    // import 'package:device_info_plus/device_info_plus.dart';
    // Voici un exemple simple :
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        var info = await deviceInfo.androidInfo;
        setState(() {
          marque = info.brand;
          modele = info.model;
          name = info.name;
          // numeroSerie = info.id; // Utilisation de l'ID comme numéro de série
        });
      } else if (Platform.isIOS) {
        var info = await deviceInfo.iosInfo;
        setState(() {
          marque = 'Apple';
          modele = info.utsname.machine;
          // numeroSerie = info.identifierForVendor;
        });
      }
    } catch (e) {
      debugPrint("Erreur device info: $e");
      setState(() {
        marque = 'Inconnue';
        modele = 'Inconnu';
        numeroSerie = 'Non disponible';
      });
    }
  }

  Future<void> loginUserNow() async {
    String telephone = phoneController.text.trim();
    String motdepasse = passwordController.text.trim();

    try {
      setState(() {
        _isLoading = true;
      });

      var res = await http.post(
        Uri.parse(API.login),
        body: {
          "telephone": completePhone,
          "motdepasse": motdepasse,
          "marque": marque,
          "modele": modele,
          "device_name": name,
          "numero_serie": '',
        },
      );

      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);
        if (resBody['success'] == true) {
          List<dynamic> datas = resBody['userData'];

          datas.forEach((data1) async {
            int idutilisateur = data1['idutilisateur'];
            String nomutilisateur = data1['nomutilisateur'];
            String nomcategorie = data1['nomcategorie'];
            int iddcategorie = data1['idcategorie'];
            String phone = data1['telephone'];
            String nomstructure = data1['nomstructure'];
            String nomtypestructure = data1['nomtypestructure'];
            int idstructure = data1['idstructure'];
            int idtypestructure = data1['idtypestructure'];

            // Creation de la classe utilisateur
            Utilisateur newutilisateur = Utilisateur(
              idutilisateur: idutilisateur,
              nomutilisateur: nomutilisateur,
              nomcategorie: nomcategorie,
              idcategorie: iddcategorie,
              telephone: phone,
              activation: 1,
              idstructure: idstructure,
              idtypestructure: idtypestructure,
              nomtypestructure: nomtypestructure,
              nomstructure: nomstructure,
            );

            if (motdepasse == "1234") {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => Default(utilisateur: newutilisateur),
                ),
                (Route<dynamic> route) => false,
              );
            } else {
              await helper.viderUtilisateur();

              await helper.insertion({
                "idutilisateur": idutilisateur,
                "nomutilisateur": nomutilisateur,
                "nomcategorie": nomcategorie,
                "idcategorie": iddcategorie,
                "idstructure": idstructure,
                "idtypestructure": idtypestructure,
                "nomtypestructure": nomtypestructure,
                "nomstructure": nomstructure,
                "telephone": phone,
                "activation": "1",
              }, "utilisateur");

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) =>
                      WalletScreen(utilisateur: newutilisateur),
                ),
                (Route<dynamic> route) => false,
              );
            }
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          Toast.show(
            "${resBody['titre']}.\n ${resBody['message']}.",
            duration: Toast.lengthLong,
            gravity: Toast.center,
            backgroundColor: Colors.red,
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
      backgroundColor: whiteColor,
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
                      child: Image.asset("images/orange.jpg"),
                    ),

                    const Text(
                      "+243",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    /*
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
                        "CONNEXION",
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

                                //dont have an account button - button
                                //dont have an account button - button
                                const SizedBox(height: 20),

                                //button
                                Material(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(25),
                                  child: InkWell(
                                    onTap: () {
                                      if (formKey.currentState!.validate()) {
                                        loginUserNow();
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
                                              "Se Connecter",
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
                        ],
                      ),
                    ),

                    /// ✅ SECTION FIXÉE EN BAS
                    Container(
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "En vous connectant, vous acceptez nos conditions d’utilisation "
                            "et votre compte sera lié à cet appareil : $marque - $name.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: darcula,
                              fontSize: 10,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              // future page "Conditions d’utilisation"
                              ////// Get.to(() => const TermsCondition());
                            },
                            child: const Text(
                              "Lire les conditions d’utilisation",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          /*
                          const Divider(color: primaryColor),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Voulez-vous délier votre compte \n à votre ancien appareil ? ",
                                style: TextStyle(color: darcula, fontSize: 10),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(() => Contacter());
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: blackColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "Nous contacter",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          */
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
