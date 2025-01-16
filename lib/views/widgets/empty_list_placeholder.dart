
import 'package:flutter/material.dart';
import 'package:minimaltodo/theme/app_theme.dart';

class EmptyListPlaceholder extends StatefulWidget {
  const EmptyListPlaceholder({super.key, this.text = 'No tasks to show'});
  final String text;

  @override
  State<EmptyListPlaceholder> createState() => _EmptyListPlaceholderState();
}

class _EmptyListPlaceholderState extends State<EmptyListPlaceholder> {


  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.note_alt_outlined,
      size: 140,
      color:Theme.of(context).colorScheme.surface,
    );
  }
}
