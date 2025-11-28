
class ResetZebra{

  int? idresetzebra;
  final String resetzebra_idutilisateur;
  final String numero;
  final String solde;

  ResetZebra(
  {

  required this.resetzebra_idutilisateur,
  required this.numero,
  required this.solde,
} );

// ✅ Conversion Map -> Objet
factory ResetZebra.fromMap(Map<String, dynamic> map) {
  return ResetZebra(

    resetzebra_idutilisateur: map['resetzebra_idutilisateur'],
    numero: map['numero'],
    solde: map['solde'],

);}

// ✅ Conversion Objet -> Map (pour insertion SQLite)
Map<String, dynamic> toMap() {
  return {
    'idresetzebra': idresetzebra,
    'resetzebra_idutilisateur': resetzebra_idutilisateur,
    'numero': numero,
    'solde': solde,
  };
}

}
