import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int daysRequired;
  final IconData icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final Color color;
  final String rank;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.daysRequired,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
    required this.color,
    required this.rank,
  });

  static List<Achievement> getAchievementTemplates() {
    return [
      Achievement(
        id: 'streak_1',
        title: 'First Step',
        description: '1 day streak',
        daysRequired: 1,
        icon: Icons.looks_one,
        isUnlocked: false,
        color: Colors.grey,
        rank: 'Newcomer',
      ),
      Achievement(
        id: 'streak_3',
        title: 'Off the Blocks',
        description: '3 days streak',
        daysRequired: 3,
        icon: Icons.local_fire_department,
        isUnlocked: false,
        color: Colors.orange,
        rank: 'Starter',
      ),
      Achievement(
        id: 'streak_5',
        title: 'Picking Up Pace',
        description: '5 days streak',
        daysRequired: 5,
        icon: Icons.run_circle,
        isUnlocked: false,
        color: Colors.deepOrange,
        rank: 'Warming Up',
      ),
      Achievement(
        id: 'streak_7',
        title: 'One Week Done',
        description: '7 days streak',
        daysRequired: 7,
        icon: Icons.shield,
        isUnlocked: false,
        color: Colors.blue,
        rank: 'Consistent',
      ),
      Achievement(
        id: 'streak_10',
        title: 'In Double Digits',
        description: '10 days streak',
        daysRequired: 10,
        icon: Icons.confirmation_number,
        isUnlocked: false,
        color: Colors.cyan,
        rank: 'Reliable',
      ),
      Achievement(
        id: 'streak_14',
        title: 'Two Weeks Strong',
        description: '14 days streak',
        daysRequired: 14,
        icon: Icons.star,
        isUnlocked: false,
        color: Colors.purple,
        rank: 'Steady',
      ),
      Achievement(
        id: 'streak_21',
        title: 'Habit Formed',
        description: '21 days streak',
        daysRequired: 21,
        icon: Icons.check_circle,
        isUnlocked: false,
        color: Colors.lightGreen,
        rank: 'Disciplined',
      ),
      Achievement(
        id: 'streak_30',
        title: 'On a Roll',
        description: '30 days streak',
        daysRequired: 30,
        icon: Icons.diamond,
        isUnlocked: false,
        color: Colors.green,
        rank: 'Motivated',
      ),
      Achievement(
        id: 'streak_60',
        title: 'Two Months In',
        description: '60 days streak',
        daysRequired: 60,
        icon: Icons.timeline,
        isUnlocked: false,
        color: Colors.teal,
        rank: 'Committed',
      ),
      Achievement(
        id: 'streak_90',
        title: 'Quarter Year Club',
        description: '90 days streak',
        daysRequired: 90,
        icon: Icons.emoji_events,
        isUnlocked: false,
        color: Colors.amber,
        rank: 'Achiever',
      ),
      Achievement(
        id: 'streak_180',
        title: 'Half-Year Hustle',
        description: '180 days streak',
        daysRequired: 180,
        icon: Icons.military_tech,
        isUnlocked: false,
        color: Colors.red,
        rank: 'Focused',
      ),
      Achievement(
        id: 'streak_365',
        title: 'Year of Progress',
        description: '365 days streak',
        daysRequired: 365,
        icon: Icons.castle,
        isUnlocked: false,
        color: Colors.deepPurple,
        rank: 'Dedicated',
      ),
      Achievement(
        id: 'streak_730',
        title: 'Two Years Strong',
        description: '730 days streak',
        daysRequired: 730,
        icon: Icons.rocket_launch,
        isUnlocked: false,
        color: Colors.indigo,
        rank: 'Resilient',
      ),
      Achievement(
        id: 'streak_1095',
        title: 'Three Year Journey',
        description: '1095 days streak',
        daysRequired: 1095,
        icon: Icons.auto_awesome,
        isUnlocked: false,
        color: Colors.teal,
        rank: 'Veteran',
      ),
      Achievement(
        id: 'streak_1825',
        title: 'Five-Year Focus',
        description: '1825 days streak',
        daysRequired: 1825,
        icon: Icons.wb_sunny,
        isUnlocked: false,
        color: Colors.amber[200]!,
        rank: 'Trailblazer',
      ),
      Achievement(
        id: 'streak_3650',
        title: 'Decade of Discipline',
        description: '10 years streak',
        daysRequired: 3650,
        icon: FontAwesomeIcons.infinity,
        isUnlocked: false,
        color: Colors.black,
        rank: 'Legendary',
      ),
    ];
  }


  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    int? daysRequired,
    IconData? icon,
    bool? isUnlocked,
    DateTime? unlockedDate,
    Color? color,
    String? rank,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      daysRequired: daysRequired ?? this.daysRequired,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      color: color ?? this.color,
      rank: rank ?? this.rank,
    );
  }
}