import 'package:flutter/material.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:darrt/note/ui/add_folder_page.dart';
import 'package:darrt/note/ui/notes_for_folder_page.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:toastification/toastification.dart';

class FolderItem extends StatefulWidget {
  const FolderItem({super.key, required this.folder});

  final Folder folder;

  @override
  State<FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<FolderItem> {
  final GlobalKey _popupKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final color =
        IconColorStorage.colors[widget.folder.color] ?? Theme.of(context).colorScheme.primary;
    final icon = IconColorStorage.flattenedIcons[widget.folder.icon];
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
      child: ListTile(
        onTap: () {
          MiniRouter.to(context, NotesForFolderPage(folder: widget.folder));
        },
        tileColor: scheme.surfaceContainer.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withAlpha(50)),
        ),
        leading: FolderIcon(color: color, icon: icon),
        title: FolderNameLabel(folder: widget.folder, textTheme: textTheme),
        subtitle: NoteCountLabel(folder: widget.folder, textTheme: textTheme),
        trailing: widget.folder.id != 1
            ? FolderPopupMenuButton(popupKey: _popupKey, folder: widget.folder, color: color)
            : null,
      ),
    );
  }
}

class FolderIcon extends StatelessWidget {
  const FolderIcon({super.key, required this.color, required this.icon});

  final Color color;
  final dynamic icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 13),
    );
  }
}

class FolderNameLabel extends StatelessWidget {
  const FolderNameLabel({
    super.key,
    required this.folder,
    required this.textTheme,
  });

  final Folder folder;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      folder.uuid == 'general' ?  '${folder.name} (Default)':folder.name,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: textTheme.titleMedium?.copyWith(),
    );
  }
}

class NoteCountLabel extends StatelessWidget {
  const NoteCountLabel({
    super.key,
    required this.folder,
    required this.textTheme,
  });

  final Folder folder;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.noteVm,
      builder: (context, child) {
        final notes = g.noteVm.notes;
        final count = notes.where((n) => n.folders.contains(folder)).toList().length;
        return Text(
          '$count ${count != 1 ? 'notes' : 'note'}',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: textTheme.labelMedium?.copyWith(),
        );
      },
    );
  }
}

class FolderPopupMenuButton extends StatelessWidget {
  const FolderPopupMenuButton({
    super.key,
    required GlobalKey<State<StatefulWidget>> popupKey,
    required this.folder,
    required this.color,
  }) : _popupKey = popupKey;

  final GlobalKey<State<StatefulWidget>> _popupKey;
  final Folder folder;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: _popupKey,
      onTap: () {
        final (offset, size) = getOffsetAndSize(_popupKey);
        _showFolderMenu(context, offset, size);
      },
      child: Icon(Icons.more_vert),
    );
  }

  Future<dynamic> _showFolderMenu(BuildContext context, Offset offset, Size size) {
    return showMenu(
      context: context,
      position: getRelativeRectFromOffsetAndSize(offset, size),
      items: [
        PopupMenuItem(
          onTap: () {
            MiniRouter.to(context, AddFolderPage(edit: true, folder: folder));
          },
          child: Row(
            children: [
              Icon(Icons.edit, color: color, size: 20),
              const SizedBox(width: 8),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _DeleteFolderDialog(folderId: folder.id),
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
    );
  }
}

class _DeleteFolderDialog extends StatefulWidget {
  const _DeleteFolderDialog({required this.folderId});

  final int folderId;

  @override
  State<_DeleteFolderDialog> createState() => _DeleteFolderDialogState();
}

class _DeleteFolderDialogState extends State<_DeleteFolderDialog> {
  bool deleteNotes = false;
  @override
  void dispose() {
    deleteNotes = false;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to delete the folder?'),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: deleteNotes,
            title: FittedBox(child: Text('Delete notes in this folder?')),
            onChanged: (newValue) {
              setState(() {
                deleteNotes = newValue ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            final message = g.folderVm.deleteItem(widget.folderId, deleteTasks: deleteNotes);
            showToast(context, type: ToastificationType.success, description: message);
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}