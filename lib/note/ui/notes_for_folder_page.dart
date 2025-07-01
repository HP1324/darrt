import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/ui/add_note_page.dart';
import 'package:minimaltodo/note/ui/note_item.dart';
import 'package:toastification/toastification.dart' show ToastificationType;

class NotesForFolderPage extends StatefulWidget {
  const NotesForFolderPage({super.key, required this.folder});
  final Folder folder;
  @override
  State<NotesForFolderPage> createState() => _NotesForFolderPageState();
}

class _NotesForFolderPageState extends State<NotesForFolderPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        g.noteVm.clearSelection();
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            ListenableBuilder(
              listenable: g.noteVm,
              builder: (context, child) {
                final ids = g.noteVm.selectedItemIds;
                return SliverAppBar(
                  leading: BackButton(),
                  title: Text(widget.folder.name),
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
                                'Delete ${ids.length > 1 ? '${ids.length} notes' : '1 note'}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    message = g.noteVm.deleteMultipleItems();
                                    showToast(
                                      context,
                                      type: ToastificationType.success,
                                      description: message,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ],
                );
              },
            ),
            ListenableBuilder(
              listenable: g.noteVm,

              builder: (context, child) {
                final notes = g.noteVm.notes
                    .where((n) => n.folders.contains(widget.folder))
                    .toList();
                return SliverPadding(
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
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => MiniRouter.to(context, AddNotePage(edit: false, folder: widget.folder)),
          backgroundColor: IconColorStorage.colors[widget.folder.color],
          tooltip: 'Add new note to this folder',
          label: Text('Add note'),
          icon: Icon(Icons.add),
        ),
      ),
    );
  }
}
