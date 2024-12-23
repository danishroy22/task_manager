import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime? deadline;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime? completedDate;

  Task({
    required this.name,
    required this.description,
    required this.category,
    this.deadline,
    required this.isCompleted,
    this.completedDate,
  });
  // Toggle the completion status of the task
  void toggleCompletion() {
    isCompleted = !isCompleted;
    completedDate = isCompleted ? DateTime.now() : null;
    save();
  }

  // Update task details
  void update({
    required String updatedName,
    required String updatedDescription,
    DateTime? updatedDeadline,
    required String updatedCategory,
  }) {
    name = updatedName;
    description = updatedDescription;
    deadline = updatedDeadline;
    category = updatedCategory;
    save();
  }

  String getFormattedDeadline() {
    if (deadline == null) {
      return "No deadline";
    }
    return "${deadline!.hour.toString().padLeft(2, '0')}:${deadline!.minute.toString().padLeft(2, '0')}";
  }
}
