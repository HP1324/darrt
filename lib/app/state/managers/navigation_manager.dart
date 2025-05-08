import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/utils.dart' show getIt;
import 'package:minimaltodo/task/state/task_view_model.dart' show TaskViewModel;

class NavigationManager extends ChangeNotifier {
  List<bool> selected = [true,false,false,false,false];
  int currentDestination = 0;
  void onDestinationChanged(int selectedDest){
    currentDestination = selectedDest;
    selected =  List.generate(selected.length, (index)=> index == selectedDest);
    notifyListeners();
  }
}
