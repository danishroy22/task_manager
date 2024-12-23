import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager3/Screens/task_calendar_screen.dart';

import 'Screens/addtaskscreen.dart';
import 'Screens/settingssccreen.dart';
import 'models/task.dart';
import 'models/category/category.dart';
import 'Screens/taskcounters.dart';
import 'Screens/taskmanagerhomepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');
  Hive.registerAdapter(CategoryAdapter()); // Register the adapter.
  await Hive.openBox<Category>('categories'); // Open the categories box.
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  _TaskManagerAppState createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  int _selectedIndex = 0;

  // List of screens corresponding to each tab
  static final List<Widget> _widgetOptions = <Widget>[
    TaskManagerHomePage(),
    const TaskCalendarScreen(),
    const SettingsScreen(), // Add your SettingsScreen here
  ];

  // Method to update the selected tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Change the tab when tapped
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskCounters()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(), // Default to light theme
        darkTheme: ThemeData.dark(), // Define the dark theme
        themeMode: ThemeMode.light, // Use the system theme by default
        initialRoute: '/',
        routes: {
          '/': (context) => Scaffold(
                body: _widgetOptions
                    .elementAt(_selectedIndex), // Display the selected screen
                bottomNavigationBar: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: 'Task Calendar',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped, // Change the selected tab when tapped
                ),
              ),
          '/addTask': (context) => AddTaskScreen(),
          '/taskCalender': (context) => const TaskCalendarScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
