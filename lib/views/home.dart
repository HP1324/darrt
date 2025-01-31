import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/view_models/navigation_view_model.dart';
import 'package:minimaltodo/views/pages/navigation/calendar_page.dart';
import 'package:minimaltodo/views/pages/navigation/categories_page.dart';
import 'package:minimaltodo/views/pages/navigation/finished_tasks_page.dart';
import 'package:minimaltodo/views/pages/navigation/pending_tasks_page.dart';
import 'package:minimaltodo/views/pages/task_editor_page.dart';
import 'package:minimaltodo/views/widgets/app_drawer.dart';
import 'package:minimaltodo/views/widgets/mini_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import 'pages/search_page.dart';

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
      child: Consumer<NavigationViewModel>(builder: (context, navVM, _) {
        return Scaffold(
          appBar: _AppBar(),
          drawer: const AppDrawer(),
          body: [
            const CalendarPage(),
            const PendingTasksPage(),
            const FinishedTasksPage(),
            const CategoriesPage(),
          ][navVM.currentDestination],
          floatingActionButton: _FloatingActionButtonWidget(),
          bottomNavigationBar: _BottomNavBarWidget(),
        );
      }),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  AppBar build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text('MinimalTodo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => MiniRouter.to(context, child: SearchPage()),
        ),
      ],
    );
  }
}

class _BottomNavBarWidget extends StatelessWidget {
  const _BottomNavBarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationViewModel>(builder: (context, navVM, _) {
      return MiniBottomNavBar(
        children: [
          MiniBottomNavBarItem(icon: Icons.calendar_month, label: 'Calendar', i: 0),
          MiniBottomNavBarItem(icon: Icons.assignment_outlined, label: 'Pending', i: 1),
          MiniBottomNavBarItem(icon: Icons.check_circle_outline, label: 'Finished', i: 2),
          MiniBottomNavBarItem(icon: Iconsax.category, label: 'Categories', i: 3),
          MiniBottomNavBarItem(icon: Iconsax.note, label: 'Notes', i: -1),
        ],
      );
    });
  }
}

class _FloatingActionButtonWidget extends StatelessWidget {
  const _FloatingActionButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Transform.scale(
        scale: 0.9,
        child: FloatingActionButton(
          onPressed: () {
            MiniRouter.to(context, child: TaskEditorPage(editMode: false));
          },
          tooltip: 'Add Task',
          elevation: 5,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
