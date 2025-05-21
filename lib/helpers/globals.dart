import 'package:minimaltodo/app/state/managers/calendar_manager.dart' show CalendarManager;
import 'package:minimaltodo/app/state/managers/theme_manager.dart' show ThemeManager;
import 'package:minimaltodo/category/state/category_state_controller.dart' show CategoryStateController;
import 'package:minimaltodo/category/state/category_view_model.dart' show CategoryViewModel;
import 'package:minimaltodo/note/state/folder_state_controller.dart' show FolderStateController;
import 'package:minimaltodo/note/state/folder_view_model.dart' show FolderViewModel;
import 'package:minimaltodo/note/state/note_state_controller.dart';
import 'package:minimaltodo/note/state/note_view_model.dart' show NoteViewModel;
import 'package:minimaltodo/task/state/task_state_controller.dart' show TaskStateController;
import 'package:minimaltodo/task/state/task_view_model.dart' show TaskViewModel;


late final taskSc = TaskStateController();

late final taskVm = TaskViewModel();

late final catSc = CategoryStateController();

late final catVm = CategoryViewModel();

late final noteSc = NoteStateController();

late final noteVm = NoteViewModel();

late final folderSc = FolderStateController();

late final folderVm = FolderViewModel();

late final themeM = ThemeManager();

late final calMan = CalendarManager();




