import 'package:flutter/material.dart';

class NavigationManager extends ChangeNotifier {
  List<bool> selected = [true,false,false,false,false];
  int currentDestination = 0;
  void onDestinationChanged(int selectedDest){
    currentDestination = selectedDest;
    selected =  List.generate(selected.length, (index)=> index == selectedDest);
    notifyListeners();
  }
}
