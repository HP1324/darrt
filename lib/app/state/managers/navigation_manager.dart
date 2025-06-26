import 'package:flutter/material.dart';

class NavigationManager  {
  List<bool> selected = [true,false,false,false,false];
  final ValueNotifier<int> currentDestination = ValueNotifier(0);
  void onDestinationChanged(int selectedDest){
    currentDestination.value = selectedDest;
    selected =  List.generate(selected.length, (index)=> index == selectedDest);
  }
}
