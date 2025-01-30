import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/widgets/color_picker_dialog.dart';
import 'package:minimaltodo/views/widgets/icon_picker_dialog.dart';
import 'package:provider/provider.dart';

class NewListPage extends StatefulWidget {
  const NewListPage({super.key, required this.editMode, this.listToEdit});

  final bool editMode;
  final CategoryModel? listToEdit;

  @override
  State<NewListPage> createState() => _NewListPageState();
}

class _NewListPageState extends State<NewListPage> {
  final TextEditingController textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = Provider.of<CategoryViewModel>(context, listen: false);
    final tvm = Provider.of<TaskViewModel>(context, listen: false);

    if (widget.editMode!) {
      categoryVM.currentCategory = widget.listToEdit!;
    }

    return PopScope(
      onPopInvokedWithResult: (_, __) async {
        logger.i('Pop called');
        if (widget.editMode!) {
          final edited = await categoryVM.editCategory();
          tvm.updateTaskListAfterEdit(widget.listToEdit!);
          if (edited) {
            // showToast(title: 'List Edited');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text(widget.editMode ? widget.listToEdit!.name!:'New Category', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Category Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if(!widget.editMode)...[
                  const Text(
                    'Create a new category to organize your tasks better',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ],
                  Hero(
                    tag: 'category_field',
                    child: TextField(
                      controller: textController,
                      focusNode: _focusNode,
                      maxLines: null,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'e.g., Work, Shopping, Personal',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      onChanged: (value) {
                        categoryVM.name = textController.text;
                      },
                    ),
                  ),
                  // Rest of the widgets remain the same
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Consumer<CategoryViewModel>(
                      builder: (context, categoryVM, _) {
                        return ListTile(
                          onTap: () async {
                            _focusNode.unfocus();
                            await Future.delayed(const Duration(milliseconds: 100));
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (_) => const IconPickerDialog(),
                              );
                            }
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              CategoryService.getIcon(categoryVM.selectedIcon),
                            ),
                          ),
                          title: Text(
                            'Choose Icon',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Consumer<CategoryViewModel>(
                      builder: (context, categoryVM, _) {
                        return ListTile(
                          onTap: () async {
                            _focusNode.unfocus();
                            await Future.delayed(const Duration(milliseconds: 100));
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (_) => const ColorPickerDialog(),
                              );
                            }
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: categoryVM.selectedColor != null
                                  ? CategoryService.categoryColors[categoryVM.selectedColor]!.withAlpha(50)
                                  : Theme.of(context).colorScheme.primary.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.color_lens,
                              color: categoryVM.selectedColor != null ? CategoryService.categoryColors[categoryVM.selectedColor] : null,
                            ),
                          ),
                          title: Text(
                            'Choose Color',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.chevron_right),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final nav = Navigator.of(context);
            if (!widget.editMode!) {
              final success = await categoryVM.addNewCategory();
              final scrollController = categoryVM.categoryScrollController;
              if (success) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
                nav.pop();
              }
            } else {
              final edited = await categoryVM.editCategory();
              if (edited) {
                tvm.updateTaskListAfterEdit(widget.listToEdit!);
                nav.pop();
              }
            }
          },
          child: Icon(Icons.done),
        ),
      ),
    );
  }
}
