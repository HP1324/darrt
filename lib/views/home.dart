import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/services/notification_action_controller.dart'
    show NotificationActionController;
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:minimaltodo/view_models/navigation_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart' show TaskViewModel;
import 'package:minimaltodo/views/pages/navigation/calendar_page.dart';
import 'package:minimaltodo/views/pages/navigation/categories_page.dart';
import 'package:minimaltodo/views/pages/navigation/wishlist_page.dart';
import 'package:minimaltodo/views/pages/task_editor_page.dart';
import 'package:minimaltodo/views/widgets/app_drawer.dart';
import 'package:minimaltodo/views/widgets/mini_app_bar.dart';
import 'package:minimaltodo/views/widgets/mini_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: MiniAppBar(),
        drawer: const AppDrawer(),
        body: Selector<NavigationViewModel, int>(
            selector: (_, navVM) => navVM.currentDestination,
            builder: (context, currentDestination, _) {
              return IndexedStack(
                index: currentDestination,
                children: [
                  const CalendarPage(),
                  const WishListPage(),
                  const CategoriesPage(),
                ],
              );
            }),
        floatingActionButton: _FloatingActionButtonWidget(),
        bottomNavigationBar: const _BottomNavBarWidget(),
      ),
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
          // const SizedBox.shrink(),
          MiniBottomNavBarItem(icon: Icons.calendar_month, label: 'Calendar', i: 0),
          MiniBottomNavBarItem(icon: Icons.assignment_outlined, label: 'Wishlist', i: 1),
          MiniBottomNavBarItem(icon: Icons.search, label: 'Search', i: -1),
          MiniBottomNavBarItem(icon: Iconsax.category, label: 'Categories', i: 2),
          // MiniBottomNavBarItem(icon: Iconsax.book, label: 'Journal', i: -2),
          // const SizedBox.shrink(),
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
