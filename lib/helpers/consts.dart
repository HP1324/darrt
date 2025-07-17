import 'dart:typed_data';

const mFirstInstallDate = 'first_install_date';

const mFirstTimeInstall = 'first_time_install';

///Whether this is first time notification permission is requested
const mFirstTimeNotifPermission = 'first_time_notif';

///Whether the notification channels initialized or not
const mChannelsInit = 'channels_init';

///Whether or not the notifications are enabled
const mNotificationsEnabled = 'notifications_enabled';

///If user has enabled notifications globally in settings or not
const mIsNotificationsGloballyEnabled = 'is_notifications_globally_enabled';

///Which type of tasks to show by default, it stores 0, 1 and 2 for [TaskType.all, TaskType.single, TaskType.recurring] respectively
const mDefaultTaskList = 'default_task_list';

const mThemeColor = 'theme_color';

const mThemePreference = 'theme_preference';

const mDefaultReminderType = 'default_reminder_type';

const mPickedAlarmSoundResourceUri = 'picked_alarm_sound_resource_uri';

const mPickedAlarmSoundName = 'picked_alarm_sound_name';

const mNotificationSound = 'notification_sound';

const firstTimeMicTap = 'first_time_mic_tap';

const micPermissionDeniedAgain = 'mic_permission_denied_again';

///How much minutes to snooze when user presses snooze action button in notification
const mSnoozeMinutes = 'snooze_minutes';

const alarmChannelKey = 'task_alarm';

const notifChannelKey = 'task_notif';

const notifReminderType = 'notif';

const alarmReminderType = 'alarm';

const mGoogleEmail = 'google_email';

const mGoogleAuthToken = 'google_auth_token';

const mGoogleRefreshToken = 'google_refresh_token';

const mLastBackupDate = 'last_backup_date';

const mAutoBackup = 'auto_backup';

const mAutoBackupFrequency = 'auto_backup_frequency';

const mCanPop = 'can_pop';

const tapHereToSignIn = 'Tap here to sign in to google account';

const googleClientId = "569574442549-543mjpqcfhsivrn5atcoblifvbkvg0vp.apps.googleusercontent.com";

Uint8List noteEmptyErrorBytes = Uint8List(0);

final mInitialDate = DateTime(2000, 1, 1);

const maxExtentDateDays = 7305;


// Timer Settings Constants
const String mAutoSwitchToBreak = 'auto_switch_to_break';
const String mAutoSwitchToFocus = 'auto_switch_to_focus';
const String mMarkTasksFinished = 'mark_tasks_finished';
const String mShowTimerNotification = 'show_timer_notification';
const String mPauseResumeSound = 'pause_resume_sound';