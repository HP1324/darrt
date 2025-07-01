import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/note/ui/add_note_page.dart';
import 'package:minimaltodo/note/ui/folders_page.dart';
import 'package:minimaltodo/note/ui/note_item.dart';
import 'package:toastification/toastification.dart' show ToastificationType;

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  void dispose() {
    super.dispose();
    g.noteVm.selectedItemIds.clear();
  }

  // Group notes by date
  Map<String, List<dynamic>> _groupNotesByDate(List<dynamic> notes) {
    Map<String, List<dynamic>> groupedNotes = {};

    for (var note in notes) {
      // Assuming note has a createdAt property of type DateTime
      final dateKey = formatDateNoJm(note.createdAt, 'EEE, dd, MMM, yyyy');

      if (groupedNotes[dateKey] == null) {
        groupedNotes[dateKey] = [];
      }
      groupedNotes[dateKey]!.add(note);
    }

    // Sort the map by date (most recent first)
    var sortedEntries = groupedNotes.entries.toList()
      ..sort((a, b) {
        // You might need to parse the date string back to DateTime for proper sorting
        // Or modify this based on how your formatDateNoJm function works
        return b.key.compareTo(a.key);
      });

    return Map.fromEntries(sortedEntries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: g.noteVm,
        builder: (context, child) {
          final ids = g.noteVm.selectedItemIds;
          final notes = g.noteVm.notes;
          final groupedNotes = _groupNotesByDate(notes);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: BackButton(),
                title: Text('Notes'),
                pinned: true,
                actions: [
                  if (ids.isNotEmpty) ...[
                    IconButton(
                      onPressed: () {
                        g.noteVm.clearSelection();
                      },
                      icon: Icon(Icons.cancel),
                    ),
                    IconButton(
                      onPressed: () async {
                        var message = '';
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Notes'),
                            content: Text(
                                'Delete ${ids.length > 1 ? '${ids.length} notes' : '1 note'}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  message = g.noteVm.deleteMultipleItems();
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (context.mounted) {
                          showToast(context,
                              type: ToastificationType.success, description: message);
                        }
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                  IconButton(
                    onPressed: () {
                      g.noteVm.clearSelection();
                      MiniRouter.to(context, FoldersPage());
                    },
                    icon: Icon(Icons.folder_open),
                  ),
                ],
              ),
              // Build grouped sections
              ...groupedNotes.entries.map((entry) {
                final dateLabel = entry.key;
                final notesForDate = entry.value;

                return SliverMainAxisGroup(
                  slivers: [
                    // Date header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    // Notes grid for this date
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childCount: notesForDate.length,
                        itemBuilder: (context, index) {
                          final note = notesForDate[index];
                          return NoteItem(note: note);
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),

              // Add some bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 100), // Space for FAB
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          MiniRouter.to(context, AddNotePage(edit: false));
        },
        shape: StadiumBorder(),
        label: Row(
          children: [
            Icon(Icons.add),
            const SizedBox(width: 8),
            Text('Add Note'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}