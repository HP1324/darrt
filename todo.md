## Features to include in next releases

- [ ] Allow to save focus sessions
- [ ] Add calendar view with syncfusion calendar widget
- [ ] Add AI voices when focus and break ends. (i.e., "Time to take a break", "Let's get ready" etc.)
- [ ] Include the following in notification actions(NotificationActionController, NotificationService)
  - [ ] When user taps snooze, open a dialog on system level that allows to choose snooze duration, and also gives a checkbox to not ask this dialog again and just use default snooze value from settings
  - [ ] Add an action button to Postpone the task, on click of this, open a dialog that allows to choose postpone duration, and also gives a checkbox to not ask this dialog again and just use default postpone value from settings, this is only when task.isRepeating is false, i.e., the task is one time only. and if task.isRepeating is true, then give an action button named skip and do nothing on this one, because task is already marked as unfinished, so no need to do anything for this skip button, it's just for the user to give a semantic understanding rather than just dismissing the notification.