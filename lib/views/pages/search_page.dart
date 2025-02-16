import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/services/task_service.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  CategoryModel? _selectedCategory;
  String? _selectedPriority;
  bool _showFilters = false;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  // Keep track of loaded tasks
  List<Task>? _currentTasks;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Task>> _loadTasks() async {
    if (_searchQuery.isEmpty) {
      return [];
    }

    List<Task> tasks;
    if (_selectedCategory != null) {
      tasks = await TaskService.getCategoryTasks(_selectedCategory!.id!);
    } else {
      // Assuming you have a method to get all tasks
      tasks = await TaskService.getTasks();
    }

    return _filterTasks(tasks);
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      // Title and Priority search
      bool matchesTitle = task.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      bool matchesPriority = task.priority?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;

      if (!matchesTitle && !matchesPriority) {
        return false;
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

  void _updateSearch(String value) {
    setState(() {
      _searchQuery = value;
      // Reset category when search query changes
      if (value.isEmpty) {
        _selectedCategory = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ),
          onChanged: _updateSearch,
        ),
      ),
      body: Column(
        children: [
          if (_showFilters) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by:',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    child: FutureBuilder<List<CategoryModel>>(
                      future: CategoryService.getCategories(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final categories = snapshot.data!;

                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            FilterChip(
                              showCheckmark: false,
                              label: Text(
                                'All Categories',
                                style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.labelMedium!.fontSize
                                ),
                              ),
                              selected: _selectedCategory == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              },
                            ),
                            ...categories.map(
                                  (category) => Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: FilterChip(
                                  showCheckmark: false,
                                  label: Text(
                                    category.name!,
                                    style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.labelMedium!.fontSize
                                    ),
                                  ),
                                  selected: _selectedCategory?.id == category.id,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = selected ? category : null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Wrap(
                    spacing: 7,
                    children: [
                      FilterChip(
                        showCheckmark: false,
                        label: Text(
                          'All Priorities',
                          style: TextStyle(
                              fontSize: Theme.of(context).textTheme.labelMedium!.fontSize
                          ),
                        ),
                        selected: _selectedPriority == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPriority = null;
                          });
                        },
                      ),
                      ..._priorities.map((priority) => FilterChip(
                        showCheckmark: false,
                        label: Text(
                          priority,
                          style: TextStyle(
                              fontSize: Theme.of(context).textTheme.labelMedium!.fontSize
                          ),
                        ),
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
          ],
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _loadTasks(),
              builder: (context, snapshot) {
                if (_searchQuery.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Start typing to search tasks',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final tasks = snapshot.data!;

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'No tasks found',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskItem(task: task);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}