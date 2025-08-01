import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class BuildHabitEditor extends StatefulWidget {
  const BuildHabitEditor({super.key, required this.edit, this.habit, this.category})
    : assert(!edit || habit != null);

  final BuildHabit? habit;
  final bool edit;

  final EntityCategory? category;
  @override
  State<BuildHabitEditor> createState() => _BuildHabitEditorState();
}

class _BuildHabitEditorState extends State<BuildHabitEditor> {
  @override
  void initState() {
    super.initState();
    g.buildHabitSc.initState(widget.edit, widget.habit, widget.category);
  }

  @override
  void dispose() {
    debugPrint("dispose called");
    g.buildHabitSc.clearState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: FittedBox(child: Text(widget.edit ? widget.habit!.name : 'Build A New Habit')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            spacing: 20,
            children: [
              const SizedBox(),
              Row(
                children: [
                  Expanded(child: HabitNameField()),
                  const SizedBox(width: 12),
                  HabitColorPicker(),
                ],
              ),
              HabitDescriptionField(),
            ],
          ),
        ),
      ),
    );
  }
}

class HabitNameField extends StatelessWidget {
  const HabitNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return _HabitTextField(
      controller: g.buildHabitSc.textController,
      focusNode: g.buildHabitSc.textFieldNode,
      autoFocus: true,
      labelText: 'Habit Name',
    );
  }
}

class HabitColorPicker extends StatelessWidget {
  const HabitColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        final scheme = ColorScheme.of(context);
        final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

        return Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: scheme.outline,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => showColorPicker(
                context,
                onColorSelected: (color) {
                  g.buildHabitSc.textFieldNode.unfocus();
                  g.buildHabitSc.setColor(color);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class HabitDescriptionField extends StatelessWidget {
  const HabitDescriptionField({super.key});

  @override
  Widget build(BuildContext context) {
    return _HabitTextField(
      controller: g.buildHabitSc.descriptionController,
      focusNode: g.buildHabitSc.descriptionFocusNode,
      autoFocus: false,
      labelText: 'Description (Optional)',
      hintText : "Why is this habit important to you?",
    );
  }
}

class _HabitTextField extends StatelessWidget {
  const _HabitTextField({
    required this.controller,
    required this.labelText,
    required this.focusNode,
    this.autoFocus = false,
    this.hintText,
  });
  final TextEditingController controller;
  final String labelText;
  final FocusNode focusNode;
  final bool autoFocus;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        final scheme = ColorScheme.of(context);
        final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autoFocus,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            labelStyle: TextStyle(color: color),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        );
      },
    );
  }
}
