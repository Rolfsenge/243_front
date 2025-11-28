import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gtm/api_connection/api_connection.dart';
import 'package:gtm/tools/color.dart';
import '../class/utilisateur.dart';

class HomeDcmData extends StatefulWidget {
  final Utilisateur utilisateur;
  const HomeDcmData({super.key, required this.utilisateur});

  @override
  State<HomeDcmData> createState() => _HomeDcmDataState();
}

class _HomeDcmDataState extends State<HomeDcmData> {
  List<dynamic>? data;
  bool isLoading = true;
  String? errorMessage;
  int totalMarchands = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // 🔹 Récupération réelle depuis l'API
  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse(API.getMarchandUser),
        body: {
          'idcategorie': widget.utilisateur.idcategorie.toString(),
          'phone_dcm': widget.utilisateur.telephone,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse['dataresult'] != null) {
          setState(() {
            data = jsonResponse['dataresult'];
            totalMarchands = data!.fold(
              0,
              (sum, item) => sum + (item['marchand'] ?? 0) as int,
            );
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Aucune donnée disponible.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Erreur serveur : ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur de connexion : $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (data == null || data!.isEmpty) {
      return const Center(
        child: Text(
          "Aucune donnée disponible",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======== EN-TÊTE RÉSUMÉ ========
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: darcula,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Activités totales",
                        style: TextStyle(fontSize: 15, color: primaryColor),
                      ),
                      Text(
                        "${data!.length}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Marchands totaux",
                        style: TextStyle(fontSize: 15, color: whiteColor),
                      ),
                      Text(
                        "$totalMarchands",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ======== GRILLE DES ACTIVITÉS ========
            GridView.builder(
              shrinkWrap: true, // ✅ empêche la hauteur infinie
              physics:
                  const NeverScrollableScrollPhysics(), // ✅ évite conflit scroll
              padding: const EdgeInsets.all(4),
              itemCount: data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final item = data![index];
                final int nbMarchands = item['marchand'] ?? 0;
                final bool hasMarchands = nbMarchands > 0;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: hasMarchands
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasMarchands
                              ? Icons.store_mall_directory
                              : Icons.store_outlined,
                          size: 40,
                          color: hasMarchands ? primaryColor : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['nomactivite'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: hasMarchands ? Colors.black : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Marchands : $nbMarchands",
                          style: TextStyle(
                            color: hasMarchands
                                ? primaryColor
                                : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
