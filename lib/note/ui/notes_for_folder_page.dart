import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/state/folder_view_model.dart';
import 'package:minimaltodo/note/state/note_view_model.dart';
import 'package:minimaltodo/note/ui/note_item.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart' show ToastificationType;

class NotesForFolderPage extends StatefulWidget {
  const NotesForFolderPage({super.key, required this.folder});
  final Folder folder;
  @override
  State<NotesForFolderPage> createState() => _NotesForFolderPageState();
}

class _NotesForFolderPageState extends State<NotesForFolderPage> {
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_,__){
        context.read<NoteViewModel>().clearSelection();
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            Consumer<NoteViewModel>(
              builder: (context, noteVm, _) {
                final ids = noteVm.selectedItemIds;
                return SliverAppBar(
                  leading: BackButton(),
                  title: Text(widget.folder.name),
                  pinned: true,
                  actions: [
                    if (ids.isNotEmpty) ...[
                      IconButton(
                        onPressed: () {
                          noteVm.clearSelection();
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
                              content: Text('Delete ${ids.length > 1 ? '${ids.length} notes' : '1 note'}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    message = noteVm.deleteMultipleItems();
                                    showToast(context, type: ToastificationType.success, description: message);
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
              }
            ),
            Consumer<NoteViewModel>(builder: (context, noteVM, _) {
              final notes = noteVM.notes.where((n) => n.folders.contains(widget.folder)).toList();
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
            }),
          ],
        )
      ),
    );
  }
}
