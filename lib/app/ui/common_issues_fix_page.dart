import 'package:flutter/material.dart';

class CommonIssuesFixPage extends StatelessWidget {
  const CommonIssuesFixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Common Issues'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          IssueCard(
            title: '1. Notification has no sound or vibration',
            description: '''
Even if you've allowed the app to send notifications, the system notification settings might have sound and vibration turned off for this app.

🔧 Fix: 
Go to your phone's Settings > Apps > Darrt > Notifications, and make sure the relevant notification channels (like Reminders, Timers, etc.) have Sound and Vibration enabled.

You can usually tap on each notification category to adjust its behavior.''',
          ),
          SizedBox(height: 24),
          IssueCard(
            title: '2. Notifications are delayed or not timely',
            description: '''
If notifications arrive late or not at all, it's often due to battery optimization restrictions.

🔧 Fix:
Go to Settings > Battery > Battery Optimization > Darrt, and set it to Not Optimized or Unrestricted. 

This allows the app to run in the background and send notifications without delay, especially important for timers or reminders.''',
          ),
          SizedBox(height: 24),
          IssueCard(
            title: '3. Auto-backup not working sometimes',
            description: '''
Auto-backup may not work reliably if your device has poor internet connection or restricts background activity due to battery optimizations.

🔧 Fix:
You can always go to the app's settings and manually trigger a backup. It only takes a few seconds and ensures your data is safe. 

Also, consider disabling battery optimizations for Darrt to allow smoother auto-backup functionality.''',
          ),
          SizedBox(height: 24),
          IssueCard(
            title: '4. Ads showing even after purchasing',
            description: '''
Sometimes, ads may still appear after purchase due to the app not restarting properly or purchase data not being restored yet.

🔧 Fix:
- Please completely close and restart the app after purchasing to apply the changes.
- If you've reinstalled the app, tap the "Remove Ads" button again. This will show the purchase dialog where you'll see a "Restore Purchases" option.
- Tap Restore Purchases, and restart the app again.

If restore still doesn’t work, make sure you're logged into the Play Store with the same account used during purchase.''',
          ),
        ],
      ),
    );
  }
}

class IssueCard extends StatelessWidget {
  final String title;
  final String description;

  const IssueCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
