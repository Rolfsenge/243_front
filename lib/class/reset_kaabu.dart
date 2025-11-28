
class ResetKaabu{

  int? idresetkaabu;
  final String resetkaabu_idutilisateur;
  final String numero;
  final String login;

  ResetKaabu(
      {
        required this.idresetkaabu,
        required this.resetkaabu_idutilisateur,
        required this.numero,
        required this.login,
      } );

// ✅ Conversion Map -> Objet
  factory ResetKaabu.fromMap(Map<String, dynamic> map) {
    return ResetKaabu(
      idresetkaabu: map['idresetkaabu'],
      resetkaabu_idutilisateur: map['resetkaabu_idutilisateur'],
      numero: map['numero'],
      login: map['login'],

    );}

// ✅ Conversion Objet -> Map (pour insertion SQLite)
  Map<String, dynamic> toMap() {
    return {
      'idresetkaabu': idresetkaabu,
      'resetkaabu_idutilisateur': resetkaabu_idutilisateur,
      'numero': numero,
      'login': login,
    };
  }

}
