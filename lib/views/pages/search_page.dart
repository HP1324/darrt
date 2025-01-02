import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/task_item.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedPriority;
  bool _showFilters = false;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      // Title, Priority and Category search
      if (_searchQuery.isNotEmpty) {
        bool matchesTitle = task.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        bool matchesPriority = task.priority?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        bool matchesCategory = task.category?.categoryName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        
        if (!matchesTitle && !matchesPriority && !matchesCategory) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null) {
        if (_selectedCategory == 'General') {
          if (task.category != null && task.category!.categoryName != 'General') {
            return false;
          }
        } else {
          if (task.category?.categoryName?.toLowerCase() != _selectedCategory?.toLowerCase()) {
            return false;
          }
        }
      }

      // Priority filter
      if (_selectedPriority != null) {
        if (task.priority == null) {
          return _selectedPriority?.toLowerCase() == 'low';
        }
        return task.priority?.toLowerCase() == _selectedPriority?.toLowerCase();
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background50,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.filter_list, color: AppTheme.primary),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskVM, _) {
          // Get all categories including 'General'
          final allCategories = ['General']..addAll(
            taskVM.tasks
                .map((task) => task.category?.categoryName)
                .where((name) => name != null && name != 'General')
                .toSet()
                .cast<String>()
          );

          final filteredTasks = _filterTasks(taskVM.tasks);

          return Column(
            children: [
              if (_showFilters) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Category Filter
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All Categories'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                          ),
                          ...allCategories.map((category) => FilterChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = selected ? category : null;
                                  });
                                },
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Priority Filter
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All Priorities'),
                            selected: _selectedPriority == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedPriority = null;
                              });
                            },
                          ),
                          ..._priorities.map((priority) => FilterChip(
                                label: Text(priority),
                                selected: _selectedPriority == priority,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedPriority = selected ? priority : null;
                                  });
                                },
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppTheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks found',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return TaskItem(task: task);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
