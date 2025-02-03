import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final storage = GetStorage();

  bool get isNotificationsEnabled =>
      storage.read<bool>('notifications_enabled') ?? false;

  String get notificationType =>
      storage.read<String>('notification_type') ?? 'notif';

  String get selectedSound =>
      storage.read<String>('selected_sound') ?? 'default';

  Future<void> _toggleNotifications(bool value) async {
    await storage.write('notifications_enabled', value);
    setState(() {});
  }

  Future<void> _setNotificationType(String type) async {
    await storage.write('notification_type', type);
    // Reset sound selection when type changes
    await storage.write('selected_sound', 'default');
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: textTheme.titleLarge,
        ),
      ),
      body: ListView(
        children: [
          // Enable/Disable Notifications
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  value: isNotificationsEnabled,
                  onChanged: (value) => _toggleNotifications(value!),
                  title: Text(
                    'Enable Notifications',
                    style: textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Receive reminders for your tasks',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  activeColor: colorScheme.primary,
                  checkColor: colorScheme.onPrimary,
                ),

                if (isNotificationsEnabled) ...[
                  const SizedBox(height: 24),

                  Text(
                    'Notification Type',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton(
                    segments: const [
                      ButtonSegment(
                        value: 'notif',
                        label: Text('Notification'),
                      ),
                      ButtonSegment(
                        value: 'alarm',
                        label: Text('Alarm'),
                      ),
                    ],
                    selected: {notificationType},
                    onSelectionChanged: (newSelection) {
                      _setNotificationType(newSelection.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return colorScheme.primaryContainer;
                          }
                          return colorScheme.surface;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sound Selection
                  ListTile(
                    title: Text(
                      'Sound',
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      selectedSound == 'default'
                          ? 'Default ${notificationType == 'alarm' ? 'alarm' : 'notification'} sound'
                          : selectedSound,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      notificationType == 'alarm'
                          ? Icons.alarm
                          : Icons.notifications,
                      color: colorScheme.primary,
                    ),
                    onTap: ()async{
                    }
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Tap to open system ${notificationType == 'alarm' ? 'alarm' : 'notification'} sounds',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}