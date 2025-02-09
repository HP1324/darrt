import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_enums.dart';
import 'package:minimaltodo/helpers/mini_page_transition.dart';
import 'package:page_transition/page_transition.dart';
///Custom router class to simplify navigation process inside the app.
class MiniRouter{
  static void to(BuildContext context, {required Widget child, PageTransitionType type = PageTransitionType.fade}){
    Navigator.push(context, PageTransition(type: type,child: child));
  }
  static void miniTo(BuildContext context, {required Widget child, MiniPageTransitionType type = MiniPageTransitionType.jumpFromRight, Offset? tapPosition}) {
    MiniPageTransition.push(context: context, page: child,type: type,tapPosition: tapPosition);
  }
}