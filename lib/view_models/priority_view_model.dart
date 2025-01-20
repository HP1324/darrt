import 'package:flutter/material.dart';
import 'package:minimaltodo/theme/app_theme.dart';

class PriorityViewModel extends ChangeNotifier{

  List<String> priorities = ["Urgent",  "High", "Medium", "Low"];
  int currentValue = 3;  // Default to Low
  String get currentPriority => priorities[currentValue];

  void navigatePriority(bool isNext) {
    if (isNext) {
      // Go to next priority (right)
      currentValue = (currentValue + 1) % priorities.length;
    } else {
      // Go to previous priority (left)
      currentValue = (currentValue - 1 + priorities.length) % priorities.length;
    }
    notifyListeners();
  }
  // void resetPriority(){
  //   currentValue = 3;
  //   notifyListeners();
  // }
  // WidgetStateProperty<Color?> setChipColor(int index){
  //   return WidgetStatePropertyAll(chipColor = currentValue == index ? AppTheme.light.primaryColor : AppTheme.light.primaryColor);
  // }
  Color setLabelColor(int index){
    return currentValue == index ? Colors.white : Colors.black;
  }
}