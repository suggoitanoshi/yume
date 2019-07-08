import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:orion/model/money_activity.dart';

class DatabaseHandler{
  static Database _database;
  Future<Database> get database async{
    if(_database == null){
      _database = await initDatabase();
    }
    return _database;
  }

  Future<Database> initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'moneyactivity_db.db'),
      onCreate: (db, version)async{
        await db.execute(
          "CREATE TABLE categorylist(categoryname STRING)"
        );
        await db.execute(
          "CREATE TABLE activity(id INTEGER PRIMARY KEY AUTOINCREMENT, amount INTEGER, time STRING, title STRING, desc STRING, isIncome BOOLEAN, category STRING, FOREIGN KEY (category) REFERENCES categorylist(categoryname))",
        );
      },
      version: 1
    );
  }

  Future<int> addActivity(MoneyActivity act) async{
    Database db = await database;
    return db.insert('activity', act.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> removeActivity(MoneyActivity act) async{
    Database db = await database;
    await db.delete('activity',  where: 'id = ?', whereArgs: [act.id]);
    List<Map<String,dynamic>> samecateg = await db.query('activity', where: 'category = ?', whereArgs: [act.category]);
    if(samecateg.length == 0){
      removeCategory(act.category);
    }
  }

  Future<int> updateActivity(MoneyActivity oldAct, MoneyActivity newAct) async{
    final Database db = await database;
    return db.update(
      'activity',
      newAct.toMap(),
      where: 'id = ?',
      whereArgs: [oldAct.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MoneyActivity>> getActivity() async{
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('activity', orderBy: 'time DESC');
    return List.generate(
      maps.length, (i){
        return MoneyActivity.fromMap(maps[i]);
      }
    );
  }
  Future<List<MoneyActivity>> getLatestNActivity(int n) async{
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      orderBy: 'time DESC',
      limit: n
    );
    return List.generate(
      maps.length, (i){
        return MoneyActivity.fromMap(maps[i]);
      }
    );
  }
  Future<List<MoneyActivity>> getNActivityWithSkip(int n, int skip) async{
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      orderBy: 'time DESC',
      limit: n,
      offset: skip,
    );
    return List.generate(
      maps.length, (i){
        return MoneyActivity.fromMap(maps[i]);
      });
  }
  Future<List<MoneyActivity>> getActivityInCategory(String category) async{
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity',
      orderBy: 'time DESC',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(
      maps.length, (i){
        return MoneyActivity.fromMap(maps[i]);
      }
    );
  }
  Future<void> addCategory(String category) async {
    final Database db = await database;
    await db.insert('categorylist', {'categoryname': category}, conflictAlgorithm: ConflictAlgorithm.abort);
  }
  Future<List<String>> listCategory() async{
    final Database db = await database;
    final List<Map<String, dynamic>> map = await db.query('categorylist');
    return List.generate(map.length, (i){
      return map[i]['categoryname'];
    });
  }
  Future<List<String>> getCategoryByPattern(String pattern) async {
    final Database db = await database;
    final List<Map<String, dynamic>> map = await db.query(
      'categorylist',
      where: "categoryname LIKE ?",
      whereArgs: ['%'+pattern+'%'],
    );
    return List.generate(map.length, (i){
      return map[i]['categoryname'];
    });
  }
  Future<void> removeCategory(String name) async {
    final Database db = await database;
    await db.delete('categorylist', where: 'categoryname = ?', whereArgs: [name]);
  }
}

