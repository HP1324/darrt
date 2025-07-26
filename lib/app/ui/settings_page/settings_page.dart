import 'package:darrt/app/ui/settings_page/reminder_settings_section.dart';
import 'package:darrt/app/ui/settings_page/timer_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:darrt/app/ui/settings_page/backup_settings_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 18,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReminderSettingsSection(),
              TimerSettingsSection(),
              BackupSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }
}