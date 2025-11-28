

import 'dart:convert';

import 'package:get/get.dart';
import '/menus/menu_all.dart';
import '/views/wallet_screen.dart';
import 'package:http/http.dart' as http;

import '../api_connection/api_connection.dart';
import '../bdd/dbhelper.dart';
import '../tools/circle_progress.dart';
import '../tools/color.dart';
import '/class/utilisateur.dart';
import 'package:flutter/material.dart';

class Telecharger extends StatefulWidget {
  final Utilisateur utilisateur;
  const Telecharger({super.key, required this.utilisateur});

  @override
  State<Telecharger> createState() => _TelechargerState();
}

class _TelechargerState extends State<Telecharger> {

  DatabaseHelper dbHelper = DatabaseHelper.instance;
  late int secteurs = 0;
  late int secteur_local = 0;
  late int secteurs_down = 0;
  
  String messageErreur = '';

  late bool isLoadSect = false;


  Future<void> getDataLocal() async {
    try {

      var nbreSecteur = await dbHelper.getNombreSecteur();


      setState(() {
        secteur_local = nbreSecteur;
      });

      getDownloadable();
    } catch (e) {
      setState(() {
        messageErreur="Erreur lors du chargement des données : $e";
      });
    }
  }

  Future<void> getDownloadable() async {
    setState(() {
      isLoadSect = true;
    });

    try {
      var res = await http.post(
        Uri.parse(API.getCount),
        body: {
          "idutilisateur": widget.utilisateur.idutilisateur.toString(),
          "idtypestructure": widget.utilisateur.idtypestructure.toString(),
          "idstructure": widget.utilisateur.idstructure.toString(),
        },
      );

      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);

        print(resBody);

        setState(() {
          secteurs_down = resBody["secteur"];

          int paie = secteurs_down - secteur_local;

          secteurs = (paie < 0) ? 0 : paie;

          isLoadSect = false;
        });
      } else {
        setState(() {
          isLoadSect = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Vous n'êtes pas connecté au serveur"),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: "Annuler",
              onPressed: () {
                // Action lors de l'annulation
              },
            ),
          ),
        );
      }
    } catch (errorMsg) {
      setState(() {
        isLoadSect = false;
      });
      // ignore: avoid_print
      print("Error :: $errorMsg");
    }
  }

@override
  void initState() {
  getDataLocal();
  getDownloadable();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Téléchargement"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.off(() => WalletScreen(utilisateur: widget.utilisateur));
          },
        ),
        actions: [
          MenuAll(utilisateur: widget.utilisateur
          )],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: whiteColor, // Couleur de la bordure
                      width: 1.0, // Épaisseur de la bordure
                    ),
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // Arrondi des coins
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$secteurs Secteurs",
                            style: TextStyle(color: whiteColor, fontSize: 20),
                          ),
                          const SizedBox(width: 20),
                          (isLoadSect)
                              ? Circle()
                              : IconButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                primaryColor,
                              ),
                            ),
                            onPressed: () {

                              telSecteur(
                                widget.utilisateur.idutilisateur.toString(),
                                widget.utilisateur.idtypestructure.toString(),
                                widget.utilisateur.idstructure.toString()
                              );


                            },
                            icon: Icon(Icons.download, color: whiteColor),
                          ),
                        ],
                      ),
                     // Text("${widget.utilisateur.nomtypestructure} : ${widget.utilisateur.nomstructure} ", style: TextStyle(color: primaryColor),)
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

   telSecteur(String idutilisateur, String idtypestructure, String idstructure) async {
     setState(() {
       isLoadSect= true;
     });

     /*
     final data = await CotService.fetchPaiements();

     for (Cotisation c in data) {
       try {
         // Vérifier si le ménage existe déjà dans la base de données locale
         int existingSecteur = await dbHelper.getExistingSecteur();

         print("Token ${c.tokencotisation} et Paiement : $existingPaiement");

         if (existingPaiement == 0) {
           await dbHelper.insertSecteur({
             'tokencotisation': c.tokencotisation,
             'cotisation_date': c.cotisation_date,
             'cotisation_montant': c.cotisation_montant,
             'cotisation_idbouquet': c.cotisation_idbouquet,
             'cotisation_idsoussection': c.cotisation_idsoussection,
             'cotisation_iddevise': c.cotisation_iddevise,
             'cotisation_idmodepaiement': c.cotisation_idmodepaiement,
             'cotisation_codemenage': c.cotisation_codemenage,
           });

           setState(() {
             if (secteurs == 0) {
               secteurs = 0;
             } else {
               secteurs--;
             }
           });
           // Mettre à jour le ménage existant
         } else {
           print('Cotisation  existant trouvé avec ID: $existingPaiement');
         }
       } catch (e) {
         print(
           "Erreur lors du traitement du ménage ID ${c.tokencotisation}: $e",
         );
         // Tu peux logguer ou enregistrer l'erreur localement si besoin
       }
     }

     setState(() {
       isLoadSect = false;
     });
     *
      */
   }
}
