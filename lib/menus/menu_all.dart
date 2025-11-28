import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gtm/views/send_dcmdata.dart';
import '../views/creation_page_dso.dart';
import '../views/dcm_performamnce.dart';
import '/views/creation_page.dart';
import '/views/reset_kabu_page.dart';
import '/views/reset_zebra_page.dart';
import '/views/update_checker.dart';
import '/views/zebra_page.dart';
import '/views/rlms_remote.dart';
import '/class/utilisateur.dart';
import '/tools/color.dart';
import '/views/cico_lite.dart';
import '/views/televerser.dart';
import '../views/telecharger.dart';

class MenuAll extends StatelessWidget {
  final Utilisateur utilisateur;
  const MenuAll({super.key, required this.utilisateur});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'cico') {
          Get.to(() => CicoLite(utilisateur: utilisateur));
        } else if (value == 'telecharger') {
          Get.to(() => Telecharger(utilisateur: utilisateur));
        } else if (value == 'televerser') {
          Get.to(() => Televerser(utilisateur: utilisateur));
        }
        //send dcm data
        else if (value == 'send_dcm_data') {
          Get.to(() => SendDcmdata(utilisateur: utilisateur));
        } else if (value == 'rlms') {
          Get.to(() => RlmsRemote(utilisateur: utilisateur));
        } else if (value == 'creation') {
          Get.to(() => CreationPage(utilisateur: utilisateur));
        } else if (value == 'creation_dso') {
          Get.to(() => CreationPageDso(utilisateur: utilisateur));
        } else if (value == 'zebra') {
          Get.to(() => ZebraPage(utilisateur: utilisateur));
        } else if (value == 'resetzebra') {
          Get.to(() => ResetZebraPage(utilisateur: utilisateur));
        } else if (value == 'resetkaabu') {
          Get.to(() => ResetKabuPage(utilisateur: utilisateur));
        } else if (value == 'update') {
          Get.to(() => UpdateChecker());
        } else if (value == 'perofmance') {
          DcmPerformamnce(utilisateur: utilisateur);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          // --- Menu réservé au type structure 6 ---
          if (utilisateur.idtypestructure == 6) ...[
            PopupMenuItem<String>(
              value: 'plus',
              child: Row(
                children: const [
                  Icon(Icons.add_circle_outline, color: primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'SD FOCUS - CREATIONS',
                    style: TextStyle(color: primaryColor),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(thickness: 2, color: primaryColor),

            PopupMenuItem<String>(
              value: 'creation',
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Kaabu'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'zebra',
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Zebra'),
                ],
              ),
            ),

            PopupMenuItem<String>(
              value: 'resetzebra',
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Reset pin Zebra'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'resetkaabu',
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Reset pin Kaabu'),
                ],
              ),
            ),

            PopupMenuItem<String>(
              value: 'rlms',
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('RLMS 395'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'cico',
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('CICO Lite'),
                ],
              ),
            ),

            PopupMenuItem<String>(
              value: 'televerser',
              child: Row(
                children: const [
                  Icon(Icons.cloud_upload),
                  SizedBox(width: 8),
                  Text('Envoyer les données'),
                ],
              ),
            ),
          ],

          // --- Menu réservé au type structure 10 ---
          if (utilisateur.idcategorie == 10 ||
              utilisateur.idcategorie == 5) ...[
            PopupMenuItem<String>(
              value: 'plus',
              child: Row(
                children: const [
                  Icon(Icons.add_circle_outline, color: primaryColor),
                  SizedBox(width: 8),
                  Text('SD FOCUS', style: TextStyle(color: primaryColor)),
                ],
              ),
            ),
            const PopupMenuDivider(thickness: 2, color: primaryColor),

            PopupMenuItem<String>(
              value: 'creation_dso',
              child: Row(
                children: const [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Création FDV'),
                ],
              ),
            ),

            PopupMenuItem<String>(
              value: 'perofmance',
              child: Row(
                children: [
                  Icon(Icons.pie_chart),
                  SizedBox(width: 8),
                  Text('Votre performance'),
                ],
              ),
            ),
          ],

          // --- Paramètres généraux ---
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: const [
                Icon(Icons.settings, color: primaryColor),
                SizedBox(width: 8),
                Text('PARAMÈTRES', style: TextStyle(color: primaryColor)),
              ],
            ),
          ),

          const PopupMenuDivider(thickness: 2, color: primaryColor),

          PopupMenuItem<String>(
            value: 'resetpwd',
            child: Row(
              children: const [
                Icon(Icons.lock_reset),
                SizedBox(width: 8),
                Text('Changer mot de passe'),
              ],
            ),
          ),

          /*
          PopupMenuItem<String>(
            value: 'telecharger',
            child: Row(
              children: const [
                Icon(Icons.cloud_download),
                SizedBox(width: 8),
                Text('Charger les données'),
              ],
            ),
          ),
          */
          PopupMenuItem<String>(
            value: 'update',
            child: Row(
              children: const [
                Icon(Icons.system_update),
                SizedBox(width: 8),
                Text('Mises à jour'),
              ],
            ),
          ),
        ];
      },
    );
  }
}
