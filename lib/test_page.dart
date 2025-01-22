import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: Text('Test page')),
      bottomNavigationBar: MiniBottomNavBar(
        children: [
          MiniBarItem(icon: Iconsax.calendar, label: 'Calendar'),
          MiniBarItem(icon: Icons.assignment_outlined, label: 'Pending'),
          MiniBarItem(icon: Icons.check_circle_outline, label: 'Finished'),
          MiniBarItem(icon: Iconsax.category, label: 'Lists'),
          MiniBarItem(icon: Iconsax.note, label: 'Notes'),
        ],
      ),
    );
  }
}

class MiniBottomNavBar extends StatefulWidget {
  const MiniBottomNavBar({super.key, required this.children});
  final List<Widget> children;
  @override
  State<MiniBottomNavBar> createState() => _MiniBottomNavBarState();
}

class _MiniBottomNavBarState extends State<MiniBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.08,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(15),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.children,
        ),
      ),
    );
  }
}


class MiniBarItem extends StatefulWidget {
  const MiniBarItem({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  State<MiniBarItem> createState() => _MiniBarItemState();
}

class _MiniBarItemState extends State<MiniBarItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 3,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(padding: EdgeInsets.all(5),child: Icon(widget.icon,size: 21,color: Theme.of(context).colorScheme.primary)),
        Text(widget.label,style: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall!.fontSize ,color: Theme.of(context).colorScheme.primary,fontWeight: FontWeight.bold)),
      ],
    );
  }
}

