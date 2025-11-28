import '/class/cicos.dart';
import '/class/creation.dart';
import '/class/reset_kaabu.dart';
import '/class/reset_zebra.dart';
import '/class/rlms_class.dart';
import '/class/zebra.dart';

import '../class/utilisateur.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "station.db";
  static const _databaseVersion = 1;

  // This is a singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE utilisateur (
        idutilisateur INTEGER PRIMARY KEY AUTOINCREMENT,
        nomutilisateur TEXT,
        telephone TEXT,
        idcategorie INTEGER,
        nomcategorie TEXT,
        nomstructure TEXT,
        nomtypestructure TEXT,
        idtypestructure INTEGER,
        idstructure INTEGER,
        activation INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE cicos (
                         idcicos INTEGER PRIMARY KEY AUTOINCREMENT,
                         msisdn TEXT NOT NULL,
                         nom TEXT NOT NULL,
                         postnom TEXT NOT NULL,
                         prenom TEXT NOT NULL,
                         carte_id TEXT DEFAULT NULL,
                         num_parent TEXT DEFAULT NULL,
                         user_id INTEGER  NOT NULL,
                         is_exported INTEGER NOT NULL DEFAULT 0,
                         created_at TEXT NULL DEFAULT NULL,
                         updated_at TEXT NULL DEFAULT NULL,
                         adresse TEXT DEFAULT NULL,
                         sexe TEXT DEFAULT NULL,
                         nationalite TEXT DEFAULT NULL,
                         numero_id TEXT DEFAULT NULL,
                         lieu_naissance TEXT DEFAULT NULL,
                         date_naissance TEXT DEFAULT NULL,
                         type_carte_id TEXT DEFAULT NULL,
                         sync TEXT DEFAULT 'NON'
)
    ''');

    await db.execute('''
        CREATE TABLE secteur (
          idsecteur INTEGER PRIMARY KEY AUTOINCREMENT,
          nomsecteur TEXT NOT NULL
        )
    ''');

    await db.execute('''
        CREATE TABLE rlms (
          idrlms INTEGER PRIMARY KEY AUTOINCREMENT,
          rlms_idutilisateur INTEGER NOT NULL,
          numero TEXT NOT NULL
        )
    ''');

    await db.execute('''
        CREATE TABLE resetkaabu (
          idresetkaabu INTEGER PRIMARY KEY AUTOINCREMENT,
          resetkaabu_idutilisateur INTEGER NOT NULL,
          numero TEXT NOT NULL,
          login TEXT NOT NULL
        )
    ''');

    await db.execute('''
        CREATE TABLE resetzebra (
          idresetzebra INTEGER PRIMARY KEY AUTOINCREMENT,
          resetzebra_idutilisateur INTEGER NOT NULL,
          numero TEXT NOT NULL,
          solde TEXT NOT NULL
        )
    ''');

    await db.execute('''
        CREATE TABLE zebra (
          idzebra INTEGER PRIMARY KEY AUTOINCREMENT,
          zebra_idutilisateur INTEGER NOT NULL,
          numero TEXT NOT NULL,
          user_msisdn TEXT NOT NULL,
          user_name TEXT NOT NULL,
          geography TEXT NOT NULL,
          category TEXT NOT NULL,
          status TEXT NOT NULL,
          plaint TEXT NOT NULL,
          parent_msisdn TEXT NOT NULL,
          email TEXT NOT NULL
        )
    ''');

    await db.execute('''
        CREATE TABLE creation (
          idcreation INTEGER PRIMARY KEY AUTOINCREMENT,
          creation_idutilisateur INTEGER NOT NULL,
          infra_category TEXT NOT NULL,
          agent_phone TEXT NOT NULL,
          nom TEXT NOT NULL,
          postnom TEXT NOT NULL,
          prenom TEXT NOT NULL,
          infra_phone TEXT NOT NULL,
          login_infra TEXT,
          photoID TEXT NOT NULL,
          plaint TEXT,
          status TEXT,
          observation TEXT
        )
    ''');
  }

  Future<int> insertutilisateur(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('utilisateur', row);
  }

  Future<int> inserer(Map<String, dynamic> row, String tableName) async {
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }

  Future<void> vider(String tableName) async {
    Database db = await instance.database;
    await db.rawDelete('DELETE FROM $tableName');
    await db.rawDelete('DELETE FROM sqlite_sequence WHERE name="$tableName"');
  }

  Future<int> insertFlexpaie(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('flexpaie', row);
  }

  // VIder une table
  Future<void> disconnectAll() async {
    Database db = await instance.database;
    await db.rawUpdate("DELETE FROM utilisateur  WHERE idutilisateur != 0");
  }

  // VIder une table
  Future<void> deleteAll(String tableName, String identifiant) async {
    Database db = await instance.database;
    await db.rawUpdate("DELETE FROM $tableName WHERE $identifiant != 0");
  }

  // VIder une table
  Future<void> deletePaiement(int idflexpaie) async {
    Database db = await instance.database;
    await db.rawUpdate("DELETE FROM flexpaie WHERE idflexpaie = $idflexpaie");
  }

  Future<void> deleteUsers(String tableName, String identifiant) async {
    Database db = await instance.database;
    await db.rawUpdate("DELETE FROM $tableName WHERE $identifiant != 1");
  }

  /// Pour compter le nombre de lignes dans une table d'une base
  /// de données SQLite sur Flutter, vous pouvez utiliser la méthode
  /// query fournie par la bibliothèque sqflite. Cette méthode vous
  /// permet d'exécuter une requête SQL SELECT
  /// pour récupérer des données de la base de données.

  Future<int?> countRows(String tableName) async {
    Database db = await instance.database;
    int? count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
    return count;
  }

  // Obtenir une rubrique dans une table
  Future<String?> getLine(
    String tableName,
    String rubrique,
    String whereRubrique,
    String whereValue,
  ) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: [rubrique],
      where: '$whereRubrique = ?',
      whereArgs: [whereValue],
    );
    if (result.isNotEmpty) {
      return result.first[rubrique].toString();
    }
    return null;
  }

  Future<int?> counTableLines(String tableName) async {
    Database db = await instance.database;
    int? count = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM $tableName"),
    );
    return count;
  }

  //Connection utilisateur
  Future<void> updateUser(String login, String motdepasse) async {
    Database db = await instance.database;
    Sqflite.firstIntValue(
      await db.rawQuery(
        "UPDATE utilisateur SET activation = 1 WHERE login = '$login' AND motdepasse = '$motdepasse'",
      ),
    );
  }

  Future<int?> getIdconnected() async {
    Database db = await instance.database;
    int? count = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT idutilisateur FROM utilisateur WHERE activation = 1",
      ),
    );
    return count;
  }

  Future<int?> checkSession() async {
    Database db = await instance.database;
    int? count = Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(*) FROM utilisateur WHERE activation = 1",
      ),
    );
    return count;
  }

  Future<List<Map<String, dynamic>>?> getDbUser() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> records = await db.rawQuery(
      'SELECT * FROM utilisateur WHERE activation = 1',
    );
    if (records.isNotEmpty) {
      return records;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getFlexCheck() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> records = await db.rawQuery(
      'SELECT * FROM flexpaie WHERE flexpaie_code = 15',
    );
    if (records.isNotEmpty) {
      return records;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserSession() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'utlisateur',
      where: 'activation = ?',
      whereArgs: [1],
      limit: 1,
    ); // Utilisez la clause WHERE pour filtrer par ID
    return result.first;
  }

  // ===================== Insertion ===============================
  Future<int> insertion(Map<String, dynamic> row, String tableName) async {
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }

  // le poste de l'équipement
  Future<int?> getIdConnected() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT idutilisateur FROM utilisateur WHERE idequipement = 1",
      ),
    );
    // return idposte;
  }

  Future<String?> getColumnValue(int id, String columnName) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'poste',
      columns: [columnName],
      where: 'idposte = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first[columnName].toString();
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUniteRow(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> rows = await db.query(
      'unite', // Nom de la table
      where: 'idunite = ?', // Clause WHERE pour filtrer la ligne par ID
      whereArgs: [id], // Valeur de l'ID à filtrer
    );
    if (rows.isNotEmpty) {
      return rows.first; // Retourne la première ligne trouvée
    } else {
      return null; // Aucune ligne trouvée
    }
  }

  Future<String?> getValueRubrique(
    String tableName,
    String rubrique,
    String key,
    String keyValue,
  ) async {
    Database db = await instance.database;
    // Exécuter une requête rawQuery
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT $rubrique FROM $tableName WHERE $key = ?',
      [keyValue],
    );

    // Vérifier si le résultat contient des données
    if (result.isNotEmpty) {
      // Renvoyer la valeur extraite de la requête
      return result.first[rubrique];
    } else {
      // Renvoyer une valeur par défaut si aucune donnée n'est trouvée
      return 'Aucun nom trouvé';
    }
  }

  // le poste de l'équipement
  Future<int?> getLastIdSyncup() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      'SELECT MAX(idsyncup) as last_id FROM syncup',
    );

    if (rows.isNotEmpty && rows.first['last_id'] != null) {
      return rows.first['last_id'];
    } else {
      return 0;
    }
  }

  // le poste de l'équipement
  Future<double?> getTotalTable(
    String tableName,
    String rubrique,
    String devise,
  ) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      "SELECT SUM($rubrique) as total FROM $tableName WHERE devise='$devise'",
    );

    if (rows.isNotEmpty && rows.first['total'] != null) {
      return rows.first['total'];
    } else {
      return 0;
    }
  }

  Future<void> syncupQuery(String requette) async {
    Database db = await instance.database;
    Sqflite.firstIntValue(await db.rawQuery(requette));
  }

  // Insérer des données dans la table
  Future<void> insertSyncDown(String query) async {
    Database db = await database;

    // Insérer des données dans la table
    await db.insert('syncdown', {
      'requette': query,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Utilisateur?> getUser() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'utilisateur',
      where: 'activation = ?',
      whereArgs: ['1'],
      limit: 1, // Ajout d'une limite pour ne récupérer qu'une seule ligne
    );

    if (maps.isNotEmpty) {
      return Utilisateur(
        idutilisateur: maps.first['idutilisateur'] ?? 0,
        nomutilisateur: maps.first['nomutilisateur'] ?? "Nom inconnu",
        idcategorie: maps.first['idcategorie'] ?? 0,
        nomcategorie: maps.first['nomcategorie'] ?? "",
        nomstructure: maps.first['nomstructure'] ?? "",
        nomtypestructure: maps.first['nomtypestructure'] ?? "",
        telephone: maps.first['telephone'] ?? "",
        idstructure: maps.first['idstructure'] ?? 0,
        idtypestructure: maps.first['idtypestructure'] ?? 0,
        activation: 1,
      );
    }
    return null;
  }

  Future<void> viderUtilisateur() async {
    Database db = await instance.database;
    await db.rawUpdate("DELETE FROM utilisateur WHERE idutilisateur > 1");
  }

  Future<int> getNbCicoNotSync() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      "SELECT COUNT(*) as nombre FROM cicos WHERE sync='NON'",
    );

    if (rows.isNotEmpty && rows.first['nombre'] != null) {
      return rows.first['nombre'];
    } else {
      return 0;
    }
  }

  Future<List<Cicos>> getCicoNotSync() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cicos',
      // where: 'sync = ?',
      // whereArgs: ['NON'],
    );

    return List.generate(maps.length, (i) {
      return Cicos(
        idcicos: maps[i]['idcicos'],
        msisdn: maps[i]['msisdn'],
        nom: maps[i]['nom'],
        postnom: maps[i]['postnom'],
        prenom: maps[i]['prenom'],
        carteId: maps[i]['carte_id'],
        numParent: maps[i]['num_parent'],
        userId: maps[i]['user_id'],
        isExported: maps[i]['is_exported'],
        createdAt: maps[i]['created_at'],
        updatedAt: maps[i]['updated_at'],
        adresse: maps[i]['adresse'],
        sexe: maps[i]['sexe'],
        nationalite: maps[i]['nationalite'],
        numeroId: maps[i]['numero_id'],
        lieuNaissance: maps[i]['lieu_naissance'],
        dateNaissance: maps[i]['date_naissance'],
        typeCarteId: maps[i]['type_carte_id'],
        sync: maps[i]['sync'],
      );
    });
  }

  // Element envoyé vers le serveur
  Future<void> sentItem(String tableName, String id, String idValue) async {
    Database db = await instance.database;

    await db.rawUpdate("DELETE FROM  $tableName  WHERE $id = '$idValue'");
  }

  Future<int> getNombreSecteur() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      "SELECT COUNT(*) as nombre FROM secteur",
    );

    if (rows.isNotEmpty && rows.first['nombre'] != null) {
      return rows.first['nombre'];
    } else {
      return 0;
    }
  }

  Future<int> getNbKaabu() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      "SELECT COUNT(*) as nombre FROM creation",
    );

    if (rows.isNotEmpty && rows.first['nombre'] != null) {
      return rows.first['nombre'];
    } else {
      return 0;
    }
  }

  Future<int> getNbZebra() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      "SELECT COUNT(*) as nombre FROM zebra",
    );

    if (rows.isNotEmpty && rows.first['nombre'] != null) {
      return rows.first['nombre'];
    } else {
      return 0;
    }
  }

  Future<int> getNbRlms() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      "SELECT COUNT(*) as nombre FROM rlms",
    );

    if (rows.isNotEmpty && rows.first['nombre'] != null) {
      return rows.first['nombre'];
    } else {
      return 0;
    }
  }

  Future<int> getNbResetKaabu() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      "SELECT COUNT(*) as nombre FROM resetkaabu",
    );

    if (rows.isNotEmpty && rows.first['nombre'] != null) {
      return rows.first['nombre'];
    } else {
      return 0;
    }
  }

  Future<int> getNbResetZebra() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.rawQuery(
      "SELECT COUNT(*) as nombre FROM resetzebra",
    );

    if (rows.isNotEmpty && rows.first['nombre'] != null) {
      return rows.first['nombre'];
    } else {
      return 0;
    }
  }

  Future<void> resetKaabuSent(String numero) async {
    Database db = await instance.database;

    await db.rawUpdate("DELETE FROM resetkaabu WHERE numero = '$numero'");
  }

  Future<void> resetZebra(String numero) async {
    Database db = await instance.database;

    await db.rawUpdate("DELETE FROM resetzebra WHERE numero = '$numero'");
  }

  Future<List<ResetKaabu>> getResetKaabu() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query("resetkaabu");

    return List.generate(maps.length, (i) {
      return ResetKaabu(
        idresetkaabu: maps[i]['idresetkaabu'],
        resetkaabu_idutilisateur: maps[i]['resetkaabu_idutilisateur']
            .toString(),
        numero: maps[i]['numero'],
        login: maps[i]['login'],
      );
    });
  }

  Future<List<ResetZebra>> getResetZebra() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query("resetzebra");

    return List.generate(maps.length, (i) {
      return ResetZebra(
        resetzebra_idutilisateur: maps[i]['resetzebra_idutilisateur']
            .toString(),
        numero: maps[i]['numero'],
        solde: maps[i]['solde'],
      );
    });
  }

  Future<List<RlmsClass>> getRlms() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query("rlms");

    return List.generate(maps.length, (i) {
      return RlmsClass(
        rlms_idutilisateur: maps[i]['rlms_idutilisateur'].toString(),
        numero: maps[i]['numero'],
      );
    });
  }

  Future<void> resetRlmsSent(String numero) async {
    Database db = await instance.database;

    await db.rawUpdate("DELETE FROM rlms WHERE numero = '$numero'");
  }

  Future<List<Zebra>> getZebra() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query("zebra");

    return List.generate(maps.length, (i) {
      return Zebra(
        zebra_idutilisateur: maps[i]['zebra_idutilisateur'].toString(),
        user_msisdn: maps[i]['user_msisdn'],
        user_name: maps[i]['user_name'],
        geography: maps[i]['geography'],
        category: maps[i]['category'],
        status: maps[i]['status'],
        plaint: maps[i]['plaint'],
        parent_msisdn: maps[i]['parent_msisdn'],
        email: maps[i]['email'],
      );
    });
  }

  Future<void> resetZebraSent(String user_msisdn) async {
    Database db = await instance.database;

    await db.rawUpdate("DELETE FROM zebra WHERE user_msisdn = '$user_msisdn'");
  }

  Future<List<Creation>> getCreation() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query("creation");

    return List.generate(maps.length, (i) {
      return Creation(
        creation_idutilisateur: maps[i]['creation_idutilisateur'].toString(),
        infra_category: maps[i]['infra_category'],
        agent_phone: maps[i]['agent_phone'],
        nom: maps[i]['nom'],
        postnom: maps[i]['postnom'],
        prenom: maps[i]['prenom'],
        infra_phone: maps[i]['infra_phone'],
        login_infra: maps[i]['login_infra'],
        photoID: maps[i]['photoID'],
        plaint: maps[i]['plaint'],
        status: maps[i]['status'],
        observation: maps[i]['observation'],
        idcreation: null,
      );
    });
  }
}
