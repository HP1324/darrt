import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/app_router.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/theme_view_model.dart';
import 'package:minimaltodo/views/pages/productivity_stats_page.dart';
import 'package:minimaltodo/views/pages/theme_settings_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    //TODO: add random quote feature in DrawerHeader
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha(30)),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('MinimalTodo',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(
                    dateFormat.format(now),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Iconsax.profile_2user),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Customize Theme'),
            onTap: () => AppRouter.to(context, child: ThemeSettingsPage()),
          ),
          ListTile(
            leading: const Icon(Iconsax.chart_2),
            title: const Text('Productivity Stats'),
            onTap: () => AppRouter.to(context, child: ProductivityStatsPage()),
          ),
          ListTile(
            leading: const Icon(Iconsax.notification),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Iconsax.setting_2),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Add navigation logic here if needed
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
