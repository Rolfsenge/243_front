import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'authentication/login_screen.dart';
import 'bdd/dbhelper.dart';
import 'class/utilisateur.dart';
import 'tools/color.dart';
import 'views/home.dart';
import 'views/wallet_screen.dart';

void main() async {
  runApp(const MyApp());
}

//895434716
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  Future<Utilisateur?> connected() async {
    try {
      DatabaseHelper helper = DatabaseHelper.instance;
      Utilisateur? data = await helper.getUser();
      return data;
    } catch (e, stacktrace) {
      // ignore: avoid_print
      print("Erreur dans connected(): $e");
      // ignore: avoid_print
      print(stacktrace);
      return null;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('fr'),
      supportedLocales: const [
        Locale('fr'), // ou [Locale('fr', 'FR')] selon ton besoin
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Performances Orange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: FutureBuilder(
        future: connected(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: whiteColor,
              body: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            );
            // Afficher un indicateur de chargement en attendant les données
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}'); // Gérer les erreurs
          } else {
            if ((snapshot.data != null)) {
              return WalletScreen(utilisateur: snapshot.data!);
            } else {
              return LoginScreen();
            }
            //Text('Données récupérées: ${snapshot.data}'); // Afficher les données récupérées
          }
        },
      ),
    );
  }
}
