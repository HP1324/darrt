import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
///Custom router class to simplify navigation process inside the app.
class MiniRouter{
  static void to(BuildContext context, Widget child,{PageTransitionType type = PageTransitionType.fade}){
    Navigator.push(context, PageTransition(type: type,child: child));
  }

}