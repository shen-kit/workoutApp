// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workout_app/Data/data.dart';

class DatabaseHelper {
  static const _dbName = 'workoutAppDb.db';
  static const _dbVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper inst = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ?? await _initDatabase();

  // create the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  // create the tables in the database
  Future _onCreate(Database db, int version) async {
    db.execute(
      'CREATE TABLE routines(id INTEGER PRIMARY KEY, name TEXT, goals TEXT)',
    );
    db.execute(
      'CREATE TABLE workouts(id INTEGER PRIMARY KEY, routineId INTEGER REFERENCES routines(id), name TEXT)',
    );
    db.execute(
      'CREATE TABLE tags(id INTEGER PRIMARY KEY, name TEXT, color INTEGER)',
    );
    db.execute(
      'CREATE TABLE exercises(id INTEGER PRIMARY KEY, name TEXT)',
    );
    db.execute(
      'CREATE TABLE exerciseTags(exerciseId INTEGER REFERENCES exercises(id), tagId INTEGER REFERENCES tags(id))',
    );
    db.execute(
      'CREATE TABLE workoutExercises(id INTEGER PRIMARY KEY, workoutId INTEGER REFERENCES workouts(id), exerciseId INTEGER REFERENCES exercises(id), sets TEXT, reps TEXT, notes TEXT, position INTEGER, superset INTEGER)',
    );
  }

  //#region Tags

  Future<void> createTag(String name, int color) async {
    final db = await database;
    await db.insert(
      'tags',
      {
        'name': name,
        'color': color,
      },
    );
  }

  Future<List<TagInfo>> getAllTags() async {
    Future<List<int>> getTagIds() async {
      final db = await database;
      List<Map<String, dynamic>> results = await db.query(
        'tags',
        columns: ['id'],
        orderBy: 'id ASC',
      );
      List<int> ids = [];
      for (Map<String, dynamic> result in results) {
        ids.add(result['id']);
      }
      return ids;
    }

    Future<TagInfo> getTagFromId(int id) async {
      final db = await database;
      List<Map<String, dynamic>> result = await db.query(
        'tags',
        columns: ['name', 'color'],
        where: 'id = ?',
        whereArgs: [id],
      );
      TagInfo tag =
          TagInfo(id: id, name: result[0]['name'], color: result[0]['color']);
      return tag;
    }

    List<int> ids = await getTagIds();
    List<TagInfo> tags = [];
    for (int id in ids) {
      tags.add(await getTagFromId(id));
    }
    return tags;
  }

  Future<void> updateTag(TagInfo tag) async {
    final db = await database;
    Map<String, dynamic> row = {
      'name': tag.name,
      'color': tag.color,
    };
    await db.update(
      'tags',
      row,
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<void> deleteTag(int id) async {
    final db = await database;
    db.delete(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //#endregion Tags

  Future<void> deleteDb() async {
    await deleteDatabase(join(await getDatabasesPath(), _dbName));
    print('deleted database');
  }
}
