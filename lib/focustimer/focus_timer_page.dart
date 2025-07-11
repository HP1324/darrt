import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/sound/sound_page.dart';

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
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
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
                Text('hsuen'),
                SoundPage()
              ],
            ),
          ),
        ],
      );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

