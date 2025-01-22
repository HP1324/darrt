import 'package:flutter/material.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:provider/provider.dart';

class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(

                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Text(
                    'Choose an Icon',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(16),
              child: Consumer2<CategoryViewModel,GeneralViewModel>(
                builder: (context, categoryVM,generacategoryVM ,_) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: CategoryService.icons.length,
                    itemBuilder: (context, index) {
                      final iconCode = CategoryService.icons.keys.elementAt(index);
                      final icon = CategoryService.icons.values.elementAt(index);
                      final isSelected = categoryVM.selectedIcon == iconCode;

                      return InkWell(
                        onTap: () {
                          categoryVM.updateSelectedIcon(iconCode);
                          Navigator.pop(context);
                          generacategoryVM.textFieldNode.unfocus();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary.withAlpha(50)
                                : null,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
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
