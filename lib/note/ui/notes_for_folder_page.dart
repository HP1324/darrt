import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/note/ui/add_note_page.dart';
import 'package:minimaltodo/note/ui/note_item.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class NotesForFolderPage extends StatefulWidget {
  const NotesForFolderPage({super.key, required this.folder});
  final Folder folder;
  @override
  State<NotesForFolderPage> createState() => _NotesForFolderPageState();
}

class _NotesForFolderPageState extends State<NotesForFolderPage> {
  @override
  void dispose() {
    g.noteVm.selectedItemIds.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.noteVm,
      builder: (context, child) {
        final notes = g.noteVm.notes.where((n) => n.folders.contains(widget.folder)).toList();
        final color =
            IconColorStorage.colors[widget.folder.color] ?? Theme.of(context).colorScheme.primary;
        final icon = IconColorStorage.flattenedIcons[widget.folder.icon];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: isDark
              ? Color.lerp(Theme.of(context).colorScheme.surface, color, 0.05)
              : Color.lerp(Colors.white, color, 0.03),
          appBar: AppBar(
            title: Text(widget.folder.name),
            backgroundColor: color.withAlpha(25),
          ),
          body: Builder(
            builder: (context) {
              if (notes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: getIconSize(context)),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  const SizedBox(height: 15),
                  if (g.noteVm.selectedItemIds.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            g.noteVm.clearSelection();
                          },
                          icon: Icon(Icons.cancel),
                        ),
                        IconButton(
                          onPressed: () {
                            g.noteVm.deleteMultipleItems();
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  Expanded(
                    child: Scrollbar(
                      thickness: 7,
                      child: CustomScrollView(
                        slivers: [
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
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => MiniRouter.to(context, AddNotePage(edit: false, folder: widget.folder)),
            backgroundColor: IconColorStorage.colors[widget.folder.color],
            tooltip: 'Add note to this folder',
            label: Text('Add note'),
            icon: Icon(Icons.add),
          ),
        );
      },
    );
  }

  double getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    double iconSize = screenWidth * 0.2;

    return iconSize.clamp(60.0, 120.0);
  }
}