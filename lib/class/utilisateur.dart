class Utilisateur {
  final int idutilisateur;
  final String nomutilisateur;
  final int idcategorie;
  final int idtypestructure;
  final int idstructure;
  final String nomcategorie;
  final String nomtypestructure;
  final String nomstructure;
  final String telephone;
  final int activation;

  Utilisateur({
    required this.idutilisateur,
    required this.nomutilisateur,
    required this.idcategorie,
    required this.idstructure,
    required this.idtypestructure,
    required this.nomtypestructure,
    required this.nomstructure,
    required this.nomcategorie,
    required this.telephone,
    required this.activation,
  });
}
