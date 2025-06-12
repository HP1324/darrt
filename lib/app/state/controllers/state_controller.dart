import 'package:flutter/material.dart';

/// Base abstract class defining the common interface for all state controllers
abstract class StateController<S, M> extends ChangeNotifier {
  /// The state managed by this controller
  late S state;

  /// Text controller for the primary text field
  final TextEditingController textController = TextEditingController();

  /// Focus node for the primary text field
  final FocusNode textFieldNode = FocusNode();

  /// Initialize the state with default values or with an existing model if in edit mode
  void initState(bool edit, [M? model]);

  /// Reset the state to default values
  void clearState();

  /// Build a model from the current state
  M buildModel({required bool edit, M? model});

  @override
  void dispose() {
    textController.dispose();
    textFieldNode.dispose();
    super.dispose();
  }
}