import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart' show showToast;
import 'package:minimaltodo/note/models/folder.dart';
import 'package:minimaltodo/note/ui/add_folder_page.dart';
import 'package:minimaltodo/note/ui/notes_for_folder_page.dart';
import 'package:toastification/toastification.dart' show ToastificationType;

class FolderItem extends StatefulWidget {
  const FolderItem({super.key, required this.folder});
  final Folder folder;
  @override
  State<FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<FolderItem> {
  @override
  Widget build(BuildContext context) {
    final color =
        IconColorStorage.colors[widget.folder.color] ?? Theme.of(context).colorScheme.primary;
    final icon = IconColorStorage.flattenedIcons[widget.folder.icon] ?? Icons.folder_outlined;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(60)),
        color: Theme.of(context).colorScheme.surface.withAlpha(100),
      ),
      child: ListTile(
        onTap: () {
          MiniRouter.to(context, NotesForFolderPage(folder: widget.folder));
        },
        leading: Icon(icon, color: color),
        title: Text(widget.folder.name),
        trailing: widget.folder.id != 1
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: () {
                      MiniRouter.to(context, AddFolderPage(edit: true, folder: widget.folder));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 8),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text('Are you sure you want to delete the category?'),
                          actions: [
                            FilledButton(
                              onPressed: () async {
                                final message = g.folderVm.deleteItem(widget.folder.id);
                                showToast(
                                  context,
                                  type: ToastificationType.success,
                                  description: message,
                                );
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Theme.of(context).colorScheme.error,
                                ),
                              ),
                              child: const Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
