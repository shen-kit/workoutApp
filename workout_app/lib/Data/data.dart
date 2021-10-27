import 'package:flutter/material.dart';

class AppData {
  static const List<Color> tagColors = [
    Color(0xFF9BA1FF),
    Color(0xFFFFF3AB),
    Color(0xFFFF9FCE),
    Color(0xFFA9F5FF),
    Color(0xFFBD8261),
    Color(0xFFA7BC54),
    Color(0xFFC52DB5),
    Color(0xFFCFA9FF),
    Color(0xFFD37F31),
  ];
  static int colorToIndex(Color color) => tagColors.indexOf(color);

  static const List<Color> supersetColors = [
    Color(0xFF8a5d43),
    Color(0xFF6c783c),
    Color(0xFF43767d),
    Color(0xFF803b78),
    Color(0xFF5b5f7d),
    Color(0xFF916031),
  ];
}

class TagInfo {
  int id;
  String name;
  int color;
  int order;

  TagInfo({
    this.id = -1,
    required this.name,
    required this.color,
    this.order = -1,
  });
}

class ExerciseInfo {
  int id;
  String name;
  List<int> tags;

  ExerciseInfo({this.id = -1, required this.name, required this.tags});
}

class RoutineInfo {
  int id;
  String name;
  String goals;
  int order;

  RoutineInfo({
    this.id = -1,
    required this.name,
    required this.goals,
    this.order = -1,
  });
}

class WorkoutInfo {
  int id;
  int routineId;
  String name;
  int order;

  WorkoutInfo({
    this.id = -1,
    required this.routineId,
    required this.name,
    this.order = -1,
  });
}

class WorkoutExerciseInfo {
  int id;
  int workoutId;
  int exerciseId;
  String? exerciseName;
  String sets;
  String reps;
  String notes;
  String weight;
  int superset;
  int exerciseOrder;

  WorkoutExerciseInfo({
    this.id = -1,
    required this.workoutId,
    required this.exerciseId,
    this.exerciseName, // get from exerciseId in case exercise gets edited
    required this.sets,
    required this.reps,
    required this.notes,
    required this.weight,
    required this.superset,
    this.exerciseOrder = -1,
  });
}
