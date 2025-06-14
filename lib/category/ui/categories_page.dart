import 'package:flutter/material.dart';
import 'package:minimaltodo/category/ui/add_category_page.dart';
import 'package:minimaltodo/category/ui/category_item.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final _focusNode = FocusNode();

  @override
  void dispose() {
    debugPrint('Categories page dispose called');
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search header with toggle button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddCategoryPage(edit: false)));
                  },
                  leading: Icon(Icons.list_alt_sharp),
                  title: Text('Add New Category'),
                  trailing: Icon(Icons.add),
                ),
              ),
              // Search toggle button
              IconButton(
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                      _searchQuery = '';
                      _focusNode.unfocus();
                    } else {
                      _focusNode.requestFocus();
                    }
                  });
                },
                icon: Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: _showSearch ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),

        // Search TextField with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showSearch ? 60 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showSearch ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                maxLines: null,
                autofocus: false,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  hintText: 'Search categories...',
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
        ),

        ListenableBuilder(
          listenable: g.catVm,
          builder: (context, child) {
            final categories = g.catVm.categories;

            // Filter categories based on search query
            final filteredCategories = categories.where((category) {
              if (_searchQuery.isEmpty) return true;
              return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return Expanded(
              child: Builder(
                builder: (context) {
                  if (filteredCategories.isEmpty && _searchQuery.isNotEmpty) {
                    return CategoriesEmptyWidget();
                  }
                  return ListView.builder(
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final c = filteredCategories[index];
                      return CategoryItem(category: c);
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class CategoriesEmptyWidget extends StatelessWidget {
  const CategoriesEmptyWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
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
    );
  }
}
