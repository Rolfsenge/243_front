import 'package:latlong2/latlong.dart';

class SiteBts {
  final String nom;
  final LatLng position;
  final double distanceKm;

  SiteBts({
    required this.nom,
    required this.position,
    required this.distanceKm,
  });
}
