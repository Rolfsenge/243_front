class Creation{


  int? idcreation;
  final String creation_idutilisateur;
  final String infra_category;
  final String agent_phone;
  final String nom;
  final String postnom;
  final String prenom;
  final String infra_phone;
  final String login_infra;
  final String photoID;
  final String plaint;
  final String status;
  final String observation;

  Creation({
    required this.idcreation,
    required this.creation_idutilisateur,
    required this.infra_category,
    required this.agent_phone,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.infra_phone,
    required this.login_infra,
    required this.photoID,
    required this.plaint,
    required this.status,
    required this.observation,

});

  factory Creation.fromMap(Map<String, dynamic> map)
  {
    return Creation(
      idcreation: map['idcreation'],
      creation_idutilisateur: map['creation_idutilisateur'],
      infra_category: map['infra_category'],
      agent_phone: map['agent_phone'],
      nom: map['nom'],
      postnom: map['postnom'],
      prenom: map['prenom'],
      infra_phone: map['infra_phone'],
      login_infra: map['login_infra'],
      photoID: map['photoID'],
      plaint: map['plaint'],
      status: map['status'],
      observation: map['observation'],

    );
  }

  Map<String, dynamic> toMap()
  {
    return {
      'idcreation': idcreation,
      'creation_idutilisateur': creation_idutilisateur,
      'infra_category': infra_category,
      'agent_phone': agent_phone,
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'infra_phone': infra_phone,
      'login_infra': login_infra,
      'photoID': photoID,
      'plaint': plaint,
      'status': status,
      'observation': observation,

    };
  }



}