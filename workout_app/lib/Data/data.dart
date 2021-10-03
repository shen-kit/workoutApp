import 'package:flutter/material.dart';

class AppData {
  static const List<Color> availableColors = [
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
  static int colorToIndex(Color color) => availableColors.indexOf(color);
}

class TagInfo {
  int id;
  String name;
  int color;

  TagInfo({this.id = -1, required this.name, required this.color});
}
