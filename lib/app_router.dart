import 'package:flutter/material.dart';
import 'package:minimaltodo/mini_page_transition.dart';
import 'package:page_transition/page_transition.dart';
///Custom router class to simplify navigation process inside the app.
class AppRouter{
  static void to(BuildContext context, {required Widget child, PageTransitionType type = PageTransitionType.fade}){
    Navigator.push(context, PageTransition(type: type,child: child));
  }
  static void miniTo(BuildContext context, {required Widget child, MiniPageTransitionType type = MiniPageTransitionType.jumpFromRight}){
    MiniPageTransition.push(context: context, page: child,type: type);
  }
}