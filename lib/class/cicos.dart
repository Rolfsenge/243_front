class Cicos {
  int? idcicos;
  String msisdn;
  String nom;
  String postnom;
  String prenom;
  String? carteId;
  String? numParent;
  int userId;
  int isExported;
  String? createdAt;
  String? updatedAt;
  String? adresse;
  String? sexe;
  String? nationalite;
  String? numeroId;
  String? lieuNaissance;
  String? dateNaissance;
  String? typeCarteId;
  String sync;

  Cicos({
    this.idcicos,
    required this.msisdn,
    required this.nom,
    required this.postnom,
    required this.prenom,
    this.carteId,
    this.numParent,
    required this.userId,
    this.isExported = 0,
    this.createdAt,
    this.updatedAt,
    this.adresse,
    this.sexe,
    this.nationalite,
    this.numeroId,
    this.lieuNaissance,
    this.dateNaissance,
    this.typeCarteId,
    this.sync = "NON",
  });

  // ✅ Conversion Map -> Objet
  factory Cicos.fromMap(Map<String, dynamic> map) {
    return Cicos(
      idcicos: map['idcicos'],
      msisdn: map['msisdn'],
      nom: map['nom'],
      postnom: map['postnom'],
      prenom: map['prenom'],
      carteId: map['carte_id'],
      numParent: map['num_parent'],
      userId: map['user_id'],
      isExported: map['is_exported'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      adresse: map['adresse'],
      sexe: map['sexe'],
      nationalite: map['nationalite'],
      numeroId: map['numero_id'],
      lieuNaissance: map['lieu_naissance'],
      dateNaissance: map['date_naissance'],
      typeCarteId: map['type_carte_id'],
      sync: map['sync'] ?? "NON",
    );
  }

  // ✅ Conversion Objet -> Map (pour insertion SQLite)
  Map<String, dynamic> toMap() {
    return {
      'idcicos': idcicos,
      'msisdn': msisdn,
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'carte_id': carteId,
      'num_parent': numParent,
      'user_id': userId,
      'is_exported': isExported,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'adresse': adresse,
      'sexe': sexe,
      'nationalite': nationalite,
      'numero_id': numeroId,
      'lieu_naissance': lieuNaissance,
      'date_naissance': dateNaissance,
      'type_carte_id': typeCarteId,
      'sync': sync,
    };
  }
}
