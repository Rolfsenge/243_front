import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/tools/color.dart';

import '../class/utilisateur.dart';

class RevenusiteUnique extends StatefulWidget {
  final Map<String, dynamic> site;
  final Color color;
  final Utilisateur utilisateur;
  final String groupe_m_usd;

  const RevenusiteUnique({
    super.key,
    required this.site,
    required this.color,
    required this.utilisateur,
    required this.groupe_m_usd,
  });

  @override
  State<RevenusiteUnique> createState() => _RevenusiteUniqueState();
}

class _RevenusiteUniqueState extends State<RevenusiteUnique> {
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = widget.site['statut_global'] ?? 'Inconnu';

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(widget.site['site_name'] ?? 'Détail du site'),
        centerTitle: true,
        backgroundColor: widget.color,
        foregroundColor: whiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧭 En-tête principale
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 30,
              color: whiteColor,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: widget.color,
                  child: const Icon(Icons.wifi, color: Colors.white),
                ),
                title: Text(
                  widget.site['site_name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(widget.site['site_key'] ?? ''),
                trailing: Chip(
                  label: Text(
                    statut,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: getStatusColor(statut),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🌍 Localisation
            buildSectionTitle("🌍 Localisation"),
            buildInfoCard([
              buildInfoItem(
                Icons.location_city,
                "Ville",
                widget.site['ville_administrative'],
              ),
              buildInfoItem(
                Icons.pin_drop,
                "Localité",
                widget.site['ville_localite'],
              ),
              buildInfoItem(Icons.map, "Territoire", widget.site['territoire']),
              buildInfoItem(
                Icons.public,
                "Région",
                widget.site['region_commerciale'],
              ),
              buildInfoItem(
                Icons.domain,
                "Zone commerciale",
                widget.site['zone_commerciale'],
              ),
              buildInfoItem(
                Icons.place,
                "Secteur",
                widget.site['secteur_commercial'],
              ),
            ]),

            const SizedBox(height: 12),

            // ⚙️ Informations techniques
            buildSectionTitle("⚙️ Informations techniques"),
            buildInfoCard([
              buildInfoItem(Icons.cell_tower, "Type", widget.site['type']),
              buildInfoItem(
                Icons.handshake,
                "Partenaire",
                widget.site['partenaire'],
              ),
              buildInfoItem(
                Icons.network_check,
                "Technologie",
                widget.site['techno'],
              ),
              buildInfoItem(
                Icons.cable,
                "Transmission",
                widget.site['type_transmission'],
              ),
              buildInfoItem(Icons.history, "Âge (jours)", widget.site['age']),
              buildInfoItem(
                Icons.category,
                "Catégorie",
                widget.site['categorie'],
              ),
              buildInfoItem(Icons.layers, "Batch", widget.site['batch']),
            ]),

            const SizedBox(height: 12),

            // 📊 Performances
            buildSectionTitle("📊 Performances récentes"),
            buildInfoCard([
              buildInfoItem(
                FontAwesomeIcons.phone,
                "First Call",
                widget.site['first_call'],
              ),
              buildInfoItem(
                FontAwesomeIcons.signal,
                "Qualité First Call",
                widget.site['first_call_quali'],
              ),
              buildInfoItem(
                FontAwesomeIcons.user,
                "Parc CICO 30j",
                widget.site['parc_cico_30d'],
              ),
              buildInfoItem(
                FontAwesomeIcons.userCheck,
                "Parc RLMS 30j",
                widget.site['parc_rlms_30d'],
              ),
              buildInfoItem(
                FontAwesomeIcons.userPlus,
                "Parc SA 30j",
                widget.site['parc_sa_30d'],
              ),
              buildInfoItem(
                FontAwesomeIcons.userClock,
                "Parc SSO 30j",
                widget.site['parc_sso_30d'],
              ),
              buildInfoItem(
                FontAwesomeIcons.userGroup,
                "Parc Zebra 30j",
                widget.site['parc_zebra_30d'],
              ),
            ]),

            const SizedBox(height: 12),

            // 💰 Groupe financier
            buildSectionTitle("💰 Groupe financier"),
            buildInfoCard([
              buildInfoItem(
                Icons.monetization_on,
                "Groupe M USD",
                widget.site['groupe_m_usd'],
              ),
              buildInfoItem(
                Icons.currency_exchange,
                "Groupe M CDF",
                widget.site['groupe_m_cdf'],
              ),
              buildInfoItem(
                Icons.trending_up,
                "Groupe M 1USD",
                widget.site['groupe_m_1usd'],
              ),
              buildInfoItem(
                Icons.trending_up,
                "Groupe M 1CDF",
                widget.site['groupe_m_1_cdf'],
              ),
            ]),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: widget.color,
        ),
      ),
    );
  }

  Widget buildInfoCard(List<Widget> items) {
    return Card(
      elevation: 10,
      color: whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: items),
    );
  }

  Widget buildInfoItem(IconData icon, String label, dynamic value) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value?.toString() ?? "-"),
      dense: true,
    );
  }
}
