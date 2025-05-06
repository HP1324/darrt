import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/category/logic/category_state_controller.dart';
import 'package:minimaltodo/category/logic/category_view_model.dart';
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:provider/provider.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key, required this.edit, this.category}) : assert(!edit || category != null);
  final bool edit;
  final CategoryModel? category;
  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  late final CategoryStateController controller;

  @override
  void initState() {
    super.initState();
      context.read<CategoryStateController>().initCategoryState(widget.edit,widget.category!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = context.read<CategoryStateController>();
  }

  @override
  void dispose() {
    controller.clearCategoryState();
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
              controller: controller.nameController,
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
            Consumer<CategoryStateController>(
              builder: (context, controller, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _SelectionTile(
                        title: 'Icon',
                        selectedValue: controller.icon,
                        onTap: () => _showIconPicker(context),
                        builder: (context) {
                          final iconData = IconColorStorage.flattenedIcons[controller.icon];
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
                      child: _SelectionTile(
                        title: 'Color',
                        selectedValue: controller.color,
                        onTap: () => _showColorPicker(context),
                        builder: (context) {
                          final selectedColor = IconColorStorage.colors[controller.color] ??
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
          CategoryModel category = controller.buildCategory(edit: widget.edit, category: widget.category);
          final message = context.read<CategoryViewModel>().putCategory(category, edit: widget.edit);
          Navigator.pop(context);
        },
        child: const Icon(Icons.done),
      ),
    );
  }

  void _showIconPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => IconPickerDialog(
        onIconSelected: (iconKey) {
          controller.setIcon(iconKey);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        onColorSelected: (colorKey) {
          controller.setColor(colorKey);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String title;
  final String selectedValue;
  final VoidCallback onTap;
  final Widget Function(BuildContext) builder;

  const _SelectionTile({
    required this.title,
    required this.selectedValue,
    required this.onTap,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            builder(context),
            const SizedBox(height: 8),
            Text(
              selectedValue.replaceAll('_', ' '),
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class IconPickerDialog extends StatefulWidget {
  final Function(String) onIconSelected;

  const IconPickerDialog({super.key, required this.onIconSelected});

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: IconColorStorage.icons.length + 1, // +1 for "All" tab
      vsync: this,
    );

    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Filter icons based on search query
  Map<String, dynamic> getFilteredIcons(Map<String, dynamic> icons) {
    if (_searchQuery.isEmpty) return icons;

    return Map.fromEntries(
        icons.entries.where((entry) =>
            entry.key.toLowerCase().contains(_searchQuery)
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAllIcons = getFilteredIcons(IconColorStorage.flattenedIcons);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Icon',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search icons...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              const Tab(text: 'All'),
              ...IconColorStorage.icons.keys.map((category) => Tab(text: category)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIconGrid(filteredAllIcons),
                ...IconColorStorage.icons.keys.map((category) =>
                    _buildIconGrid(getFilteredIcons(IconColorStorage.icons[category]!))
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconGrid(Map<String, dynamic> icons) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final iconKey = icons.keys.elementAt(index);
        final iconData = icons[iconKey];

        return InkWell(
          onTap: () => widget.onIconSelected(iconKey),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, size: 24),
                const SizedBox(height: 4),
                Text(
                  iconKey.replaceAll('_', ' '),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ColorPickerDialog extends StatelessWidget {
  final Function(String) onColorSelected;

  const ColorPickerDialog({super.key, required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Color',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: IconColorStorage.colors.entries.map((entry) {
                    return InkWell(
                      onTap: () => onColorSelected(entry.key),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.1),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.key.replaceAll('_', ' '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

