import 'package:flutter/material.dart';
import 'package:minimaltodo/app_router.dart';
import 'package:minimaltodo/view_models/general_view_model.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/views/widgets/custom_text_field.dart';
import 'package:minimaltodo/views/widgets/category_item.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  FocusNode _focusNode = FocusNode();
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CategoryViewModel, TaskViewModel,GeneralViewModel>(
      builder: (context, categoryVM, taskVM,generacategoryVM, _) {
        final categories = categoryVM.categories;

        // Filter categories based on search query
        final filteredcategories = categories.where((list) {
          if (_searchQuery.isEmpty) return true;
          return list.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        }).toList();

        return SingleChildScrollView(
          controller: categoryVM.categoryScrollController,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All categories',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showSearch = !_showSearch;
                              if (!_showSearch) {
                                _searchController.clear();
                                _searchQuery = '';
                                _focusNode.unfocus();
                              }else{
                                _focusNode.requestFocus();
                              }
                            });
                          },
                          icon: Icon(
                            _showSearch ? Icons.close : Iconsax.search_normal,
                            color: _showSearch ? Colors.red : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => AppRouter.to(context, child: NewListPage(editMode: false)),
                          icon: const Icon(Iconsax.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Search TextField
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _showSearch ? 60 : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showSearch ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomTextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      isMaxLinesNull: false,
                      autoFocus: false,
                      hintText: 'Search categories...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value ?? '';
                        });
                      },
                    ),
                  ),
                ),
              ),
              // categories Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: filteredcategories.isEmpty
                    ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.search_normal,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No categories found',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisExtent: 100),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredcategories.length,
                  itemBuilder: (context, index) {
                    final list = filteredcategories[index];
                    return CategoryItem(list: list);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}