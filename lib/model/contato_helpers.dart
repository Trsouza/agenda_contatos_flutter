import 'dart:async';
import 'dart:async' as prefix0;
import 'dart:core';
import 'dart:core' as prefix1;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tabelaContato = "tabelaContato";
final String idColuna = "idColuna";
final String nomeColuna = "nomeColuna";
final String emailColuna = "emailColuna";
final String telefoneColuna = "telefoneColuna";
final String imagemColuna = "imagemColuna";

class ContatoHelper {
  static final ContatoHelper _instancia = ContatoHelper.interno();
  factory ContatoHelper() => _instancia;
  ContatoHelper.interno();

  Database _db;

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  prefix0.Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contatos.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int numVersao) async {
        
      await db.execute(
          "CREATE TABLE $tabelaContato($idColuna INTEGER PRIMARY KEY, $nomeColuna TEXT, $emailColuna TEXT,  $telefoneColuna TEXT, $imagemColuna TEXT)");
    });
  }

  Future<Contato> salvarContato(Contato contato) async {
    Database dbContato = await db;
    contato.id = await dbContato.insert(tabelaContato, contato.toMap());
    return contato;
  }

  Future<Contato> getContato(int id) async {
    Database dbContato = await db;
    List<Map> maps = await dbContato.query(tabelaContato,
        columns: [
          idColuna,
          nomeColuna,
          emailColuna,
          telefoneColuna,
          imagemColuna
        ],
        where: "$idColuna = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contato.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> excluirContato(int id) async {
    Database dbContato = await db;
    return await dbContato
        .delete(tabelaContato, where: "$idColuna =?", whereArgs: [id]);
  }

  Future<int> atualizarContato(Contato contato) async {
    Database dbContato = await db;
    return await dbContato.update(tabelaContato, contato.toMap(),
        where: "$idColuna =?", whereArgs: [contato.id]);
  }

  Future<List> getContatos() async {
    Database dbContato = await db;
    List listMap = await dbContato.rawQuery("SELECT * FROM $tabelaContato");
    List<Contato> listContato = List();
    for (Map m in listMap) {
      listContato.add(Contato.fromMap(m));
    }
    return listContato;
  }

  Future<int> getNumero() async {
    Database dbContato = await db;
    return Sqflite.firstIntValue(
        await dbContato.rawQuery("SELECT COUNT(*) FROM $tabelaContato"));
  }

  Future fechar() async {
    Database dbContato = await db;
    dbContato.close();
  }
}

class Contato {
  String nome, email, telefone, imagem;
  int id;
  Contato();

  //transforma de map para contato
  Contato.fromMap(Map map) {
    id = map[idColuna];
    nome = map[nomeColuna];
    email = map[emailColuna];
    telefone = map[telefoneColuna];
    imagem = map[imagemColuna];
  }

  //transforma de contato para map
  Map toMap() {
    Map<String, dynamic> map = {
      nomeColuna: nome,
      emailColuna: email,
      telefoneColuna: telefone,
      imagemColuna: imagem
    };
    if (id != null) {
      map[idColuna] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contato(id: $id, nome: $nome, email: $email, telefone: $telefone, imagem: $imagem)";
  }
}
