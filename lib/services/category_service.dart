import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/database_service.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    final database = await DatabaseService.openDb();
    final List<Map<String, dynamic>> categoryMaps = await database.query('categories');

    // Debug: Print all categories and their icon codes
    for (var map in categoryMaps) {
      logger.d('List: ${map['name']}, Icon code: ${map['icon_code']}');
    }

    return List.generate(categoryMaps.length, (index) {
      return CategoryModel.fromJson(categoryMaps[index]);
    });
  }

  static Future<int> addCategory(CategoryModel category) async {
    final database = await DatabaseService.openDb();
    int id = 0;
    try {
      id = await database.insert('categories', category.toJson());
    } catch (e) {
      logger.e('an Exception or Error is thrown when adding category to database ${e.toString()}');
    }
    return id;
  }

  static Future<int> deleteCategory(int id) async {
    final database = await DatabaseService.openDb();
    int rowsAffected = 0;
    try {
      // Begin transaction to ensure data consistency
      await database.transaction((txn) async {
        // First update all tasks in this list to set list to null
        await txn.update('tasks', {'categoryId': 1}, where: 'categoryId = ?', whereArgs: [id]);

        // Then delete the list
        rowsAffected = await txn.delete('categories', where: 'id = ?', whereArgs: [id]);
      });
    } catch (e) {
      logger.e('An Exception or Error is thrown while deleting the list: ${e.toString()}');
    }

    return rowsAffected; // Return success
  }

  static CategoryModel? getCategoryById(int id) {
    CategoryModel cm = CategoryModel();
    DatabaseService.openDb().then((db) {
      db.query('categories', where: 'id = ?', whereArgs: [id]).then((categories) {
        if (categories.isNotEmpty) {
          cm = CategoryModel.fromJson(categories.first);
        }
      });
    });
    return cm;
  }

  static Future<CategoryModel?> getGeneralCategory() async {
    final db = await DatabaseService.openDb();
    final generalListMap = await db.query('categories', where: 'id = ?', whereArgs: [1]);
    CategoryModel? generalListModel;
    generalListModel = CategoryModel.fromJson(generalListMap.first);
    return generalListModel;
  }

  static Future<int> editCategory(CategoryModel category) async {
    final database = await DatabaseService.openDb();
    int rowsAffected = 0;
    try {
      rowsAffected = await database.update(
        'categories',
        category.toJson(),
        where: 'id = ?',
        whereArgs: [category.id],
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
    'beer': FontAwesomeIcons.beerMugEmpty,
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
    'apple': FontAwesomeIcons.appleWhole,
    'cheese': FontAwesomeIcons.cheese,
    'bread': FontAwesomeIcons.breadSlice,
    'fish_food': FontAwesomeIcons.fishFins,
    'steak': FontAwesomeIcons.bacon,
    'salad': FontAwesomeIcons.leaf,
    'sushi': FontAwesomeIcons.fish,
    'wine': FontAwesomeIcons.wineBottle,
    'cocktail': FontAwesomeIcons.martiniGlassCitrus,
    'whiskey': FontAwesomeIcons.whiskeyGlass,
    'tea': FontAwesomeIcons.mugSaucer,
    'birthday': FontAwesomeIcons.cakeCandles,
    'pepper': FontAwesomeIcons.pepperHot,
    'money': FontAwesomeIcons.moneyBill,
    'coins': FontAwesomeIcons.coins,
    'credit_card': FontAwesomeIcons.creditCard,
    'bitcoin': FontAwesomeIcons.bitcoin,
    'ethereum': FontAwesomeIcons.ethereum,
    'chart_line': FontAwesomeIcons.chartLine,
    'chart_pie': FontAwesomeIcons.chartPie,
    'calculator': FontAwesomeIcons.calculator,
    'briefcase_medical': FontAwesomeIcons.briefcaseMedical,
    'pencil': FontAwesomeIcons.pencil,
    'ruler': FontAwesomeIcons.ruler,
    'chalkboard': FontAwesomeIcons.chalkboard,
    'microphone_alt': FontAwesomeIcons.microphoneLines,
    'headset': FontAwesomeIcons.headphonesSimple,
    'radio': FontAwesomeIcons.radio,
    'tv': FontAwesomeIcons.tv,
    'satellite_dish': FontAwesomeIcons.satelliteDish,
    'blender': FontAwesomeIcons.blender,
    'oven': FontAwesomeIcons.temperatureEmpty,
    'grill': FontAwesomeIcons.fireBurner,
    'cutlery': FontAwesomeIcons.utensils,
    'plate': FontAwesomeIcons.plateWheat,
    'spoon': FontAwesomeIcons.spoon,
    'bowl': FontAwesomeIcons.bowlFood,
    'trash': FontAwesomeIcons.trash,
    'recycle_alt': FontAwesomeIcons.recycle,
    'solar_panel': FontAwesomeIcons.solarPanel,
    'wind_turbine': FontAwesomeIcons.wind,
    'nuclear': FontAwesomeIcons.radiation,
    'battery': FontAwesomeIcons.batteryFull,
    'charging': FontAwesomeIcons.bolt,
    'gas_pump': FontAwesomeIcons.gasPump,
    'oil_can': FontAwesomeIcons.oilCan,
    'smoking': FontAwesomeIcons.smoking,
    'allergy': FontAwesomeIcons.handDots,
    'xray': FontAwesomeIcons.xRay,
    'heartbeat': FontAwesomeIcons.heartPulse,
    'lungs': FontAwesomeIcons.lungs,
    'brain_circuit': FontAwesomeIcons.brain,
    'eye': FontAwesomeIcons.eye,
    'ear': FontAwesomeIcons.earListen,
    'scale': FontAwesomeIcons.weightScale,
    'treadmill': FontAwesomeIcons.personRunning,
    'yoga': FontAwesomeIcons.personPraying,
    'hiking_alt': FontAwesomeIcons.personHiking,
    'shield_alt': FontAwesomeIcons.shieldHalved,
    'helmet': FontAwesomeIcons.helmetSafety,
    'megaphone': FontAwesomeIcons.bullhorn,
    'fire_extinguisher': FontAwesomeIcons.fireExtinguisher,
    'police': FontAwesomeIcons.shield,
    'ambulance': FontAwesomeIcons.truckMedical,
    'siren': FontAwesomeIcons.circleExclamation,
    'construction': FontAwesomeIcons.triangleExclamation,
    'hardhat': FontAwesomeIcons.hardHat,
    'blueprint': FontAwesomeIcons.drawPolygon,
    'ruler_combined': FontAwesomeIcons.rulerCombined,
    'compass_drafting': FontAwesomeIcons.compassDrafting,
    'paint_brush': FontAwesomeIcons.paintbrush,
    'spraycan': FontAwesomeIcons.sprayCan,
    'ruler_vertical': FontAwesomeIcons.rulerVertical,
    'cubes': FontAwesomeIcons.cubes,
    'pallet': FontAwesomeIcons.pallet,
    'forklift': FontAwesomeIcons.truckFront,
    'warehouse': FontAwesomeIcons.warehouse,
    'parachute': FontAwesomeIcons.parachuteBox,
    'sonar': FontAwesomeIcons.water,
    'fighter_jet': FontAwesomeIcons.jetFighter,
    'parachute_alt': FontAwesomeIcons.parachuteBox,
    'luggage': FontAwesomeIcons.suitcaseRolling,
    'passport_alt': FontAwesomeIcons.idCardClip,
    'language': FontAwesomeIcons.language,
    'translate': FontAwesomeIcons.earthAsia,
    'hierarchy': FontAwesomeIcons.diagramProject,
    'network': FontAwesomeIcons.networkWired,
    'blockchain': FontAwesomeIcons.link,
    'cpu': FontAwesomeIcons.microchip,
   'fan': FontAwesomeIcons.fan,
    'magnet': FontAwesomeIcons.magnet,
    'hourglass': FontAwesomeIcons.hourglassHalf,
    'stopwatch_alt': FontAwesomeIcons.stopwatch20,
    'alarm_clock': FontAwesomeIcons.clock,
    'calendar_alt': FontAwesomeIcons.calendarDays,
    'diary': FontAwesomeIcons.bookJournalWhills,
    'scroll': FontAwesomeIcons.scroll,
    'quill': FontAwesomeIcons.featherPointed,
    'typewriter': FontAwesomeIcons.keyboard,
    'newspaper_alt': FontAwesomeIcons.newspaper,
    'blog': FontAwesomeIcons.blog,
    'podcast': FontAwesomeIcons.podcast,
    'ad': FontAwesomeIcons.rectangleAd,
    'megaphone_alt': FontAwesomeIcons.bullhorn,
    'hashtag_alt': FontAwesomeIcons.hashtag,
    'at': FontAwesomeIcons.at,
    'envelope': FontAwesomeIcons.envelope,
    'voicemail': FontAwesomeIcons.voicemail,
    'phone': FontAwesomeIcons.phone,
    'phone_alt': FontAwesomeIcons.phoneFlip,
    'fax': FontAwesomeIcons.fax,
    'printer_alt': FontAwesomeIcons.print,
    'ethernet': FontAwesomeIcons.ethernet,
    'sd_card': FontAwesomeIcons.sdCard,
    'sim_card': FontAwesomeIcons.simCard,
    'memory': FontAwesomeIcons.memory,
    'barcode': FontAwesomeIcons.barcode,
    'qr_code': FontAwesomeIcons.qrcode,
    'shopping_basket': FontAwesomeIcons.basketShopping,
    'receipt': FontAwesomeIcons.receipt,
    'tags': FontAwesomeIcons.tags,
    'price_tag': FontAwesomeIcons.tag,
    'truck': FontAwesomeIcons.truck,
    'delivery': FontAwesomeIcons.truckFast,
    'package_alt': FontAwesomeIcons.boxOpen,
    'fork_knife': FontAwesomeIcons.utensils,
    'salad_alt': FontAwesomeIcons.bowlFood,
    'soup': FontAwesomeIcons.bowlRice,
    'pasta': FontAwesomeIcons.plateWheat,
    'rice': FontAwesomeIcons.bowlRice,
    'milk': FontAwesomeIcons.jugDetergent,
    'spices': FontAwesomeIcons.mortarPestle,
    'grill_alt': FontAwesomeIcons.fireFlameCurved,
    'restaurant': FontAwesomeIcons.store,
    'farm': FontAwesomeIcons.tractor,
    'watering_can': FontAwesomeIcons.water,
    'seedling_alt': FontAwesomeIcons.seedling,
    'fence': FontAwesomeIcons.borderNone,
    'campfire': FontAwesomeIcons.fire,
    'tent': FontAwesomeIcons.tent,
    'fishing_rod': FontAwesomeIcons.fish,
    'life_ring': FontAwesomeIcons.lifeRing,
    'kayak': FontAwesomeIcons.sailboat,
    'archery': FontAwesomeIcons.bullseye,
    'golf': FontAwesomeIcons.golfBallTee,
    'bowling': FontAwesomeIcons.bowlingBall,
    'hockey': FontAwesomeIcons.hockeyPuck,
    'martial_arts': FontAwesomeIcons.handFist,
    'surfing': FontAwesomeIcons.water,
    'snowboarding': FontAwesomeIcons.personSnowboarding,
    'sledding': FontAwesomeIcons.sleigh,
    'chess_alt': FontAwesomeIcons.chessQueen,
    'dice_alt': FontAwesomeIcons.diceD20,
    'controller': FontAwesomeIcons.gamepad,
    'vr_headset': FontAwesomeIcons.vrCardboard,
    'kite': FontAwesomeIcons.wind,
    'piñata': FontAwesomeIcons.candyCane,
    'theater': FontAwesomeIcons.masksTheater,
    'ticket_alt': FontAwesomeIcons.ticketSimple,
    'camera_movie': FontAwesomeIcons.clapperboard,
    'director_chair': FontAwesomeIcons.chair,
    'music_video': FontAwesomeIcons.music,
    'drum_alt': FontAwesomeIcons.drumSteelpan,
    'piano': FontAwesomeIcons.music,
    'microscope_alt': FontAwesomeIcons.microscope,
    'test_tube': FontAwesomeIcons.vial,
    'dna_alt': FontAwesomeIcons.dna,
    'atom_alt': FontAwesomeIcons.atom,
    'magnet_alt': FontAwesomeIcons.magnet,
    'eclipse': FontAwesomeIcons.cloudSun,
    'constellation': FontAwesomeIcons.starAndCrescent,
    'shower_meteor': FontAwesomeIcons.meteor,
    'tornado': FontAwesomeIcons.tornado,
    'volcano_alt': FontAwesomeIcons.volcano,
    'mountain_city': FontAwesomeIcons.mountainCity,
    'map_alt': FontAwesomeIcons.mapLocation,
    'signpost': FontAwesomeIcons.signsPost,
    'passport_check': FontAwesomeIcons.passport,
    'suitcase_alt': FontAwesomeIcons.suitcaseRolling,
    'hotel': FontAwesomeIcons.bed,
    'concierge': FontAwesomeIcons.bellConcierge,
    'luggage_cart': FontAwesomeIcons.luggageCart,
    'beach': FontAwesomeIcons.umbrellaBeach,
    'mountain_sun': FontAwesomeIcons.mountainSun,
    'binoculars': FontAwesomeIcons.binoculars,
    'water_bottle': FontAwesomeIcons.bottleWater,
    'camping_alt': FontAwesomeIcons.campground,
    'icicles': FontAwesomeIcons.icicles,
    'bonsai': FontAwesomeIcons.tree,
    'bird': FontAwesomeIcons.dove,
    'paw': FontAwesomeIcons.paw,
    'horse': FontAwesomeIcons.horse,
    'frog': FontAwesomeIcons.frog,
    'dragon': FontAwesomeIcons.dragon,
    'spider': FontAwesomeIcons.spider,
    'cockroach': FontAwesomeIcons.bug,
    'whale': FontAwesomeIcons.fish,
    'dolphin': FontAwesomeIcons.fishFins,
    'shark': FontAwesomeIcons.fishFins,
    'dinosaur': FontAwesomeIcons.dragon,
    'robot_alt': FontAwesomeIcons.robot,
    'alien': FontAwesomeIcons.jedi,
    'nebula': FontAwesomeIcons.cloudMoon,
    'black_hole': FontAwesomeIcons.circleRadiation,
    'satellite_alt': FontAwesomeIcons.satellite,
    'astronaut': FontAwesomeIcons.userAstronaut,
    'flag_alt': FontAwesomeIcons.flagCheckered,
    'anchor_alt': FontAwesomeIcons.anchorCircleCheck,
    'ship_wheel': FontAwesomeIcons.ship,
    'baseball_alt': FontAwesomeIcons.baseballBatBall,
    'gym': FontAwesomeIcons.dumbbell,
    'yoga_alt': FontAwesomeIcons.spa,
    'meditation_alt': FontAwesomeIcons.om,
    'prayer': FontAwesomeIcons.handsPraying,
    'church_alt': FontAwesomeIcons.church,
    'synagogue_alt': FontAwesomeIcons.synagogue
  };

  static const Map<String, Color> categoryColors = {
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

  static Color getColorFromString(BuildContext context,String? colorKey) {
    if (colorKey == null || colorKey == 'primary') return Theme.of(context).colorScheme.primary;
    return categoryColors[colorKey] ?? Theme.of(context).colorScheme.primary;
  }

  static String? getStringFromColor(Color color) {
    return categoryColors.entries
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
