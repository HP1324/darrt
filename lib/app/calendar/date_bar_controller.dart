import 'package:flutter/material.dart' show ScrollController;
import 'package:flutter_riverpod/flutter_riverpod.dart';


final dateBarControllerProvider = ChangeNotifierProvider<ScrollController>((ref) => ScrollController());
