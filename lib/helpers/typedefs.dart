import 'package:flutter/material.dart';

typedef OneTimeCompletions = ValueNotifier<Map<int, bool>>;

typedef RepeatingCompletions = ValueNotifier<Map<int, Set<int>>>;
