import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'category.g.dart'; // Run `flutter packages pub run build_runner build`

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int colorValue; // Storing the Color as an integer.

  @HiveField(2)
  List<int> taskIds; // List of task IDs associated with the category.

  Category({
    required this.name,
    required this.colorValue,
    required this.taskIds,
  });

  // Convert the integer back to a Color object
  Color get color => Color(colorValue);
}
