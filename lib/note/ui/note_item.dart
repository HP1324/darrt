import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart' show formatDateAndTime, formatTime;
import 'package:darrt/note/models/note.dart';
import 'package:darrt/note/ui/add_note_page.dart';
import 'package:flutter/material.dart';

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
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.noteVm,
      builder: (context, child) {
        final scheme = context.colorScheme;
        final textTheme = context.textTheme;
        final note = g.noteVm.notes.firstWhere((t) => t.id == widget.note.id);
        final isSelected = g.noteVm.selectedItemIds.contains(widget.note.id);

        initialContent = _extractInitialContent(note);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: scheme.outline.withAlpha(isSelected ? 255 : 60),
            ),
            color: isSelected
                ? scheme.outline.withAlpha(150)
                : scheme.outline.withAlpha(13),
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
                  MiniRouter.to(
                    context,
                    AddNotePage(edit: true, note: widget.note),
                  );
                } else {
                  g.noteVm.toggleSelection(widget.note.id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      initialContent,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        final updatedAt = note.updatedAt!;
                        final isToday = updatedAt.isSameDay(now);
                        final isYesterday = updatedAt.isSameDay(
                          now.subtract(const Duration(days: 1)),
                        );

                        final timeOfDay = TimeOfDay.fromDateTime(updatedAt);
                        final lastUpdatedText = isToday || isYesterday
                            ? '${isYesterday ? 'Yesterday' : 'Today'} ${formatTime(timeOfDay)}'
                            : formatDateAndTime(updatedAt, 'dd/M/yyyy');
                        return FittedBox(
                          child: Text(
                            'Updated: $lastUpdatedText',
                            style: textTheme.labelSmall?.copyWith(),
                          ),
                        );
                      },
                    ),
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
