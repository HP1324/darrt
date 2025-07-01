import 'package:minimaltodo/app/state/managers/calendar_manager.dart' show CalendarManager;
import 'package:minimaltodo/app/state/managers/navigation_manager.dart' show NavigationManager;
import 'package:minimaltodo/app/state/managers/theme_manager.dart' show ThemeManager;
import 'package:minimaltodo/app/state/controllers/settings_state_controller.dart';
import 'package:minimaltodo/app/state/viewmodels/view_model.dart';
import 'package:minimaltodo/category/state/category_state_controller.dart' show CategoryStateController;
import 'package:minimaltodo/category/state/category_view_model.dart' show CategoryViewModel;
import 'package:minimaltodo/note/state/folder_state_controller.dart' show FolderStateController;
import 'package:minimaltodo/note/state/folder_view_model.dart' show FolderViewModel;
import 'package:minimaltodo/note/state/note_state_controller.dart';
import 'package:minimaltodo/note/state/note_view_model.dart' show NoteViewModel;
import 'package:minimaltodo/note/ui/add_note_page.dart';
import 'package:minimaltodo/task/state/completion_view_model.dart';
import 'package:minimaltodo/task/state/task_state_controller.dart' show TaskStateController;
import 'package:minimaltodo/task/state/task_view_model.dart' show TaskViewModel;
import 'package:minimaltodo/task/ui/add_task_page.dart';
import 'package:uuid/uuid.dart';



final taskSc = TaskStateController();

final taskVm = TaskViewModel();

final catSc = CategoryStateController();

final catVm = CategoryViewModel();

final noteSc = NoteStateController();

final noteVm = NoteViewModel();

final folderSc = FolderStateController();

final folderVm = FolderViewModel();

final themeMan = ThemeManager();

final calMan = CalendarManager();

final navMan = NavigationManager();

final taskSttController = TaskSttController();

final noteSttController = NoteSttController();

final settingsSc = SettingsStateController();

final completionVm = CompletionViewModel();

final Uuid uuid = Uuid();




