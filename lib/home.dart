import 'package:darrt/app/ads/my_banner_ad_widget.dart';
import 'package:darrt/app/ads/timed_banner_ad_widget.dart';
import 'package:darrt/app/ui/app_drawer.dart';
import 'package:darrt/app/ui/mini_app_bar.dart';
import 'package:darrt/app/ui/mini_bottom_nav_bar.dart';
import 'package:darrt/category/ui/categories_page.dart';
import 'package:darrt/focustimer/focus_timer_page.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/note/ui/notes_page.dart';
import 'package:darrt/task/ui/add_task_page.dart';
import 'package:darrt/task/ui/task_search_page.dart';
import 'package:darrt/task/ui/tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // g.adsController.initializeHomePageBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: getSurfaceColor(context),
        appBar: MiniAppBar(),
        drawer: const AppDrawer(),
        body: ValueListenableBuilder(
          valueListenable: g.navMan.currentDestination,
          builder: (context, value, child) {
            return IndexedStack(
              index: value,
              children: [
                const TasksPage(),
                const FocusTimerPage(),
                const CategoriesPage(),
              ],
            );
          },
        ),
        floatingActionButton: ValueListenableBuilder(
          valueListenable: g.navMan.currentDestination,
          builder: (context, value, child) {
            if (value == 0) {
              return const _FloatingActionButtonWidget();
            }
            return const SizedBox.shrink();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: g.navMan.currentDestination,
          builder: (context, value, child) {
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
                  MiniBottomNavBarItem(
                    icon: Icons.psychology_outlined,
                    label: 'Focus',
                    onTap: () => g.navMan.onDestinationChanged(1),
                    i: 1,
                  ),
                  MiniBottomNavBarItem(
                    icon: Icons.search,
                    label: 'Search',
                    onTap: () => MiniRouter.to(context, const TaskSearchPage()),
                    i: -2,
                  ),
                  MiniBottomNavBarItem(
                    icon: Iconsax.category,
                    label: 'Categories',
                    onTap: () => g.navMan.onDestinationChanged(2),
                    i: 2,
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
        ),
        ListenableBuilder(
          listenable: g.adsController,
          builder: (context, child) {
            return TimedBannerAdWidget(
              adInitializer: () => g.adsController.initializeHomePageBannerAd(),
              showFor: const Duration(seconds: 40),
              hideFor: const Duration(seconds: 10),
              showFirst: false,
              childBuilder: () {
                if (g.adsController.isHomePageBannerAdLoaded) {
                  return MyBannerAdWidget(bannerAd: g.adsController.homePageBannerAd);
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onPressed: () => MiniRouter.to(context, AddTaskPage(edit: false)),
          tooltip: 'Add Task',
          elevation: 5,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
