import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // For donut chart
import 'package:intl/intl.dart'; // For date formatting
import '../models/task.dart';
import 'taskcounters.dart'; // Import TaskCounters
import 'dart:math'; // For percentage calculation
import 'task_list_screen.dart';
import 'package:task_manager3/models/category/category.dart';

class TaskManagerHomePage extends StatelessWidget {
  const TaskManagerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for the entire page
      appBar: AppBar(
        title:
            const Text('Task Manager', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Consumer<TaskCounters>(
        builder: (context, taskCounters, child) {
          return ValueListenableBuilder<Box<Task>>(
            valueListenable: Hive.box<Task>('tasks').listenable(),
            builder: (context, box, _) {
              final tasks = box.values.toList();

              return ValueListenableBuilder<Box<Category>>(
                valueListenable: Hive.box<Category>('categories').listenable(),
                builder: (context, categoryBox, _) {
                  final customCategories = categoryBox.values.toList();

                  // Calculate task counts
                  final completedTasks =
                      tasks.where((t) => t.isCompleted).length;
                  final workTasks = tasks
                      .where((t) => t.category == 'Work' && !t.isCompleted)
                      .length;
                  final personalTasks = tasks
                      .where((t) => t.category == 'Personal' && !t.isCompleted)
                      .length;
                  final urgentTasks = tasks
                      .where((t) => t.category == 'Urgent' && !t.isCompleted)
                      .length;

                  final Map<String, int> categoryTaskCount = {};
                  customCategories.forEach((category) {
                    categoryTaskCount[category.name] = tasks
                        .where((task) => task.category == category.name)
                        .length;
                  });

                  // Use addPostFrameCallback to update counters after the build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    taskCounters.updateTaskCounts(
                      completed: completedTasks,
                      work: workTasks,
                      personal: personalTasks,
                      urgent: urgentTasks,
                      customCategories: categoryTaskCount,
                    );
                  });

                  // Calculate today's tasks
                  final today = DateTime.now();
                  final todayTasks = tasks
                      .where((t) =>
                          t.deadline != null &&
                          isSameDay(t.deadline!, today) &&
                          !t.isCompleted)
                      .toList();

                  final missedTasks = tasks
                      .where((t) =>
                          t.deadline != null &&
                          t.deadline!.isBefore(today) &&
                          !t.isCompleted)
                      .toList();

                  // Calculate percentage of completed tasks using TaskCounters
                  final totalTasks = taskCounters.totalTasks;
                  final percentageCompleted = totalTasks > 0
                      ? (taskCounters.completed / totalTasks) * 100
                      : 0;

                  return Column(
                    children: [
                      // Donut Chart with Today's Info
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Donut Chart
                            Expanded(
                              flex: 3,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sections: [
                                          if (completedTasks > 0)
                                            _buildChartSection("Completed",
                                                completedTasks, Colors.green),
                                          if (workTasks > 0)
                                            _buildChartSection(
                                                "Work", workTasks, Colors.blue),
                                          if (personalTasks > 0)
                                            _buildChartSection("Personal",
                                                personalTasks, Colors.orange),
                                          if (urgentTasks > 0)
                                            _buildChartSection("Urgent",
                                                urgentTasks, Colors.red),
                                        ],
                                        sectionsSpace: 4,
                                        centerSpaceRadius: 50, // Thinner donut
                                        borderData: FlBorderData(show: true),
                                      ),
                                    ),
                                    Text(
                                      "${percentageCompleted.toStringAsFixed(1)}%",
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 255, 64),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Today's Info
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('d MMM').format(today),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    todayTasks.isEmpty
                                        ? "No tasks due today"
                                        : "${todayTasks.length} tasks Due today",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    missedTasks.isEmpty
                                        ? "No missed tasks"
                                        : "${missedTasks.length} missed tasks",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.red,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Task Grid
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          padding: const EdgeInsets.all(16),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildCategoryTile(
                                context, "Completed", taskCounters.completed),
                            _buildCategoryTile(
                                context, "Work", taskCounters.work),
                            _buildCategoryTile(
                                context, "Personal", taskCounters.personal),
                            _buildCategoryTile(
                                context, "Urgent", taskCounters.urgent),
                            ...customCategories.map((category) {
                              return Consumer<TaskCounters>(
                                builder: (context, counters, child) {
                                  final count = counters
                                          .customCategories[category.name] ??
                                      0; // Get the count for the custom category
                                  print(
                                      "Custom category count for ${category.name}: $count"); // Debug statement
                                  return GestureDetector(
                                    onLongPress: () =>
                                        _showDeleteDialog(context, category),
                                    child: _buildCustomCategoryTile(
                                      context,
                                      category.name,
                                      count, // Pass the count explicitly
                                      category.color,
                                    ),
                                  );
                                },
                              );
                            }),
                            _buildAddCustomCategoryTile(
                                context), // Placeholder card
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/addTask'),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, String title, int count) {
    return InkWell(
      onTap: () {
        if (title == "Completed") {
          // Open the CompletedTaskList screen when the "Completed" category is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompletedTaskList(
                completedTasks: Hive.box<Task>('tasks')
                    .values
                    .where((task) => task.isCompleted)
                    .toList(), // Pass the list of completed tasks
              ),
            ),
          );
        } else {
          // For other categories, navigate to TaskListScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskListScreen(
                category: title,
                showCompleted: false,
              ),
            ),
          );
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 6, // More elevation for a better card effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // Blue Accent for category titles
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCategoryTile(
      BuildContext context, String title, int count, Color color) {
    return InkWell(
      onTap: () {
        // Logic for navigating to different screens based on the category
        if (title == "Completed") {
          // Open the CompletedTaskList screen when the "Completed" category is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompletedTaskList(
                completedTasks: Hive.box<Task>('tasks')
                    .values
                    .where((task) => task.isCompleted)
                    .toList(), // Pass the list of completed tasks
              ),
            ),
          );
        } else {
          // For other categories, navigate to TaskListScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskListScreen(
                category: title,
                showCompleted: false,
              ),
            ),
          );
        }
      },
      child: Card(
        color: color, // Set the background color of the custom category tile
        elevation: 6, // More elevation for a better card effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for the category title
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for the count
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomCategoryTile(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 40, color: Colors.blueAccent),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue; // Initial color selection

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Category Name"),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pick a color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: selectedColor,
                            onColorChanged: (color) {
                              selectedColor =
                                  color; // Update the selected color
                            },
                            showLabel: true,
                            pickerAreaHeightPercent: 0.8,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close color picker dialog
                            },
                            child: const Text('Select'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  height: 40,
                  width: 40,
                  color: selectedColor, // Display the selected color
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final box = Hive.box<Category>('categories');
                box.add(Category(
                  name: nameController.text,
                  colorValue:
                      selectedColor.value, // Use selectedColor.value here
                  taskIds: [],
                ));

                // Add the new custom category to TaskCounters
                final counters =
                    Provider.of<TaskCounters>(context, listen: false);
                counters
                    .addCustomCategory(nameController.text); // Add this line

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: const Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              onPressed: () {
                category.delete();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}

PieChartSectionData _buildChartSection(String title, int value, Color color) {
  final total = max(1, value); // Avoid division by zero
  final percentage =
      (value / total * 100).toStringAsFixed(0); // Percentage of completed tasks
  return PieChartSectionData(
    color: color,
    value: total.toDouble(),
    title:
        percentage == "100" ? "$value" : "$percentage%", // Display percentage
    titleStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    radius: 30,
  );
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.day == date2.day && date1.month == date2.month;
}

class CompletedTaskList extends StatelessWidget {
  final List<Task> completedTasks;

  const CompletedTaskList({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed Tasks"),
        backgroundColor: Colors.blueAccent, // Consistent with FAB color
      ),
      body: ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          final task = completedTasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(task.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.description,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Completed on: ${task.completedDate}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Delete task logic (if needed)
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
