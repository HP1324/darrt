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
        id: 'streak_3',
        title: 'Getting Started',
        description: '3 days streak',
        daysRequired: 3,
        icon: Icons.local_fire_department,
        isUnlocked: false,
        color: Colors.orange,
        rank: 'Beginner',
      ),
      Achievement(
        id: 'streak_7',
        title: 'One Week Strong',
        description: '7 days streak',
        daysRequired: 7,
        icon: Icons.shield,
        isUnlocked: false,
        color: Colors.blue,
        rank: 'Consistent',
      ),
      Achievement(
        id: 'streak_14',
        title: 'Two Weeks In',
        description: '14 days streak',
        daysRequired: 14,
        icon: Icons.star,
        isUnlocked: false,
        color: Colors.purple,
        rank: 'Steady',
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
        id: 'streak_90',
        title: 'Three-Month Milestone',
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
        title: 'One Year Strong',
        description: '365 days streak',
        daysRequired: 365,
        icon: Icons.castle,
        isUnlocked: false,
        color: Colors.deepPurple,
        rank: 'Dedicated',
      ),
      Achievement(
        id: 'streak_730',
        title: 'Two Years In',
        description: '2 years streak',
        daysRequired: 730,
        icon: Icons.rocket_launch,
        isUnlocked: false,
        color: Colors.indigo,
        rank: 'Resilient',
      ),
      Achievement(
        id: 'streak_1095',
        title: 'Three Years Strong',
        description: '3 years streak',
        daysRequired: 1095,
        icon: Icons.auto_awesome,
        isUnlocked: false,
        color: Colors.teal,
        rank: 'Veteran',
      ),
      Achievement(
        id: 'streak_1825',
        title: 'Five Year Mark',
        description: '5 years streak',
        daysRequired: 1825,
        icon: Icons.wb_sunny,
        isUnlocked: false,
        color: Colors.amber[200]!,
        rank: 'Trailblazer',
      ),
      Achievement(
        id: 'streak_3650',
        title: 'A Decade of Progress',
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