import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/services/database_service.dart';

class ListService {
  static Future<List<ListModel>> getLists() async {
    final database = await DatabaseService.openDb();
    final List<Map<String, dynamic>> listMaps = await database.query('lists');
    return List.generate(listMaps.length, (index) {
      return ListModel.fromJson(listMaps[index]);
    });
  }

  static Future<int> addList(ListModel list) async {
    final database = await DatabaseService.openDb();
    final id = database.insert('lists', list.toJson());
    return id;
  }

  static Future<int> deleteList(int id) async {
    final database = await DatabaseService.openDb();

    // Begin transaction to ensure data consistency
    await database.transaction((txn) async {
      // First update all tasks in this list to set list to null
      await txn.update('tasks', {'list_id': null, 'list_name': null},
          where: 'list_id = ?', whereArgs: [id]);

      // Then delete the list
      await txn.delete('lists', where: 'id = ?', whereArgs: [id]);
    });

    return 1; // Return success
  }

  static ListModel? getListById(int id) {
    ListModel lm = ListModel();
    DatabaseService.openDb().then((db) {
      db.query('lists', where: 'id = ?', whereArgs: [id]).then((lists) {
        if (lists.isNotEmpty) {
          lm = ListModel.fromJson(lists.first);
        }
      });
    });
    return lm;
  }

  static Future<int> editList(ListModel list) async {
    final database = await DatabaseService.openDb();
    int rowsAffected = await database.update(
      'lists',
      list.toJson(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
    return rowsAffected;
  }

  ///Icon related logic
  static final Map<String, String> defaultIconCodes = {
    'Sports': 'football',          // FontAwesomeIcons.football
    'Health': 'heart',             // Iconsax.heart
    'Work': 'briefcase',           // Iconsax.briefcase
    'Shopping': 'cart',            // Iconsax.shopping_cart
    'Groceries': 'shop',           // Iconsax.shop
    'Books': 'book',               // Iconsax.book
    'Travel': 'airplane',          // Iconsax.airplane
    'Education': 'graduation_cap',  // FontAwesomeIcons.graduationCap
    'Personal': 'home',            // Iconsax.home
    'Finance': 'wallet',           // Iconsax.wallet
    'Hobbies': 'gamepad',          // FontAwesomeIcons.gamepad
    'Fitness': 'dumbbell',         // FontAwesomeIcons.dumbbell
    'Food': 'utensils',            // FontAwesomeIcons.utensils
    'Friends': 'heart',            // Iconsax.heart
    'Family': 'home',              // Iconsax.home
    'Chores': 'task',              // Iconsax.task_square
    'Projects': 'chart',           // Iconsax.chart
    'Entertainment': 'video',       // Iconsax.video
  };

  static final Map<String, IconData> icons = {
    'folder': Iconsax.folder,
    'heart': Iconsax.heart,
    'book': Iconsax.book,
    'cart': Iconsax.shopping_cart,
    'home': Iconsax.home,
    'briefcase': Iconsax.briefcase,
    'calendar': Iconsax.calendar,
    'star': Iconsax.star,
    'music': Iconsax.music,
    'camera': Iconsax.camera,
    'car': Iconsax.car,
    'gift': Iconsax.gift,
    'coffee': Iconsax.coffee,
    'game': Iconsax.game,
    'chart': Iconsax.chart,
    'note': Iconsax.note,
    'clock': Iconsax.clock,
    'wallet': Iconsax.wallet,
    'location': Iconsax.location,
    'airplane': Iconsax.airplane,
    'crown': Iconsax.crown,
    'medal': Iconsax.medal,
    'flag': Iconsax.flag,
    'map': Iconsax.map,
    'ticket': Iconsax.ticket,
    'video': Iconsax.video,
    'message': Iconsax.message,
    'bag': Iconsax.bag,
    'box': Iconsax.box,
    'headphone': Iconsax.headphone,
    'shield': Iconsax.shield,
    'lamp': Iconsax.lamp,
    'tree': Iconsax.tree,
    'building': Iconsax.building,
    'cake': Iconsax.cake,
    'health': Iconsax.health,
    'pet': Iconsax.pet,
    'shop': Iconsax.shop,
    'task': Iconsax.task_square,
    'teacher': Iconsax.teacher,
    'utensils': FontAwesomeIcons.utensils,
    'dumbbell': FontAwesomeIcons.dumbbell,
    'guitar': FontAwesomeIcons.guitar,
    'palette': FontAwesomeIcons.palette,
    'graduation_cap': FontAwesomeIcons.graduationCap,
    'code': FontAwesomeIcons.code,
    'brain': FontAwesomeIcons.brain,
    'pills': FontAwesomeIcons.pills,
    'shirt': FontAwesomeIcons.shirt,
    'socks': FontAwesomeIcons.socks,
    'glasses': FontAwesomeIcons.glasses,
    'baby': FontAwesomeIcons.baby,
    'cat': FontAwesomeIcons.cat,
    'dog': FontAwesomeIcons.dog,
    'fish': FontAwesomeIcons.fish,
    'burger': FontAwesomeIcons.hamburger,
    'pizza': FontAwesomeIcons.pizzaSlice,
    'ice_cream': FontAwesomeIcons.iceCream,
    'cookie': FontAwesomeIcons.cookie,
    'drum': FontAwesomeIcons.drum,
    'gamepad': FontAwesomeIcons.gamepad,
    'dice': FontAwesomeIcons.dice,
    'chess': FontAwesomeIcons.chess,
    'football': FontAwesomeIcons.football,
    'baseball': FontAwesomeIcons.baseball,
    'tennis': FontAwesomeIcons.tableTennisPaddleBall,
    'volleyball': FontAwesomeIcons.volleyball,
    'hiking': FontAwesomeIcons.personHiking,
    'camping': FontAwesomeIcons.campground,
    'mountain': FontAwesomeIcons.mountain,
    'umbrella_beach': FontAwesomeIcons.umbrellaBeach,
    'tools': FontAwesomeIcons.screwdriverWrench,
    'paint_roller': FontAwesomeIcons.paintRoller,
    'scissors': FontAwesomeIcons.scissors,

    // Custom icons added as placeholders (use appropriate icon fonts if available):
    'task': Iconsax.task_square, // Placeholder for 'task'
    'graduation_cap': FontAwesomeIcons.graduationCap, // Education
    'football': FontAwesomeIcons.football, // Sports
  };


  static IconData getIcon(String? code) {
    return icons[code ?? 'folder'] ?? Iconsax.folder;
  }
}
