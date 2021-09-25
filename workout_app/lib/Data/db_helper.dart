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

  // #region Create

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

  // #endregion

  //#region Read

  Future<List<Tag>> getAllTags() async {
    List<int> ids = await getTagIds();
    List<Tag> tags = [];
    for (int id in ids) {
      tags.add(await getTagFromId(id));
    }
    return tags;
  }

  Future<List<int>> getTagIds() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'tags',
      columns: ['id'],
      orderBy: 'id DESC',
    );
    List<int> ids = [];
    for (Map<String, dynamic> result in results) {
      ids.add(result['id']);
    }
    return ids;
  }

  Future<Tag> getTagFromId(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'tags',
      columns: ['name', 'color'],
      where: 'id = ?',
      whereArgs: [id],
    );
    Tag tag = Tag(id: id, name: result[0]['name'], color: result[0]['color']);
    return tag;
  }

  //#endregion Queries

  // #region Delete

  Future<void> deleteDb() async {
    await deleteDatabase(join(await getDatabasesPath(), _dbName));
    // ignore: avoid_print
    print('deleted database');
  }

  // #endregion
}
