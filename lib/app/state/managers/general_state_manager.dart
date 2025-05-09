import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;

class GeneralStateManager extends ChangeNotifier{
   ScrollController scrollController = ScrollController();
  bool isFabVisible = true;

  GeneralStateManager(){
    scrollController.addListener(_onScroll);
  }
  void _onScroll(){
    if(scrollController.position.userScrollDirection == ScrollDirection.reverse){
      isFabVisible = false;
    }else if(scrollController.position.userScrollDirection == ScrollDirection.forward){
      isFabVisible = true;
    }
    notifyListeners();
  }

  void setNewController(){
    scrollController = ScrollController();
  }
}