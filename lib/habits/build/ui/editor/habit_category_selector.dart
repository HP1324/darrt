import 'package:darrt/category/ui/add_category_page.dart';
import 'package:darrt/category/ui/category_chip.dart';
import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class HabitCategorySelector extends StatelessWidget {
  const HabitCategorySelector({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = ColorScheme.of(context);
    return InkWell(
      onTap: () {
        g.buildHabitSc.textFieldNode.unfocus();
        _showCategorySelectionBottomSheet(context);
      },
      child: Row(
        children: [
          Icon(Icons.category_outlined, color: getColorFromString(g.buildHabitSc.color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(fontSize: textTheme.labelLarge!.fontSize),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.03,
                  child: ListenableBuilder(
                    listenable: g.buildHabitSc,
                    builder: (context, child) {
                      final map = g.buildHabitSc.categorySelection;
                      final categories = map.entries
                          .where((e) => e.value)
                          .map((e) => e.key)
                          .toList();
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        separatorBuilder: (context, index) => const SizedBox(width: 2),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryChip(category: category);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              g.buildHabitSc.textFieldNode.unfocus();
              _showCategorySelectionBottomSheet(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _showCategorySelectionBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            ListTile(
              onTap: () => MiniRouter.to(context, AddCategoryPage(edit: false)),
              title: const Text(
                'Create New Category',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add),
              ),
              trailing: const Icon(Icons.list_alt),
            ),
            Expanded(
              child: Scrollbar(
                thickness: 8,
                radius: const Radius.circular(4),
                child: ListenableBuilder(
                  listenable: Listenable.merge([g.buildHabitSc, g.taskVm]),
                  builder: (context, child) => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: g.catVm.categories.length,
                    itemBuilder: (_, index) {
                      final cat = g.catVm.categories[index];
                      final map = g.buildHabitSc.categorySelection;
                      return ListTile(
                        selected: map[cat] ?? false,
                        selectedColor: IconColorStorage.colors[cat.color],
                        leading: Icon(IconColorStorage.flattenedIcons[cat.icon]),
                        trailing: Checkbox(
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return IconColorStorage.colors[cat.color];
                            }
                            return null;
                          }),
                          value: map[cat] ?? false,
                          onChanged: (selected) {
                            if (selected != null) {
                              g.buildHabitSc.setCategory(cat, selected);
                            }
                          },
                        ),
                        title: Text(
                          cat.name,
                          style: const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
