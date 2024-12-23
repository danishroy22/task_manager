import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskCalendarScreen extends StatefulWidget {
  const TaskCalendarScreen({super.key});

  @override
  _TaskCalendarScreenState createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  late final Box<Task> _taskBox;
  late Map<DateTime, List<Task>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _taskBox = Hive.box<Task>('tasks');
    _events = _groupTasksByDate();
  }

  /// Groups tasks by their deadline
  Map<DateTime, List<Task>> _groupTasksByDate() {
    Map<DateTime, List<Task>> events = {};
    for (var task in _taskBox.values) {
      if (task.deadline != null) {
        // Normalize the date to ensure consistency
        final date = DateTime.utc(
          task.deadline!.year,
          task.deadline!.month,
          task.deadline!.day,
        );
        if (!events.containsKey(date)) {
          events[date] = [];
        }
        events[date]!.add(task);
      }
    }
    print('Grouped Events: $events'); // Debugging output
    return events;
  }

  /// Retrieves tasks for a specific day
  List<Task> _getTasksForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    final tasks = _events[normalizedDay] ?? [];
    print('Tasks for $normalizedDay: $tasks'); // Debugging output
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar<Task>(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            eventLoader: _getTasksForDay,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }

  /// Builds the list of tasks for the selected day
  Widget _buildTaskList() {
    final tasks = _getTasksForDay(_selectedDay ?? _focusedDay);

    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks for this day.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              task.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (task.deadline != null)
                  Text(
                    'Deadline: ${task.deadline!.hour}:${task.deadline!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            trailing: Icon(
              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: task.isCompleted ? Colors.green : Colors.grey,
            ),
            onTap: () {
              _showTaskDetails(task);
            },
          ),
        );
      },
    );
  }

  /// Shows task details in a dialog
  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${task.description}'),
            if (task.deadline != null) Text('Deadline: ${task.deadline}'),
            Text(
              task.isCompleted ? 'Status: Completed' : 'Status: Incomplete',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                task.isCompleted = !task.isCompleted;
                task.save();
                _events = _groupTasksByDate(); // Refresh events
              });
              Navigator.of(context).pop();
            },
            child: Text(
              task.isCompleted ? 'Mark as Incomplete' : 'Mark as Completed',
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
