import 'package:flutter/material.dart';

import '../class/utilisateur.dart';

class PerformancePdvRegion extends StatefulWidget {
  final Utilisateur utilisateur;
  final String statut_pdv;
  final Color color;
  final String total;
  final String region;

  const PerformancePdvRegion({
    super.key,
    required this.utilisateur,
    required this.statut_pdv,
    required this.color,
    required this.total,
    required this.region,
  });

  @override
  State<PerformancePdvRegion> createState() => _PerformancePdvRegionState();
}

class _PerformancePdvRegionState extends State<PerformancePdvRegion> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
