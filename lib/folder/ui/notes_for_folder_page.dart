import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/folder/models/folder.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/note/ui/add_note_page.dart';
import 'package:darrt/note/ui/note_item.dart';
import 'package:flutter/material.dart';

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
        final notes = g.noteVm.notes.forFolder(widget.folder);
        final color =
            IconColorStorage.colors[widget.folder.color] ?? Theme.of(context).colorScheme.primary;
        final icon = IconColorStorage.flattenedIcons[widget.folder.icon];
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final ids = g.noteVm.selectedItemIds;
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
                  if (ids.isNotEmpty)
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
                          onPressed: () async {
                            var message = '';
                            await showDialog(
                              context: context,
                              builder: (innerContext) => AlertDialog(
                                title: const Text('Delete Notes'),
                                content: Text(
                                  'Delete ${ids.length > 1 ? '${ids.length} notes' : '1 note'}?',
                                ),
                                actions: [
                                  FilledButton(
                                    onPressed: () {
                                      message = g.noteVm.deleteMultipleItems();
                                      Navigator.pop(context);
                                      if (mounted) {
                                        showSuccessToast(context, message);
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        ColorScheme.of(context).error,
                                      ),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.delete),
                          tooltip: 'Delete selected notes',
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
                            sliver: SliverGrid.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  mainAxisExtent: MediaQuery.sizeOf(context).height * 0.16
                              ),
                              itemCount: notes.length,
                              itemBuilder: (context, index) {
                                final note = notes[index];
                                return NoteItem(note: note);
                              },
                            ),
                          ),
                          SliverToBoxAdapter(child:const SizedBox(height: 100)),
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