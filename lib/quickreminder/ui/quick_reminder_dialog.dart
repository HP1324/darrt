import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minimaltodo/app/notification/notification_service.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/messages.dart' show Messages;
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/quickreminder/model/quick_reminder.dart';
import 'package:toastification/toastification.dart';

import '../../helpers/consts.dart' show notifReminderType, alarmReminderType;

class QuickReminderDialog extends StatefulWidget {
  const QuickReminderDialog({super.key, required this.edit, this.reminder})
    : assert(!edit || reminder != null);
  final bool edit;
  final QuickReminder? reminder;
  @override
  State<QuickReminderDialog> createState() => _QuickReminderDialogState();
}

class _QuickReminderDialogState extends State<QuickReminderDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  late String type = notifReminderType;
  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      type = widget.reminder!.type!;
      _titleController.text = widget.reminder!.title ?? '';
      _minutesController.text = widget.reminder!.durationMinutes.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return AlertDialog.adaptive(
      shape: OutlineInputBorder(),
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quick reminder',
            style: textTheme.titleMedium,
          ),
          Tooltip(
            showDuration: Duration(milliseconds: 6000),
            triggerMode: TooltipTriggerMode.tap,
            message: Messages.mQuickReminderMessage,
            child: Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      content: Column(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Reminder type selection segmented buttons string
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: notifReminderType,
                label: FittedBox(child: Text('Notification')),
              ),
              ButtonSegment(value: alarmReminderType, label: Text('Alarm')),
            ],
            selected: {type},
            onSelectionChanged: (selected) {
              setState(() {
                type = selected.first;
              });
            },
          ),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title (optional)',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
          ),
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Remind me after'),
                SizedBox(width: 8),
                Flexible(
                  child: IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 40,
                        maxWidth: 80,
                      ),
                      child: TextField(
                        controller: _minutesController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          isDense: true,
                          counterText: '',
                          errorText: null,
                        ),
                        style: TextStyle(fontSize: 16, height: 1.2),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) {
                              // Don't allow starting with 0
                              if (newValue.text.startsWith('0') && newValue.text.isNotEmpty) {
                                return oldValue;
                              }

                              if (newValue.text.isEmpty) return newValue;
                              final intValue = int.tryParse(newValue.text);
                              if (intValue != null && intValue > 999) {
                                return oldValue;
                              }
                              return newValue;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text('minutes'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final title = _titleController.text;
            final minutes = int.parse(_minutesController.text);
            showToast(
              context,
              type: ToastificationType.success,
              description:
                  'Reminder set after ${minutes > 1 ? '$minutes minutes' : '$minutes minute'}',
            );
            Navigator.pop(context);
            final notifId = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
            await NotificationService.scheduleQuickReminder(id: notifId, title, minutes, type: type);
            MiniLogger.dp('title: $title, minutes: $minutes, type: ${minutes.runtimeType}');


            final reminder =  QuickReminder(
              id: widget.edit ? widget.reminder!.id : 0,
              notifId: notifId,
              durationMinutes: minutes,
              title: title,
              type: type,
            );

            g.quickVm.putItem(reminder, edit: widget.edit);
          },
          child: Text('Set Reminder'),
        ),
      ],
    );
  }

}
