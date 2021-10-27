// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:workout_app/Data/data.dart';
import 'package:workout_app/routes/new_workout_exercise.dart';
import 'package:workout_app/routes/routine.dart';
import 'package:workout_app/routes/routines.dart';
import 'package:workout_app/routes/workout.dart' as workout_page;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    // primarySwatch: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExTrack',
      darkTheme: darkTheme.copyWith(
        colorScheme: darkTheme.colorScheme.copyWith(
          secondary: const Color(0xFF40C0DC),
        ),
      ),
      themeMode: ThemeMode.dark,
      // home: const workout_page.Workout(workoutId: 0, name: 'Hypertrophy'),6
      home: const Routines(),
    );
  }
}
