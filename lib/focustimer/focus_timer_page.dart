import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/focustimer/sound/sound_tab.dart';
import 'package:darrt/focustimer/timer/focus_timer_tab.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> with SingleTickerProviderStateMixin,AutomaticKeepAliveClientMixin{
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    g.audioController.initialize();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textTheme = context.textTheme;
    final scheme = context.colorScheme;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: getLerpedSurfaceColor(context),
        title: Text('Focus', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          InkWell(
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(0.9),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.question_mark),
            ),
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    content: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "If notification permissions are granted, you can see persistent timer notification after enabling it from settings. Go to app's Settings > Timer Settings >Enable \"Show timer as notification in notification bar until ends.\"",
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
          children: [
            TabBar(
              controller: tabController,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Focus Timer'),
                Tab(text: 'Relaxing Sounds'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  FocusTimerTab(),
                  SoundTab()
                ],
              ),
            ),
          ],
        ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

