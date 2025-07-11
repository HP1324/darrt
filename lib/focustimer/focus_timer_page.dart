import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/sound/sound_page.dart';

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> with SingleTickerProviderStateMixin{
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Focus Sessions')),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'Timer'),
              Tab(text: 'Listen to sounds')
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
      ),
    );
  }
}

