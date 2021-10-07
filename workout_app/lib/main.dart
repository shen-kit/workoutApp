// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:workout_app/routes/edit_tags.dart';
import 'package:workout_app/routes/exercises.dart';
import 'package:workout_app/routes/new_exercise.dart';

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
      home: const Exercises(),
    );
  }
}
