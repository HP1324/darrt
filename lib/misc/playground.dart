
// ignore_for_file: dangling_library_doc_comments

///////////////////////////////////////////////////////////////////////////////////////
//This file is intended to use for any general rough work, like testing a utility    //
//function before using it inside the actual code, or anything else that is not the  //
//part of the actual code, but rather used as a test                                 //
///////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:darrt/task/models/task.dart';



class _Playground extends StatefulWidget {
  const _Playground();

  @override
  State<_Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<_Playground> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void roughFunction(){
    var tasks = [];
    Task? task;
    bool? newValue;
    setState(() {
      List<Map<String, dynamic>> updatedTasks = List.from(tasks);
      int index = tasks.indexWhere((t)=>Task.fromJson(t).id == task!.id);
      if(index != -1){
        updatedTasks[index] = {
          'id': updatedTasks[index]['id'], // Preserve the id
          'title': updatedTasks[index]['title'], // Preserve the title
          'isDone': newValue! ? 1 : 0, // Update isDone
        };
      }
      tasks = updatedTasks;
    });
  }
}

