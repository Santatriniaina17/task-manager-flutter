import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_lite/providers/task_provider.dart';
import 'package:task_manager_lite/screens/task_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..fetchTasks(),
      child: MaterialApp(
        title: 'Task Manager Lite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}
