import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager3/models/category/category.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _taskName = '';
  String _taskDescription = '';
  DateTime _deadline = DateTime.now();
  String selectedCategory = 'Work'; // Default category

  @override
  Widget build(BuildContext context) {
    final predefinedCategories = ['Work', 'To-Do', 'Urgent'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Name Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Task Name",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
                  ),
                  onSaved: (value) => _taskName = value!,
                  validator: (value) =>
                      value!.isEmpty ? "Enter a task name" : null,
                ),
                const SizedBox(height: 16),

                // Task Description Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Task Description",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
                  ),
                  onSaved: (value) => _taskDescription = value!,
                  validator: (value) =>
                      value!.isEmpty ? "Enter a description" : null,
                ),
                const SizedBox(height: 16),

                // Category Selection - Card for Predefined and Custom Categories
                GestureDetector(
                  onTap: () {
                    _selectCategory(context, predefinedCategories);
                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.category, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Category: $selectedCategory",
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Deadline: ${_deadline.toLocal()}".split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _deadline,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_deadline),
                          );

                          if (pickedTime != null) {
                            DateTime combinedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                            setState(() => _deadline = combinedDateTime);
                          }
                        }
                      },
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save Task Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Save task to Hive
                      var taskBox = Hive.box<Task>('tasks');
                      taskBox.add(Task(
                        name: _taskName,
                        category: selectedCategory,
                        deadline: _deadline,
                        description: _taskDescription,
                        isCompleted: false,
                      ));

                      Navigator.pop(context); // Return to the home screen
                    }
                  },
                  child: const Text(
                    "Save Task",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectCategory(
      BuildContext context, List<String> predefinedCategories) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Category"),
          content: ValueListenableBuilder(
            valueListenable: Hive.box<Category>('categories').listenable(),
            builder: (context, Box<Category> categoriesBox, _) {
              final categories = categoriesBox.values.toList();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display Predefined Categories
                    ...predefinedCategories.map((category) {
                      return ListTile(
                        title: Text(category),
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),

                    // Display Custom Categories
                    ...categories.map((category) {
                      return ListTile(
                        title: Text(category.name),
                        onTap: () {
                          setState(() {
                            selectedCategory = category.name;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
