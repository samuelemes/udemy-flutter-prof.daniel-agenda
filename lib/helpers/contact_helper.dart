import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String table = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _intance = ContactHelper.internal();

  factory ContactHelper() => _intance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final dataBasePath = await getDatabasesPath();
    final path = join(dataBasePath, "contacts.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $table ($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
          "$phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(table, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(table,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(table, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    await dbContact.update(table, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;

    List listMap = await dbContact.rawQuery("SELECT * FROM $table");
    List<Contact> list = new List();
    for (Map m in listMap) {
      list.add(Contact.fromMap(m));
    }
    return list;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $table"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

//
class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if (id != null) {
      map[idColumn] = id;
    }
    print('map');
    print(map);
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString

    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
