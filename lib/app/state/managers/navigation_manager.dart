import 'package:flutter/material.dart';

class NavigationManager  {
  final ValueNotifier<int> currentDestination = ValueNotifier(0);
  void onDestinationChanged(int selectedDest){
    currentDestination.value = selectedDest;
  }
  final ValueNotifier<int> currentTab = ValueNotifier(0);

}
