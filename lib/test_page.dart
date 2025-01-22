import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/views/widgets/mini_bottom_nav_bar.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test page')),
      bottomNavigationBar: MiniBottomNavBar(
        children: [
          MiniBottomNavBarItem(icon: Icons.calendar_month, label: 'Calendar', i: 0),
          MiniBottomNavBarItem(icon: Icons.assignment_outlined, label: 'Pending', i: 1),
          MiniBottomNavBarItem(icon: Icons.check_circle_outline, label: 'Finished', i: 2),
          MiniBottomNavBarItem(icon: Iconsax.category, label: 'categories', i: 3),
          MiniBottomNavBarItem(icon: Iconsax.note, label: 'Notes', i: -1),
        ],
      ),
    );
  }
}

