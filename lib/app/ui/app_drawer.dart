import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:darrt/app/ui/settings_page/settings_page.dart';
import 'package:darrt/app/ui/theme_settings_page.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/quickreminder/ui/quick_reminders_page.dart';
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
                  const Text('Darrt',
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
            leading: const Icon(Icons.alarm),
            title: const Text('Quick Reminders'),
            onTap: () {
              MiniRouter.to(context, QuickRemindersPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Theme'),
            onTap: () {
              Navigator.pop(context);
              MiniRouter.to(context, ThemeSettingsPage());
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.setting_2),
            title: const Text('Settings'),
            onTap: () {
                MiniRouter.to(context, SettingsPage());
            },
          ),
          const Spacer(),
          const AppVersionLabel(),
        ],
      ),
    );
  }
}

class AppVersionLabel extends StatelessWidget {
  const AppVersionLabel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Builder(
        builder: (context) {

          // PackageInfo packageInfo = PackageInfo.fromPlatform();
          return Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
            ),
          );
        }
      ),
    );
  }
}
