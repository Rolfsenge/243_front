class RlmsClass{
  int? idrlms;
  String rlms_idutilisateur;
  String numero;

    RlmsClass({
      this.idrlms,
      required this.rlms_idutilisateur,
      required this.numero
  });

    factory RlmsClass.fromMap(Map<String, dynamic> map) {
      return RlmsClass(
          rlms_idutilisateur:  map['rlms_idutilisateur'],
          numero: map['numero']);
    }

    // ✅ Conversion Objet -> Map (pour insertion SQLite)
    Map<String, dynamic> toMap(){
          return {
            'rlms_idutilisateur': rlms_idutilisateur,
            'numero': numero,
          };
    }
}