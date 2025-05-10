import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:iconsax/iconsax.dart';

import 'package:minimaltodo/app/state/managers/navigation_manager.dart';
import 'package:minimaltodo/app/ui/app_drawer.dart';
import 'package:minimaltodo/app/ui/mini_app_bar.dart';
import 'package:minimaltodo/app/ui/mini_bottom_nav_bar.dart';
import 'package:minimaltodo/category/ui/categories_page.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart' show getIt;
import 'package:minimaltodo/task/ui/add_task_page.dart';
import 'package:minimaltodo/task/ui/tasks_page.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: MiniAppBar(),
        drawer: const AppDrawer(),
        body: IndexedStack(
          index: context.watch<NavigationManager>().currentDestination,
          children: [
            const TasksPage(),
            const CategoriesPage(),
          ],
        ),
        floatingActionButton: Consumer<NavigationManager>(
          builder: (context, manager, _) {
            if (manager.currentDestination == 0) {
              return const _FloatingActionButtonWidget();
            }
            return const SizedBox.shrink(); // Return an invisible widget instead of null
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: const _BottomNavBarWidget(),
      ),
    );
  }
}

class _BottomNavBarWidget extends StatelessWidget {
  const _BottomNavBarWidget();
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationManager>(builder: (context, navVM, _) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
             color: Theme.of(context).colorScheme.primary.withAlpha(20), width: 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: MiniBottomNavBar(
          children: [
            // const SizedBox.shrink(),
            MiniBottomNavBarItem(icon: Icons.calendar_month, label: 'Calendar', i: 0),
            MiniBottomNavBarItem(icon: Icons.search, label: 'Search', i: -1),
            MiniBottomNavBarItem(icon: Iconsax.category, label: 'Categories', i: 1),
            MiniBottomNavBarItem(icon: Icons.assignment_outlined, label: 'Notes', i: -2),
            // MiniBottomNavBarItem(icon: Iconsax.book, label: 'Journal', i: -2),
            // const SizedBox.shrink(),
          ],
        ),
      );
    });
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
          onPressed: () {
            MiniRouter.to(context, AddTaskPage(edit: false));
          },
          shape: StadiumBorder(),
          tooltip: 'Add Task',
          elevation: 5,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
