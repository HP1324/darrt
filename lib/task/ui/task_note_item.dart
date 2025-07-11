import 'package:flutter/material.dart';
import 'package:minimaltodo/app/services/toast_service.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/note/ui/add_note_page.dart';

class TaskNoteItem extends StatefulWidget {
  const TaskNoteItem({super.key, required this.note});
  final Note note;
  @override
  State<TaskNoteItem> createState() => _TaskNoteItemState();
}

class _TaskNoteItemState extends State<TaskNoteItem> {
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => MiniRouter.to(context, AddNotePage(edit: true, note: widget.note)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Note content icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.sticky_note_2_outlined,
                color: scheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Note text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _extractInitialContent(widget.note),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to edit',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Remove Note',
                          style: textTheme.titleLarge?.copyWith(
                            color: scheme.error,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to remove this note from the task?',
                          style: textTheme.bodyMedium,
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () {
                              g.taskSc.removeNote(widget.note);
                              Navigator.pop(context);
                              showSuccessToast(context, 'Note remove');
                            },
                            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(scheme.error)),
                            child: Text('Remove'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.errorContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: scheme.error,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractInitialContent(Note note) {
    final controller = note.quillController;
    final text = controller.document.toPlainText();
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }
}
