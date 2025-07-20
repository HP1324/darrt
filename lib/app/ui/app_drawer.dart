import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/app/ui/common_issues_fix_page.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/docs/v1.dart' hide TextStyle;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:darrt/app/ui/settings_page/settings_page.dart';
import 'package:darrt/app/ui/theme_settings_page.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/quickreminder/ui/quick_reminders_page.dart';
import 'package:url_launcher/url_launcher.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
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
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text('Common Issues'),
            onTap: () {
              MiniRouter.to(context, CommonIssuesFixPage());
            },
          ),
          const Spacer(),
          const FooterSection(),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(
            '•',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse('https://hp1324.github.io/darrt-privacy-policy/');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if(context.mounted){
                  showErrorToast(context, 'Could not launch URL');
                }
              }
            },
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

