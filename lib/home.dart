import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/app/ui/app_drawer.dart';
import 'package:minimaltodo/app/ui/mini_app_bar.dart';
import 'package:minimaltodo/app/ui/mini_bottom_nav_bar.dart';
import 'package:minimaltodo/category/ui/categories_page.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/note/ui/notes_page.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';
import 'package:minimaltodo/task/ui/task_search_page.dart';
import 'package:minimaltodo/task/ui/tasks_page.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: MiniAppBar(),
        drawer: const AppDrawer(),
        body: ValueListenableBuilder(
            valueListenable: g.navMan.currentDestination,
            builder: (context,value, child) {
              return IndexedStack(
                index: value,
                children: [
                  const TasksPage(),
                  const CategoriesPage(),
                ],
              );
            }),
        floatingActionButton: ValueListenableBuilder(
          valueListenable: g.navMan.currentDestination,
          builder: (context, value ,child) {
            if (value == 0) {
              return const _FloatingActionButtonWidget();
            }
            return const SizedBox.shrink(); // Return an invisible widget instead of null
          },
        ),
        bottomNavigationBar: const _BottomNavBarWidget(),
      ),
    );
  }
}

class _BottomNavBarWidget extends StatelessWidget {
  const _BottomNavBarWidget();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: g.navMan.currentDestination,
      builder: (context, value,child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: MiniBottomNavBar(
            children: [
              MiniBottomNavBarItem(
                icon: Icons.calendar_month,
                label: 'Tasks',
                onTap: () => g.navMan.onDestinationChanged(0),
                i: 0,
              ),
              // MiniBottomNavBarItem(
              //   icon: Icons.timeline,
              //   label: 'Timelines',
              //   onTap: () => MiniRouter.to(context, const TaskSearchPage()),
              //   i: -1,
              // ),
              MiniBottomNavBarItem(
                icon: Icons.search,
                label: 'Search',
                onTap: () => MiniRouter.to(context, const TaskSearchPage()),
                i: -2,
              ),
              MiniBottomNavBarItem(
                icon: Iconsax.category,
                label: 'Categories',
                onTap: () => g.navMan.onDestinationChanged(1),
                i: 1,
              ),
              MiniBottomNavBarItem(
                icon: Icons.assignment_outlined,
                label: 'Notes',
                onTap: () => MiniRouter.to(context, NotesPage()),
                i: -3,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingActionButtonWidget extends StatelessWidget {
  const _FloatingActionButtonWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Transform.scale(
        scale: 0.9,
        child: FloatingActionButton(
          onPressed: () => MiniRouter.to(context, AddTaskPage(edit: false)),
          tooltip: 'Add Task',
          elevation: 5,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
