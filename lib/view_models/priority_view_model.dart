import 'package:flutter/material.dart';
import 'package:minimaltodo/theme/app_theme.dart';

class PriorityViewModel extends ChangeNotifier{
  List<String> priorities = ["Urgent", "High", "Medium", "Low"];
  int? currentValue = 3;
  String? currentPriority;
  Color labelColor = Colors.black;
  Color? chipColor;
  void updatePriority(bool selected, int index){
    currentValue = selected ? index : null;
    currentValue ??= 3;
    currentPriority = priorities[currentValue!];
    notifyListeners();
  }
  void resetPriority(){
    currentValue = 3;
    notifyListeners();
  }
  WidgetStateProperty<Color?> setChipColor(int index){
    return WidgetStatePropertyAll(chipColor = currentValue == index ? AppTheme.primary : AppTheme.background100);
  }
  Color setLabelColor(int index){
    return currentValue == index ? Colors.white : Colors.black;
  }
}