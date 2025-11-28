class Zebra {
  int? idzebra;
  final String zebra_idutilisateur;
  final String user_msisdn;
  final String user_name;
  final String geography;
  final String category;
  final String status;
  final String plaint;
  final String parent_msisdn;
  final String email;

  Zebra({
    required this.zebra_idutilisateur,
    required this.user_msisdn,
    required this.user_name,
    required this.geography,
    required this.category,
    required this.status,
    required this.plaint,
    required this.parent_msisdn,
    required this.email,
  });

  // ✅ Conversion Map -> Objet
  factory Zebra.fromMap(Map<String, dynamic> map) {
    return Zebra(
      zebra_idutilisateur: map['zebra_idutilisateur'],
      user_msisdn: map['user_msisdn'],
      user_name: map['user_name'],
      geography: map['geography'],
      category: map['category'],
      status: map['status'],
      plaint: map['plaint'],
      parent_msisdn: map['parent_msisdn'],
      email: map['email'],
    );
  }
  // ✅ Conversion Objet -> Map (pour insertion SQLite)
  Map<String, dynamic> toMap() {
    return {
      'zebra_idutilisateur': zebra_idutilisateur,
      'user_msisdn': user_msisdn,
      'user_name': user_name,
      'geography': geography,
      'category': category,
      'status': status,
      'plaint': plaint,
      'parent_msisdn': parent_msisdn,
      'email': email,
    };
  }
}
