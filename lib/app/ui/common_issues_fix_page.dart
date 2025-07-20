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
