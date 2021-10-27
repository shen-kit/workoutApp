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
      'CREATE TABLE routines(id INTEGER PRIMARY KEY, name TEXT, goals TEXT, routineOrder INTEGER)',
    );
    db.execute(
      'CREATE TABLE workouts(id INTEGER PRIMARY KEY, routineId INTEGER REFERENCES routines(id), name TEXT, workoutOrder INTEGER)',
    );
    db.execute(
      'CREATE TABLE tags(id INTEGER PRIMARY KEY, name TEXT, color INTEGER, tagOrder)',
    );
    db.execute(
      'CREATE TABLE exercises(id INTEGER PRIMARY KEY, name TEXT)',
    );
    db.execute(
      'CREATE TABLE exerciseTags(exerciseId INTEGER REFERENCES exercises(id), tagId INTEGER REFERENCES tags(id))',
    );
    db.execute(
      'CREATE TABLE workoutExercises(id INTEGER PRIMARY KEY, workoutId INTEGER REFERENCES workouts(id), exerciseId INTEGER REFERENCES exercises(id), sets TEXT, reps TEXT, notes TEXT, weight TEXT, exerciseOrder INTEGER, superset INTEGER)',
    );
  }

  //#region Tags

  Future<void> createTag(TagInfo tag) async {
    final db = await database;
    var result = await db.query(
      'tags',
      columns: ['tagOrder'],
      limit: 1,
      orderBy: 'tagOrder DESC',
    );
    int orderNumber = (result.isNotEmpty)
        ? int.parse(result[0]['tagOrder'].toString()) + 1
        : 0;
    db.insert(
      'tags',
      {
        'name': tag.name,
        'color': tag.color,
        'tagOrder': orderNumber,
      },
    );
  }

  Future<List<TagInfo>> getAllTags() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'tags',
      columns: ['id', 'name', 'color'],
      orderBy: 'tagOrder ASC',
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
    db.update(
      'tags',
      row,
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<void> reorderTags(int oldIndex, int newIndex) async {
    final db = await database;

    List<TagInfo> oldTagsInfo = await getAllTags();
    oldTagsInfo.insert(newIndex, oldTagsInfo.removeAt(oldIndex));

    await db.delete('tags');

    List<TagInfo> newTagsInfo = [];
    for (var i = 0; i < oldTagsInfo.length; i++) {
      final info = oldTagsInfo[i];
      newTagsInfo.add(
        TagInfo(
          id: info.id,
          name: info.name,
          color: info.color,
          order: i,
        ),
      );
    }

    for (TagInfo tag in newTagsInfo) {
      await db.insert(
        'tags',
        {
          'id': tag.id,
          'name': tag.name,
          'color': tag.color,
          'tagOrder': tag.order,
        },
      );
    }
  }

  Future<void> deleteTag(int id) async {
    final db = await database;
    db.delete(
      'exerciseTags',
      where: 'tagId = ?',
      whereArgs: [id],
    );
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
      db.insert(
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

  Future<void> updateExercise(ExerciseInfo exercise) async {
    final db = await database;
    // update exercise name
    db.update(
      'exercises',
      {
        'name': exercise.name,
      },
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
    // recreate tags for the exercise
    await db.delete(
      'exerciseTags',
      where: 'exerciseId = ?',
      whereArgs: [exercise.id],
    );
    for (int id in exercise.tags) {
      db.insert(
        'exerciseTags',
        {
          'tagId': id,
          'exerciseId': exercise.id,
        },
      );
    }
  }

  Future<void> deleteExercise(int id) async {
    final db = await database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.delete(
      'exerciseTags',
      where: 'exerciseId = ?',
      whereArgs: [id],
    );
  }

  //#endregion Exercises

  //#region Routines

  Future<void> createRoutine(RoutineInfo routine) async {
    final db = await database;
    var result = await db.query(
      'routines',
      columns: ['routineOrder'],
      limit: 1,
      orderBy: 'routineOrder DESC',
    );
    int orderNumber = (result.isNotEmpty)
        ? int.parse(result[0]['routineOrder'].toString()) + 1
        : 0;
    await db.insert(
      'routines',
      {
        'name': routine.name,
        'goals': routine.goals,
        'routineOrder': orderNumber,
      },
    );
    await reorderRoutines(orderNumber, 0);
  }

  Future<List<RoutineInfo>> getAllRoutines() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'routines',
      columns: ['id', 'name', 'goals', 'routineOrder'],
      orderBy: 'routineOrder ASC',
    );
    List<RoutineInfo> routines = [];
    for (Map<String, dynamic> result in results) {
      routines.add(RoutineInfo(
        id: result['id'],
        name: result['name'],
        goals: result['goals'],
        order: result['routineOrder'],
      ));
    }
    return routines;
  }

  Future<void> updateRoutine(RoutineInfo routine) async {
    final db = await database;
    // update exercise name
    db.update(
      'routines',
      {
        'name': routine.name,
        'goals': routine.goals,
      },
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  Future<void> reorderRoutines(int oldIndex, int newIndex) async {
    final db = await database;

    List<RoutineInfo> oldRoutineInfo = await getAllRoutines();
    oldRoutineInfo.insert(newIndex, oldRoutineInfo.removeAt(oldIndex));

    await db.delete('routines');

    List<RoutineInfo> newRoutineInfo = [];
    for (var i = 0; i < oldRoutineInfo.length; i++) {
      final info = oldRoutineInfo[i];
      newRoutineInfo.add(
        RoutineInfo(
          id: info.id,
          name: info.name,
          goals: info.goals,
          order: i,
        ),
      );
    }

    for (RoutineInfo routine in newRoutineInfo) {
      await db.insert(
        'routines',
        {
          'id': routine.id,
          'name': routine.name,
          'goals': routine.goals,
          'routineOrder': routine.order,
        },
      );
    }
  }

  Future<void> deleteRoutine(int id) async {
    final db = await database;

    // get and delete all related workouts and workout exercises before deleting the routine
    List<Map<String, dynamic>> results = await db.query(
      'workouts',
      columns: ['id'],
      where: 'routineId = ?',
      whereArgs: [id],
    );
    for (Map<String, dynamic> result in results) {
      final workoutId = result['id'];
      db.delete(
        'workoutExercises',
        where: 'workoutId = ?',
        whereArgs: [workoutId],
      );
    }
    db.delete(
      'workouts',
      where: 'routineId = ?',
      whereArgs: [id],
    );
    await db.delete(
      'routines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //#endregion Routines

  //#region Workouts

  Future<void> createWorkout(WorkoutInfo workout) async {
    final db = await database;
    var result = await db.query(
      'workouts',
      columns: ['workoutOrder'],
      where: 'routineId = ?',
      whereArgs: [workout.routineId],
      limit: 1,
      orderBy: 'workoutOrder DESC',
    );
    int orderNumber = (result.isNotEmpty)
        ? int.parse(result[0]['workoutOrder'].toString()) + 1
        : 0;
    await db.insert(
      'workouts',
      {
        'routineId': workout.routineId,
        'name': workout.name,
        'workoutOrder': orderNumber,
      },
    );
  }

  Future<List<WorkoutInfo>> getWorkoutsForRoutine(int routineId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'workouts',
      columns: ['id', 'routineId', 'name'],
      where: 'routineId = ?',
      whereArgs: [routineId],
      orderBy: 'workoutOrder ASC',
    );

    List<WorkoutInfo> workouts = [];
    for (var result in results) {
      workouts.add(
        WorkoutInfo(
          id: result['id'],
          routineId: result['routineId'],
          name: result['name'],
        ),
      );
    }

    return workouts;
  }

  Future<void> reorderWorkouts(
      int routineId, int oldIndex, int newIndex) async {
    final db = await database;

    List<WorkoutInfo> oldWorkoutInfo = await getWorkoutsForRoutine(routineId);
    oldWorkoutInfo.insert(newIndex, oldWorkoutInfo.removeAt(oldIndex));

    await db.delete(
      'workouts',
      where: 'routineId = ?',
      whereArgs: [routineId],
    );

    List<WorkoutInfo> newWorkoutInfo = [];
    for (var i = 0; i < oldWorkoutInfo.length; i++) {
      final info = oldWorkoutInfo[i];
      newWorkoutInfo.add(
        WorkoutInfo(
          id: info.id,
          name: info.name,
          routineId: routineId,
          order: i,
        ),
      );
    }

    for (WorkoutInfo workout in newWorkoutInfo) {
      await db.insert(
        'workouts',
        {
          'id': workout.id,
          'name': workout.name,
          'routineId': workout.routineId,
          'workoutOrder': workout.order,
        },
      );
    }
  }

  Future<void> deleteWorkout(int id) async {
    final db = await database;
    await db.delete(
      'workoutExercises',
      where: 'workoutId = ?',
      whereArgs: [id],
    );
    await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //#endregion Workouts

  //#region WorkoutExercises

  Future<void> createWorkoutExercise(WorkoutExerciseInfo exercise) async {
    final db = await database;
    var result = await db.query(
      'workoutExercises',
      columns: ['exerciseOrder'],
      where: 'workoutId = ?',
      whereArgs: [exercise.workoutId],
      limit: 1,
      orderBy: 'exerciseOrder DESC',
    );
    int orderNumber = (result.isNotEmpty)
        ? int.parse(result[0]['exerciseOrder'].toString()) + 1
        : 0;
    await db.insert(
      'workoutExercises',
      {
        'workoutId': exercise.workoutId,
        'exerciseId': exercise.exerciseId,
        'sets': exercise.sets,
        'reps': exercise.reps,
        'notes': exercise.notes,
        'weight': exercise.weight,
        'superset': exercise.superset,
        'exerciseOrder': orderNumber,
      },
    );
  }

  Future<List<WorkoutExerciseInfo>> getWorkoutExercises(int workoutId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'workoutExercises',
      columns: [
        'id',
        'exerciseId',
        'sets',
        'reps',
        'notes',
        'weight',
        'superset',
      ],
      where: 'workoutId = ?',
      whereArgs: [workoutId],
      orderBy: 'exerciseOrder ASC',
    );

    List<WorkoutExerciseInfo> exercises = [];
    for (var result in results) {
      List<Map<String, dynamic>> nameResult = await db.query(
        'exercises',
        columns: ['name'],
        where: 'id = ?',
        whereArgs: [result['exerciseId']],
      );
      String exerciseName = nameResult[0]['name'];
      exercises.add(
        WorkoutExerciseInfo(
          id: result['id'],
          workoutId: workoutId,
          exerciseId: result['exerciseId'],
          exerciseName: exerciseName,
          sets: result['sets'],
          reps: result['reps'],
          notes: result['notes'],
          weight: result['weight'],
          superset: result['superset'],
        ),
      );
    }

    return exercises;
  }

  //#endregion WorkoutExercises

  Future<void> deleteDb() async {
    await deleteDatabase(join(await getDatabasesPath(), _dbName));
    print('deleted database');
  }
}
