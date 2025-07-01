import 'package:flutter/material.dart';
import 'package:minimaltodo/app/ui/icon_color_picker.dart';
import 'package:minimaltodo/category/models/category_model.dart';
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
  final CategoryModel? category;
  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  @override
  void initState() {
    super.initState();
    g.catSc.initState(widget.edit, widget.edit ? widget.category! : null);
  }

  @override
  void dispose() {
    g.catSc.clearState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? 'Edit Category' : 'Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: g.catSc.textController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter Category Name Here',
                border: OutlineInputBorder(),
                filled: true,
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
                        title: 'Icon',
                        selectedValue: g.catSc.icon,
                        onTap: () => showIconPicker(context, onIconSelected: (icon){
                          g.catSc.setIcon(icon);
                          Navigator.pop(context);
                        }),
                        builder: (context) {
                          final iconData = IconColorStorage.flattenedIcons[g.catSc.icon];
                          return Icon(
                            iconData ?? Icons.folder,
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SelectionTile(
                        title: 'Color',
                        selectedValue: g.catSc.color,
                        onTap: () => showColorPicker(context,onColorSelected: (color){
                          g.catSc.setColor(color);
                          Navigator.pop(context);
                        }),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CategoryModel category = g.catSc.buildModel(edit: widget.edit, model: widget.category);
          final message = g.catVm.putItem(category, edit: widget.edit);
          if (message == Messages.mCategoryExists) {
            showToast(context, type: ToastificationType.error, description: message);
          } else if(message == Messages.mCategoryEmpty){
            showToast(context, type: ToastificationType.error, description: message);
          } else{
            showToast(context, type: ToastificationType.success, description: message);
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.done),
      ),
    );
  }

}


