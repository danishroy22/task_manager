import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import 'taskcounters.dart';
import 'package:intl/intl.dart'; // For date formatting

class TaskListScreen extends StatefulWidget {
  final String category;
  final bool showCompleted;

  const TaskListScreen({
    super.key,
    required this.category,
    required this.showCompleted,
  });

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Box<Task> _taskBox;

  @override
  void initState() {
    super.initState();
    _taskBox = Hive.box<Task>('tasks');
  }

  @override
  Widget build(BuildContext context) {
    // Filter tasks by category and completion status
    final tasks = widget.showCompleted
        ? _taskBox.values.where((task) => task.isCompleted).toList()
        : _taskBox.values
            .where(
                (task) => task.category == widget.category && !task.isCompleted)
            .toList();

    // Get the current count of tasks in the custom category
    final currentTaskCount = _taskBox.values
        .where((task) => task.category == widget.category)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} ($currentTaskCount)', // Display the current task count
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: tasks.isEmpty
            ? Center(
                child: Text(
                  widget.showCompleted
                      ? "No Completed Tasks"
                      : "No Tasks in this Category",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        task.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.description,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Deadline: ${task.deadline != null ? DateFormat('yMMMd').format(task.deadline!) : 'No deadline set'}", // Format the deadline
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                      trailing: widget.showCompleted
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Delete the task
                                task.delete();

                                // Update counters for deleted tasks if necessary
                                final counters = Provider.of<TaskCounters>(
                                    context,
                                    listen: false);
                                counters
                                    .decrementCompleted(); // Adjust as needed

                                // Show a Snackbar for feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Task deleted successfully')),
                                );

                                // Refresh the UI
                                setState(() {});
                              },
                            )
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  task.isCompleted = true;
                                  task.completedDate = DateTime.now();
                                  task.save();

                                  // Update counters dynamically
                                  final counters = Provider.of<TaskCounters>(
                                      context,
                                      listen: false);
                                  counters.incrementCompleted();

                                  // Call the method to update task counts based on completion
                                  counters.batchUpdateForCompletion(
                                    category: task.category,
                                    isCompleted: true,
                                  );

                                  // Show a Snackbar for feedback
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Task marked as completed')),
                                  );
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: const Text(
                                'Mark as Completed',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
