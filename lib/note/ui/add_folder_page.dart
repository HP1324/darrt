import 'package:darrt/app/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/ui/icon_color_picker.dart';
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/note/models/folder.dart';
import 'package:darrt/note/state/folder_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;

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
  void dispose() {
    super.dispose();
    g.folderSc.clearState();
  }

  Future<void> showFullPageAd() async {
    if(g.adsController.isFullPageOnAddFolderPagePopAdLoaded) {
      final popCount = MiniBox().read('add_folder_pop_count') ?? 0;
      if (popCount % 2 == 0) {
        await g.adsController.fullPageAdOnAddFolderPagePop.show();
      }
      MiniBox().write('add_folder_pop_count', popCount + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return ListenableBuilder(
      listenable: g.folderSc,
      builder: (context, child) {
        final folderColor = IconColorStorage.colors[g.folderSc.color] ?? scheme.primary;
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
                  Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(selectionHandleColor: folderColor),
                    ),
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: g.folderSc.textController,
                      autofocus: true,
                      cursorColor: folderColor,
                      decoration: InputDecoration(
                        hintText: 'Enter Folder Name Here',
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: folderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: folderColor, width: 2),
                        ),
                        border: OutlineInputBorder(borderSide: BorderSide(color: folderColor)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Customize Folder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: g.folderSc,
                    builder: (context, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: SelectionTile(
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
                                  color:
                                      IconColorStorage.colors[g.folderSc.color] ?? scheme.primary,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SelectionTile(
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
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            floatingActionButton: ListenableBuilder(
              listenable: g.folderSc,
              builder: (context, child) {
                return FloatingActionButton(
                  onPressed: () {
                    final folder = g.folderSc.buildModel(edit: widget.edit, model: widget.folder);
                    final message = g.folderVm.putItem(folder, edit: widget.edit);
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
}
