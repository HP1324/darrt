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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: g.noteVm,
        builder: (context, child) {
          final ids = g.noteVm.selectedItemIds;
          final notes = g.noteVm.notes;
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
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteItem(note: note);
                  },
                ),
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
