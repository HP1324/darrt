import 'package:flutter/material.dart';

class GeneralViewModel extends ChangeNotifier{
  FocusNode textFieldNode = FocusNode();

  @override
  void dispose() {
    textFieldNode.dispose();
    super.dispose();
  }
}