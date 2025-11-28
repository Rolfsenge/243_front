import 'dart:math';

import 'package:flutter/material.dart';
import '/tools/color.dart';

class TermsCondition extends StatefulWidget {
  const TermsCondition({super.key});

  @override
  State<TermsCondition> createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Titre
              Text(
                "Conditions d'utilisation",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 12,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(thickness: sqrt1_2, height: 20, color: primaryColor),
              Text(
                "En utilisant cette application, vous acceptez les conditions suivantes :\n\n"
                "1. Confidentialité : Vos données personnelles seront traitées conformément à notre politique de confidentialité.\n\n"
                "2. Sécurité : Vous êtes responsable de la sécurité de votre compte et de vos informations de connexion.\n\n"
                "3. Utilisation acceptable : Vous vous engagez à utiliser l'application de manière légale et éthique.\n\n"
                "4. Limitation de responsabilité : Nous ne serons pas responsables des dommages résultant de l'utilisation de l'application.\n\n"
                "5. Modifications : Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications seront publiées dans l'application.\n\n"
                "6. Résiliation : Nous nous réservons le droit de suspendre ou de résilier votre accès à l'application en cas de violation de ces conditions.\n\n"
                "7. Droit applicable : Ces conditions sont régies par les lois en vigueur en RD Congo.\n\n"
                "8. Votre compte est lié à un appareil mobile, donc vous devez vous assurer que votre appareil est sécurisé par ce que la session est unique.\n\n"
                "9. Si vous changez d'appareil, vous devez nous contacter pour réinitialiser votre compte.\n\n"
                "10. Contact : Pour toute question concernant ces conditions, veuillez nous contacter à support@example.com",

                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
