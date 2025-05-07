import 'package:flutter/material.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/ui/task_item.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text('Notes'),floating: true,expandedHeight: 200),
          SliverList(delegate: SliverChildBuilderDelegate((context, index) => TaskItem(task: Task(title: 'Title')),childCount: 1000)),
        ],
      ),
    );
  }
}
