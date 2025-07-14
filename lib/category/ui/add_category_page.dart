import 'package:flutter/material.dart';
import 'package:minimaltodo/app/services/mini_box.dart';
import 'package:minimaltodo/app/ui/icon_color_picker.dart';
import 'package:minimaltodo/category/models/task_category.dart';
import 'package:minimaltodo/category/state/category_state_controller.dart';
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/helpers/messages.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:toastification/toastification.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key, required this.edit, this.category})
    : assert(!edit || category != null);
  final bool edit;
  final TaskCategory? category;
  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  @override
  void initState() {
    super.initState();
    g.catSc.initState(widget.edit, widget.edit ? widget.category : null);
    g.adsController.initializeFullPageAdOnAddCategoryPagePop();
  }

  @override
  void dispose() {
    super.dispose();
    g.catSc.clearState();
  }

  Future<void> showFullPageAd() async {
    final popCount = MiniBox().read('add_category_pop_count') ?? 0;
    if (popCount.isEven) {
      await g.adsController.fullPageAdOnAddCategoryPagePop.show();
    }
    MiniBox().write('add_category_pop_count', popCount + 1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return ListenableBuilder(
      listenable: g.catSc,
      builder: (context, child) {
        final categoryColor = IconColorStorage.colors[g.catSc.color] ?? scheme.primary;
        return PopScope(
          onPopInvokedWithResult: (_, __) async {
              await showFullPageAd();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.edit ? widget.category!.name : 'Add Category'),
              backgroundColor: categoryColor.withValues(alpha: 0.1),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        selectionHandleColor: categoryColor,
                      ),
                    ),
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: g.catSc.textController,
                      autofocus: true,
                      cursorColor: categoryColor,
                      decoration: InputDecoration(
                        hintText: 'Enter Category Name Here',
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: categoryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: categoryColor, width: 2),
                        ),
                        border: OutlineInputBorder(borderSide: BorderSide(color: categoryColor)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Customize Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListenableBuilder(
                    listenable: g.catSc,
                    builder: (context, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: SelectionTile(
                              borderColor: categoryColor.withValues(alpha: 0.6),
                              title: 'Icon',
                              selectedValue: g.catSc.icon,
                              onTap: () => showIconPicker(
                                context,
                                onIconSelected: (icon) {
                                  g.catSc.setIcon(icon);
                                  Navigator.pop(context);
                                },
                              ),
                              builder: (context) {
                                final iconData = IconColorStorage.flattenedIcons[g.catSc.icon];
                                return Icon(
                                  iconData ?? Icons.folder,
                                  size: 28,
                                  color: IconColorStorage.colors[g.catSc.color] ?? scheme.primary,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SelectionTile(
                              borderColor: categoryColor.withValues(alpha: 0.6),
                              title: 'Color',
                              selectedValue: g.catSc.color,
                              onTap: () => showColorPicker(
                                context,
                                onColorSelected: (color) {
                                  g.catSc.setColor(color);
                                  Navigator.pop(context);
                                },
                              ),
                              builder: (context) {
                                final selectedColor =
                                    IconColorStorage.colors[g.catSc.color] ??
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
              listenable: g.catSc,
              builder: (context, child) {
                return FloatingActionButton(
                  onPressed: () {
                    final category = g.catSc.buildModel(edit: widget.edit, model: widget.category);
                    final message = g.catVm.putItem(category, edit: widget.edit);
                    if (message != Messages.mFolderEmpty) {
                      showToast(context, type: ToastificationType.success, description: message);
                      Navigator.pop(context);
                    } else {
                      showToast(context, type: ToastificationType.error, description: message);
                    }
                  },
                  backgroundColor: IconColorStorage.colors[g.catSc.color],
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
