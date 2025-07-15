import 'package:flutter/material.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart' show formatDateAndTime, formatTime;
import 'package:darrt/note/models/note.dart';
import 'package:darrt/note/ui/add_note_page.dart';

class NoteItem extends StatefulWidget {
  final Note note;

  const NoteItem({super.key, required this.note});

  @override
  State<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  late String initialContent;

  @override
  void initState() {
    super.initState();
    initialContent = _extractInitialContent(widget.note);
  }

  String _extractInitialContent(Note note) {
    final controller = note.quillController;
    final text = controller.document.toPlainText();
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: g.noteVm,
      builder: (context, child) {
        final note = g.noteVm.notes.firstWhere((t) => t.id == widget.note.id);
        initialContent = _extractInitialContent(note);
        final isSelected = g.noteVm.selectedItemIds.contains(widget.note.id);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline.withAlpha(isSelected ? 255 : 60)),
            color: isSelected ? theme.colorScheme.outline.withAlpha(150) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onLongPress: () {
                g.noteVm.toggleSelection(widget.note.id);
              },
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                final ids = g.noteVm.selectedItemIds;
                if (ids.isEmpty) {
                  MiniRouter.to(context, AddNotePage(edit: true, note: widget.note));
                } else {
                  g.noteVm.toggleSelection(widget.note.id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      initialContent,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Builder(builder: (context) {
                      final updatedAt = note.updatedAt!;
                      final isToday = DateUtils.isSameDay(DateTime.now(), updatedAt);
                      final isYesterday = DateUtils.isSameDay(
                          DateTime.now().subtract(const Duration(days: 1)), updatedAt);
                      final timeOfDay = TimeOfDay.fromDateTime(updatedAt);
                      final lastUpdatedText = isToday || isYesterday
                          ? '${isYesterday ? 'Yesterday' : 'Today'} ${formatTime(timeOfDay)}'
                          : formatDateAndTime(updatedAt, 'dd/M/yyyy');
                      return FittedBox(
                          child: Text(
                        'Modified: $lastUpdatedText',
                        style: theme.textTheme.labelSmall?.copyWith(),
                      ));
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
