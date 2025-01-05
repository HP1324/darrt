import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/database_service.dart';

class ListService {
  static Future<List<ListModel>> getLists() async {
    final database = await DatabaseService.openDb();
    final List<Map<String, dynamic>> listMaps = await database.query('lists');

    // Debug: Print all lists and their icon codes
    for (var map in listMaps) {
      logger.d('List: ${map['name']}, Icon code: ${map['icon_code']}');
    }

    return List.generate(listMaps.length, (index) {
      return ListModel.fromJson(listMaps[index]);
    });
  }

  static Future<int> addList(ListModel list) async {
    final database = await DatabaseService.openDb();
    int id = 0;
    try {
      id = await database.insert('lists', list.toJson());
    } catch (e) {
      logger.e('an Exception or Error is thrown when adding list to database ${e.toString()}');
    }
    return id;
  }

  static Future<int> deleteList(int id) async {
    final database = await DatabaseService.openDb();
    int rowsAffected = 0;
    try {
      // Begin transaction to ensure data consistency
      await database.transaction((txn) async {
        // First update all tasks in this list to set list to null
        await txn.update('tasks', {'list_id': 1}, where: 'list_id = ?', whereArgs: [id]);

        // Then delete the list
        rowsAffected = await txn.delete('lists', where: 'id = ?', whereArgs: [id]);
      });
    } catch (e) {
      logger.e('An Exception or Error is thrown while deleting the list: ${e.toString()}');
    }

    return rowsAffected; // Return success
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

  static Future<ListModel?> getGeneralList() async {
    final db = await DatabaseService.openDb();
    final generalListMap = await db.query('lists', where: 'id = ?', whereArgs: [1]);
    ListModel? generalListModel;
    generalListModel = ListModel.fromJson(generalListMap.first);
    return generalListModel;
  }

  static Future<int> editList(ListModel list) async {
    final database = await DatabaseService.openDb();
    int rowsAffected = 0;
    try {
      rowsAffected = await database.update(
        'lists',
        list.toJson(),
        where: 'id = ?',
        whereArgs: [list.id],
      );
    } catch (e) {
      logger.e('an Exception or Error is thrown when editing a list in database ${e.toString()}');
    }
    return rowsAffected;
  }

  ///Icon related logic
  static final Map<String, String> defaultIconCodes = {
    'Sports': 'football', // FontAwesomeIcons.football
    'Health': 'heart', // Iconsax.heart
    'Work': 'briefcase', // Iconsax.briefcase
    'Shopping': 'cart', // Iconsax.shopping_cart
    'Groceries': 'shop', // Iconsax.shop
    'Books': 'book', // Iconsax.book
    'Travel': 'airplane', // Iconsax.airplane
    'Education': 'graduation_cap', // FontAwesomeIcons.graduationCap
    'Personal': 'home', // Iconsax.home
    'Finance': 'wallet', // Iconsax.wallet
    'Hobbies': 'gamepad', // FontAwesomeIcons.gamepad
    'Fitness': 'dumbbell', // FontAwesomeIcons.dumbbell
    'Food': 'utensils', // FontAwesomeIcons.utensils
    'Friends': 'people', // Iconsax.heart
    'Family': 'home', // Iconsax.home
    'Chores': 'task', // Iconsax.task_square
    'Projects': 'chart', // Iconsax.chart
    'Entertainment': 'video', // Iconsax.video
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
    'burger': FontAwesomeIcons.burger,
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
    'people': FontAwesomeIcons.handshake,
    'robot': FontAwesomeIcons.robot,
    'plant': FontAwesomeIcons.seedling,
    'basketball': FontAwesomeIcons.basketball,
    'meditation': FontAwesomeIcons.spa,
    'book_open': FontAwesomeIcons.bookOpen,
    'microscope': FontAwesomeIcons.microscope,
    'flask': FontAwesomeIcons.flask,
    'rocket': FontAwesomeIcons.rocket,
    'leaf': FontAwesomeIcons.leaf,
    'anchor': FontAwesomeIcons.anchor,
    'snowflake': FontAwesomeIcons.snowflake,
    'sun': FontAwesomeIcons.sun,
    'moon': FontAwesomeIcons.moon,
    'cloud': FontAwesomeIcons.cloud,
    'bicycle': FontAwesomeIcons.bicycle,
    'train': FontAwesomeIcons.train,
    'bus': FontAwesomeIcons.bus,
    'ship': FontAwesomeIcons.ship,
    'skull': FontAwesomeIcons.skull,
    'globe': FontAwesomeIcons.globe,
    'camera_retro': FontAwesomeIcons.cameraRetro,
    'film': FontAwesomeIcons.film,
    'hammer': FontAwesomeIcons.hammer,
    'syringe': FontAwesomeIcons.syringe,
    'tooth': FontAwesomeIcons.tooth,
    'bandage': FontAwesomeIcons.bandage,
    'hand_holding_heart': FontAwesomeIcons.handHoldingHeart,
    'hurricane': FontAwesomeIcons.hurricane,
    'volcano': FontAwesomeIcons.volcano,
    'mask': FontAwesomeIcons.mask,
    'laptop': FontAwesomeIcons.laptop,
    'mobile': FontAwesomeIcons.mobile,
    'tablet': FontAwesomeIcons.tablet,
    'desktop': FontAwesomeIcons.desktop,
    'server': FontAwesomeIcons.server,
    'database': FontAwesomeIcons.database,
    'virus': FontAwesomeIcons.virus,
    'bug': FontAwesomeIcons.bug,
    'lightbulb': FontAwesomeIcons.lightbulb,
    'pen': FontAwesomeIcons.pen,
    'eraser': FontAwesomeIcons.eraser,
    'bookmark': FontAwesomeIcons.bookmark,
    'bell': FontAwesomeIcons.bell,
    'key': FontAwesomeIcons.key,
    'lock': FontAwesomeIcons.lock,
    'unlock': FontAwesomeIcons.unlock,
    'check': FontAwesomeIcons.check,
    'microphone': FontAwesomeIcons.microphone,
    'brush': FontAwesomeIcons.brush,
    'newspaper': FontAwesomeIcons.newspaper,
    'fire': FontAwesomeIcons.fire,
    'compass': FontAwesomeIcons.compass,
    'fingerprint': FontAwesomeIcons.fingerprint,
    'dna': FontAwesomeIcons.dna,
    'infinity': FontAwesomeIcons.infinity,
    'trophy': FontAwesomeIcons.trophy,
    'recycle': FontAwesomeIcons.recycle,
    'wifi': FontAwesomeIcons.wifi,
    'hashtag': FontAwesomeIcons.hashtag,
    'mosque': FontAwesomeIcons.mosque,
    'church': FontAwesomeIcons.church,
    'synagogue': FontAwesomeIcons.synagogue,
    'hospital': FontAwesomeIcons.hospital,
    'bank': FontAwesomeIcons.buildingColumns,
    'store': FontAwesomeIcons.store,
    'factory': FontAwesomeIcons.industry,
    'wind': FontAwesomeIcons.wind,
    'rainbow': FontAwesomeIcons.rainbow,
    'atom': FontAwesomeIcons.atom,
    'satellite': FontAwesomeIcons.satellite,
    'feather': FontAwesomeIcons.feather,
    'puzzle': FontAwesomeIcons.puzzlePiece,
    'piggy_bank': FontAwesomeIcons.piggyBank,
    'keyboard': FontAwesomeIcons.keyboard,
    'mouse': FontAwesomeIcons.computerMouse,
    'printer': FontAwesomeIcons.print,
    'microchip': FontAwesomeIcons.microchip,
    'archive': FontAwesomeIcons.boxArchive,
    'id_card': FontAwesomeIcons.idCard,
    'passport': FontAwesomeIcons.passport,
    'stopwatch': FontAwesomeIcons.stopwatch,
    'earth': FontAwesomeIcons.earthAmericas,
    'meteor': FontAwesomeIcons.meteor,
    'temperature': FontAwesomeIcons.temperatureHigh,
    'bridge': FontAwesomeIcons.bridge,
    'road': FontAwesomeIcons.road,
    'traffic_light': FontAwesomeIcons.trafficLight,
    'subway': FontAwesomeIcons.trainSubway,
    'helicopter': FontAwesomeIcons.helicopter,
    'motorcycle': FontAwesomeIcons.motorcycle,
    'tractor': FontAwesomeIcons.tractor,
    'wheat': FontAwesomeIcons.wheatAwn,
    'carrot': FontAwesomeIcons.carrot,
    'lemon': FontAwesomeIcons.lemon,
    'hotdog': FontAwesomeIcons.hotdog,
    'egg': FontAwesomeIcons.egg,
    'mug_hot': FontAwesomeIcons.mugHot,
    'wine_glass': FontAwesomeIcons.wineGlass,
    'beer': FontAwesomeIcons.beer,
    'shirt_running': FontAwesomeIcons.personRunning,
    'swimming': FontAwesomeIcons.personSwimming,
    'skiing': FontAwesomeIcons.personSkiing,
    'biking': FontAwesomeIcons.personBiking,
    'crown_simple': FontAwesomeIcons.crown,
    'ranking_star': FontAwesomeIcons.rankingStar,
    'handcuffs': FontAwesomeIcons.handcuffs,
    'gavel': FontAwesomeIcons.gavel,
    'scale_balanced': FontAwesomeIcons.scaleBalanced,
    'suitcase_medical': FontAwesomeIcons.suitcaseMedical,
    'stethoscope': FontAwesomeIcons.stethoscope,
    'prescription': FontAwesomeIcons.prescription,
    'staff_snake': FontAwesomeIcons.staffSnake,
    'shower': FontAwesomeIcons.shower,
    'toilet': FontAwesomeIcons.toilet,
    'bath': FontAwesomeIcons.bath,
    'bed': FontAwesomeIcons.bed,
    'couch': FontAwesomeIcons.couch,
    'chair': FontAwesomeIcons.chair,
    'soap': FontAwesomeIcons.soap,
    'spray_can': FontAwesomeIcons.sprayCanSparkles,
    'broom': FontAwesomeIcons.broom,
    'bucket': FontAwesomeIcons.bucket,
  };

  static const Map<String, Color> listColors = {
    'primary' : Color(0xFF6B4EFF),
    'red': Color(0xFFE57373),
    'pink': Color(0xFFF06292),
    'purple': Color(0xFFBA68C8),
    'deepPurple': Color(0xFF9575CD),
    'indigo': Color(0xFF7986CB),
    'blue': Color(0xFF64B5F6),
    'lightBlue': Color(0xFF4FC3F7),
    'cyan': Color(0xFF4DD0E1),
    'teal': Color(0xFF4DB6AC),
    'green': Color(0xFF81C784),
    'lightGreen': Color(0xFFAED581),
    'orange': Color(0xFFFFB74D),
    'deepOrange': Color(0xFFFF8A65),
    'brown': Color(0xFFA1887F),
    'blueGrey': Color(0xFF90A4AE),
  };

  static Color getColorFromString(String? colorKey) {
    if (colorKey == null) return Colors.grey;
    return listColors[colorKey] ?? Colors.grey;
  }

  static String? getStringFromColor(Color color) {
    return listColors.entries
        .firstWhere(
          (element) => element.value == color,
          orElse: () => const MapEntry('grey', Colors.grey),
        )
        .key;
  }

  static IconData getIcon(String? code) {
    // logger.d('Getting icon for code: $code');
    if (code == null) {
      logger.d('Code is null, returning folder icon');
      return Iconsax.folder;
    }

    final icon = icons[code];
    if (icon == null) {
      // logger.d('No icon found for code: $code, returning folder icon');
      return Iconsax.folder;
    }

    // logger.d('Found icon for code: $code');
    return icon;
  }
}
