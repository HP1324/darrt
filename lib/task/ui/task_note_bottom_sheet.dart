import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/note/ui/add_note_page.dart';
import 'package:darrt/task/state/task_state_controller.dart';
import 'package:darrt/task/state/task_view_model.dart';
import 'package:darrt/task/ui/task_note_item.dart';

import '../models/task.dart';

class TaskNoteBottomSheet extends StatefulWidget {
  const TaskNoteBottomSheet({super.key, required this.controller, this.task})
    : assert(
        controller is! TaskViewModel || task != null,
        'Task must be provided for TaskViewModel',
      );
  final Listenable controller;
  final Task? task;
  @override
  State<TaskNoteBottomSheet> createState() => _TaskNoteBottomSheetState();
}

class _TaskNoteBottomSheetState extends State<TaskNoteBottomSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      g.taskVm.initTaskNotesState(widget.task!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = ColorScheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Icon(
                  Icons.sticky_note_2_outlined,
                  color: scheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Task Notes',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (widget.controller is TaskStateController)
            Expanded(
              child: ListenableBuilder(
                listenable: g.taskSc,
                builder: (context, child) {
                  final notes = g.taskSc.notes;
                  if (notes == null || notes.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: scheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes for this task',
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first note to get started',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return TaskNoteItem(note: notes[index], controller: widget.controller);
                    },
                  );
                },
              ),
            ),
          if (widget.controller is TaskViewModel)
            Expanded(
              child: ListenableBuilder(
                listenable: g.taskVm,
                builder: (context, child) {
                  final notes = g.taskVm.taskTimerNotes;
                  if (notes == null || notes.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: scheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes for this task',
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first note to get started',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return TaskNoteItem(
                        task: widget.task,
                        note: notes[index],
                        controller: widget.controller,
                      );
                    },
                  );
                },
              ),
            ),
          // Add button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getSurfaceColor(context),
              border: Border(
                top: BorderSide(
                  color: scheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  MiniRouter.to(context, AddNotePage(edit: false, isTaskNote: true, task: widget.task,));
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Write a note',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
