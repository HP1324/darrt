import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart' show formatDate, formatDateAndTime, formatTime;
import 'package:minimaltodo/note/models/note.dart';
import 'package:minimaltodo/note/state/note_state_controller.dart';
import 'package:minimaltodo/note/state/note_view_model.dart';
import 'package:minimaltodo/note/ui/add_note_page.dart';
import 'package:provider/provider.dart'; // Import your Note model here

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
    final controller = note.toQuillController();
    final text = controller.document.toPlainText();
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<NoteViewModel>(builder: (context, noteVM, _) {
      final note = noteVM.notes.firstWhere((t) => t.id == widget.note.id);
      initialContent = _extractInitialContent(note);
      final isSelected = noteVM.selectedItemIds.contains(widget.note.id);
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
              context.read<NoteViewModel>().toggleSelection(widget.note.id);
            },
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final ids = context.read<NoteViewModel>().selectedItemIds;
              if (ids.isEmpty) {
                MiniRouter.to(context, AddNotePage(edit: true, note: widget.note));
              } else {
                context.read<NoteViewModel>().toggleSelection(widget.note.id);
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
                    final isYesterday = DateUtils.isSameDay(DateTime.now().subtract(const Duration(days: 1)), updatedAt);
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
    });
  }
}
