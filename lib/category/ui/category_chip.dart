import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/category/logic/category_view_model.dart';
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:provider/provider.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category});
  final CategoryModel category;
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Consumer<CategoryViewModel>(
      builder: (_,catVM,___) {
        final thisCategory = catVM.categories.firstWhere((c) => c.id == category.id);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: IconColorStorage.colors[thisCategory.color]?.withValues(alpha: 0.1) ?? primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconColorStorage.flattenedIcons[thisCategory.icon],size:12,color: IconColorStorage.colors[thisCategory.color]),
              const SizedBox(width: 4),
              Text(category.name, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        );
      }
    );
  }
}
