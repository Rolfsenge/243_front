import 'dart:math';

class Code {
  String creerCode(int length) {
    Random random = Random();
    String code = '';
    for (int i = 0; i < length; i++) {
      int randomNumber = random.nextInt(26) +
          65; // Génère un nombre aléatoire entre 65 et 90 (codes ASCII pour les lettres majuscules)
      code += String.fromCharCode(randomNumber);
    }
    return code;
  }
}
