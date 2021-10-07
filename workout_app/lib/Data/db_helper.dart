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

  Future<void> createTag(TagInfo tag) async {
    final db = await database;
    await db.insert(
      'tags',
      {
        'name': tag.name,
        'color': tag.color,
      },
    );
  }

  Future<List<TagInfo>> getAllTags() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'tags',
      columns: ['id', 'name', 'color'],
      orderBy: 'id ASC',
    );
    List<TagInfo> tags = [];
    for (Map<String, dynamic> result in results) {
      tags.add(TagInfo(
        id: result['id'],
        name: result['name'],
        color: result['color'],
      ));
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

  //#region Exercises

  Future<void> createExercise(ExerciseInfo exercise) async {
    final db = await database;
    int exerciseId = await db.insert(
      'exercises',
      {
        'name': exercise.name,
      },
    );
    for (int tag in exercise.tags) {
      await db.insert(
        'exerciseTags',
        {
          'exerciseId': exerciseId,
          'tagId': tag,
        },
      );
    }
  }

  Future<List<ExerciseInfo>> getAllExercises() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'exercises',
      columns: ['id', 'name'],
      orderBy: 'name ASC',
    );

    List<ExerciseInfo> exercises = [];
    for (Map<String, dynamic> result in results) {
      ExerciseInfo exercise = ExerciseInfo(
        id: result['id'],
        name: result['name'],
        tags: [],
      );
      List<Map<String, dynamic>> tagsResult = await db.query(
        'exerciseTags',
        columns: ['tagId'],
        where: 'exerciseId = ?',
        whereArgs: [result['id']],
      );
      for (Map<String, dynamic> tag in tagsResult) {
        exercise.tags.add(tag['tagId']);
      }
      exercises.add(exercise);
    }
    return exercises;
  }

  //#endregion Exercises

  Future<void> deleteDb() async {
    await deleteDatabase(join(await getDatabasesPath(), _dbName));
    print('deleted database');
  }
}
