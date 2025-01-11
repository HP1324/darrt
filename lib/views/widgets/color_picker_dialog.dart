import 'package:flutter/material.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:provider/provider.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    'Choose a Color',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          Theme.of(context).textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              padding: const EdgeInsets.all(16),
              child: Consumer3<ListViewModel,TaskViewModel,GeneralViewModel>(
                builder: (context, listVM,taskVM,generalVM, _) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: ListService.listColors.length,
                    itemBuilder: (context, index) {
                      final colorKey =
                          ListService.listColors.keys.elementAt(index);
                      final color =
                          ListService.listColors.values.elementAt(index);
                      final isSelected = listVM.selectedColor == colorKey;

                      return InkWell(
                        onTap: () {
                          listVM.updateSelectedColor(colorKey,taskVM );
                          Navigator.pop(context);
                          generalVM.textFieldNode.unfocus();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
