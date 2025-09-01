import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/app/ui/icon_color_picker.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:darrt/note/state/folder_state_controller.dart';
import 'package:flutter/material.dart';

class AddFolderPage extends StatefulWidget {
  const AddFolderPage({super.key, required this.edit, this.folder})
    : assert(!edit || folder != null);
  final bool edit;
  final Folder? folder;

  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  @override
  void initState() {
    super.initState();
    g.folderSc.initState(widget.edit, widget.edit ? widget.folder : null);
    g.adsController.initializeFullPageOnAddFolderPagePopAd();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.folderSc,
      builder: (context, child) {
        final scheme = context.colorScheme;
        final textTheme = context.textTheme;
        final folderColor =
            IconColorStorage.colors[g.folderSc.color] ?? scheme.primary;
        return PopScope(
          onPopInvokedWithResult: (_, __) async {
            await showFullPageAd();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.edit ? widget.folder!.name : 'Add Folder'),
              backgroundColor: folderColor.withValues(alpha: 0.1),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _FolderTextFormField(folderColor: folderColor),
                  const SizedBox(height: 24),
                  Text('Customize Folder', style: textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    spacing: 16,
                    children: [
                      Expanded(child: _IconSelector(folderColor: folderColor)),
                      Expanded(child: _ColorSelector(folderColor: folderColor)),
                    ],
                  ),
                ],
              ),
            ),
            floatingActionButton: ListenableBuilder(
              listenable: g.folderSc,
              builder: (context, child) {
                return FloatingActionButton(
                  onPressed: () {
                    final folder = g.folderSc.buildModel(
                      edit: widget.edit,
                      model: widget.folder,
                    );
                    final message = g.folderVm.putItem(
                      folder,
                      edit: widget.edit,
                    );
                    if (message != Messages.mFolderEmpty) {
                      showSuccessToast(context, message);
                      Navigator.pop(context);
                    } else {
                      showErrorToast(context, message);
                    }
                  },
                  backgroundColor: IconColorStorage.colors[g.folderSc.color],
                  child: const Icon(Icons.done),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    g.folderSc.clearState();
  }

  Future<void> showFullPageAd() async {
    if (g.adsController.isFullPageOnAddFolderPagePopAdLoaded) {
      final popCount = MiniBox().read('add_folder_pop_count') ?? 0;
      if (popCount % 2 == 0) {
        await g.adsController.fullPageAdOnAddFolderPagePop.show();
      }
      MiniBox().write('add_folder_pop_count', popCount + 1);
    }
  }
}

class _FolderTextFormField extends StatefulWidget {
  const _FolderTextFormField({required this.folderColor});

  final Color folderColor;

  @override
  State<_FolderTextFormField> createState() => _FolderTextFormFieldState();
}

class _FolderTextFormFieldState extends State<_FolderTextFormField> {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = g.folderSc.name;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: widget.folderColor,
          selectionColor: widget.folderColor.withValues(alpha: 0.35),
        ),
      ),
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        controller: nameController,
        autofocus: true,
        cursorColor: widget.folderColor,
        onChanged: (value) {
          g.folderSc.setName(value);
        },
        decoration: InputDecoration(
          hintText: 'Enter Folder Name Here',
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.folderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.folderColor, width: 2),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: widget.folderColor),
          ),
        ),
      ),
    );
  }
}

class _IconSelector extends StatelessWidget {
  const _IconSelector({required this.folderColor});

  final Color folderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return SelectionTile(
      borderColor: folderColor.withValues(alpha: 0.6),
      title: 'Icon',
      selectedValue: g.folderSc.icon,
      onTap: () => showIconPicker(
        context,
        onIconSelected: (icon) {
          g.folderSc.setIcon(icon);
          Navigator.pop(context);
        },
      ),
      builder: (context) {
        final iconData = IconColorStorage.flattenedIcons[g.folderSc.icon];
        return Icon(
          iconData ?? Icons.folder,
          size: 28,
          color: IconColorStorage.colors[g.folderSc.color] ?? scheme.primary,
        );
      },
    );
  }
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({required this.folderColor});

  final Color folderColor;

  @override
  Widget build(BuildContext context) {
    return SelectionTile(
      borderColor: folderColor.withValues(alpha: 0.6),
      title: 'Color',
      selectedValue: g.folderSc.color,
      onTap: () => showColorPicker(
        context,
        onColorSelected: (color) {
          g.folderSc.setColor(color);
          Navigator.pop(context);
        },
      ),
      builder: (context) {
        final selectedColor =
            IconColorStorage.colors[g.folderSc.color] ??
            Theme.of(context).colorScheme.primary;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: selectedColor,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
