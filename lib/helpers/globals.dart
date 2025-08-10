import 'package:darrt/app/ads/ads_controller.dart';
import 'package:darrt/app/state/managers/calendar_manager.dart' show CalendarManager;
import 'package:darrt/app/state/managers/navigation_manager.dart' show NavigationManager;
import 'package:darrt/app/state/managers/theme_manager.dart' show ThemeManager;
import 'package:darrt/app/ui/settings_page/settings_state_controller.dart';
import 'package:darrt/category/state/category_state_controller.dart' show CategoryStateController;
import 'package:darrt/category/state/category_view_model.dart' show CategoryViewModel;
import 'package:darrt/focustimer/sound/sound_controller.dart';
import 'package:darrt/focustimer/timer/timer_controller.dart' show TimerController;
import 'package:darrt/note/state/folder_state_controller.dart' show FolderStateController;
import 'package:darrt/note/state/folder_view_model.dart' show FolderViewModel;
import 'package:darrt/note/state/note_state_controller.dart';
import 'package:darrt/note/state/note_view_model.dart' show NoteViewModel;
import 'package:darrt/note/ui/add_note_page.dart';
import 'package:darrt/quickreminder/state/quick_reminder_view_model.dart';
import 'package:darrt/task/state/completion_view_model.dart';
import 'package:darrt/task/state/task_state_controller.dart' show TaskStateController;
import 'package:darrt/task/state/task_stt_controller.dart';
import 'package:darrt/task/state/task_view_model.dart' show TaskViewModel;
import 'package:uuid/uuid.dart';



late final taskSc = TaskStateController();

late final taskVm = TaskViewModel();

late final catSc = CategoryStateController();

late final catVm = CategoryViewModel();

late final noteSc = NoteStateController();

late final noteVm = NoteViewModel();

late final folderSc = FolderStateController();

late final folderVm = FolderViewModel();

late final themeMan = ThemeManager();

late final calMan = CalendarManager();

late final navMan = NavigationManager();

late final taskSttController = TaskSttController();

late final noteSttController = NoteSttController();

late final settingsSc = SettingsStateController();

late final completionVm = CompletionViewModel();

late final quickVm = QuickReminderViewModel();

late final audioController = SoundController();

late final timerController = TimerController();

late final adsController = AdsController();

late final Uuid uuid = Uuid();




