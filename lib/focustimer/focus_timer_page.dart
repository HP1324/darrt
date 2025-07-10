import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/sound/sound_page.dart';

class FocusTimerPage extends StatefulWidget {
  const FocusTimerPage({super.key});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SoundPage(),
    );
  }
}

