import 'package:flutter/material.dart';
import 'package:task_manager3/models/task.dart';

class TaskCounters with ChangeNotifier {
  // Predefined categories
  int _completed = 0;
  int _work = 0;
  int _personal = 0;
  int _urgent = 0;

  // Map for custom categories
  Map<String, int> _customCategories = {};

  // Placeholder for task list (replace this with your actual task list)
  List<Task> someTaskList = [];

  // Getters for predefined categories
  int get completed => _completed;
  int get work => _work;
  int get personal => _personal;
  int get urgent => _urgent;

  // Getters for custom categories
  Map<String, int> get customCategories => _customCategories;

  // Total tasks (completed + all categories)
  int get totalTasks {
    return _completed +
        _work +
        _personal +
        _urgent +
        _customCategories.values.fold(0, (sum, count) => sum + count);
  }

  int getCustomCategoryCount(String category) {
    return _customCategories[category] ??
        0; // Return 0 if the category does not exist
  }

  // Reset counters for predefined and custom categories
  void resetCounters() {
    _completed = 0;
    _work = 0;
    _personal = 0;
    _urgent = 0;
    _customCategories.clear();
    notifyListeners();
  }

  // Update task counts
  void updateTaskCounts({
    required int completed,
    required int work,
    required int personal,
    required int urgent,
    required Map<String, int> customCategories,
  }) {
    _completed = completed;
    _work = work;
    _personal = personal;
    _urgent = urgent;
    _customCategories = customCategories;
    notifyListeners();
  }

  // Increment completed tasks
  void incrementCompleted() {
    _completed++;
    notifyListeners();
  }

  // Decrement completed tasks
  void decrementCompleted() {
    if (_completed > 0) _completed--;
    notifyListeners();
  }

  // Increment predefined category count
  void incrementCategory(String category) {
    if (category == 'Work') {
      _work++;
    } else if (category == 'Personal') {
      _personal++;
    } else if (category == 'Urgent') {
      _urgent++;
    } else {
      incrementCustomCategoryCount(category);
    }
    notifyListeners();
  }

  // Decrement predefined category count
  void decrementCategory(String category) {
    if (category == 'Work' && _work > 0) {
      _work--;
    } else if (category == 'Personal' && _personal > 0) {
      _personal--;
    } else if (category == 'Urgent' && _urgent > 0) {
      _urgent--;
    } else {
      decrementCustomCategoryCount(category);
    }
    notifyListeners();
  }

  // Add a custom category
  void addCustomCategory(String category) {
    if (!_customCategories.containsKey(category)) {
      _customCategories[category] = 0;
      notifyListeners();
    }
  }

  // Remove a custom category
  void removeCustomCategory(String category) {
    if (_customCategories.containsKey(category)) {
      _customCategories.remove(category);
      notifyListeners();
    }
  }

  // Increment custom category count
  void incrementCustomCategoryCount(String category) {
    if (_customCategories.containsKey(category)) {
      _customCategories[category] = _customCategories[category]! + 1;
    } else {
      _customCategories[category] = 1;
    }
    notifyListeners();
  }

  // Decrement custom category count
  void decrementCustomCategoryCount(String category) {
    if (_customCategories.containsKey(category) &&
        _customCategories[category]! > 0) {
      _customCategories[category] = _customCategories[category]! - 1;
    }
    notifyListeners();
  }

  // Batch update for task completion
  void batchUpdateForCompletion({
    required String category,
    required bool isCompleted,
  }) {
    // Check if the category is a custom category
    if (_customCategories.containsKey(category)) {
      // Recalculate the count for the category
      _customCategories[category] = calculateCustomCategoryCount(category);

      // Update the completed task count if marking as completed
      if (isCompleted) {
        incrementCompleted();
      } else {
        decrementCompleted();
      }
    }
    notifyListeners();
  }

  // Helper method to recalculate the task count for a custom category
  int calculateCustomCategoryCount(String category) {
    // Filter tasks in the given category that are not completed
    return someTaskList
        .where((task) => task.category == category && !task.isCompleted)
        .length;
  }

  // Refresh all custom categories dynamically
  void refreshAllCustomCategoryCounts() {
    for (String category in _customCategories.keys) {
      _customCategories[category] = calculateCustomCategoryCount(category);
    }
    notifyListeners();
  }
}
