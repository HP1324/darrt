import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g show buildHabitSc;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
class TargetSelector extends StatefulWidget {
  const TargetSelector({super.key});

  @override
  State<TargetSelector> createState() => _TargetSelectorState();
}

class _TargetSelectorState extends State<TargetSelector> {
  Icon icon = Icon(Icons.add_circle_outline_rounded);
  bool isExpanded = false;
  late VoidCallback _unitListener;
  String unitText = '';

  @override
  void initState() {
    super.initState();
    _unitListener = () {
      if (!mounted) return;
      setState(() {
        unitText = g.buildHabitSc.unitController.text;
      });
    };
    g.buildHabitSc.unitController.addListener(_unitListener);
  }

  @override
  void dispose(){
    g.buildHabitSc.removeListener(_unitListener);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;
    return  ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
              icon = Icon(
                expanded ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
                color: color,
              );
            });
          },
          title: Text(
            'Set Targets${unitText.isEmpty ? '' : ' ($unitText)'}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: color,
          collapsedIconColor: color,
          shape: RoundedRectangleBorder(),
          trailing: icon,
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Column(
              spacing: 12,
              children: [
                DailyTarget(),
                WeeklyTarget(),
                MonthlyTarget(),
                YearlyTarget(),
              ],
            ),
          ],
        );
  }
}

class TargetItem extends StatefulWidget {
  const TargetItem({
    super.key,
    required this.label,
    this.targetCount = 0,
    this.onChanged,
  });
  final String label;
  final int targetCount;
  final ValueChanged<int>? onChanged;

  @override
  State<TargetItem> createState() => _TargetItemState();
}

class _TargetItemState extends State<TargetItem> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late VoidCallback _unitListener;
  Timer? _longPressTimer;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.targetCount.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(TargetItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetCount != widget.targetCount) {
      _controller.text = widget.targetCount.toString();
    }
  }

  void _increment() {
    final newValue = widget.targetCount + 1;
    widget.onChanged?.call(newValue);
  }

  void _decrement() {
    final newValue = (widget.targetCount - 1).clamp(0, 999999);
    widget.onChanged?.call(newValue);
  }

  void _startLongPressIncrement() {
    _isLongPressing = true;
    _longPressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isLongPressing) {
        timer.cancel();
        return;
      }
      if (!mounted) {  // <--- Add this mounted check
        timer.cancel();
        return;
      }
      _increment();
    });
  }

  void _startLongPressDecrement() {
    if (widget.targetCount > 0) {
      _isLongPressing = true;
      _longPressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (!_isLongPressing || widget.targetCount <= 0) {
          timer.cancel();
          return;
        }
        if (!mounted) {  // <--- Add this mounted check
          timer.cancel();
          return;
        }
        _decrement();
      });
    }
  }


  void _stopLongPress() {
    _isLongPressing = false;
    _longPressTimer?.cancel();
  }

  void _onTextChanged(String value) {
    final intValue = int.tryParse(value) ?? 0;
    if (intValue != widget.targetCount) {
      widget.onChanged?.call(intValue.clamp(0, 999999));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;

    return Row(
      children: [
        // Label
        SizedBox(
          width: 70,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
        ),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Decrement button with long press
              GestureDetector(
                onTap: widget.targetCount > 0 ? _decrement : null,
                onLongPressStart: widget.targetCount > 0 ? (_) => _startLongPressDecrement() : null,
                onLongPressEnd: (_) => _stopLongPress(),
                onLongPressCancel: _stopLongPress,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.targetCount > 0
                              ? color.withValues(alpha: 0.5)
                              : scheme.outline.withValues(alpha: 0.3),
                        ),
                        color: _isLongPressing && widget.targetCount > 0
                            ? color.withValues(alpha: 0.1)
                            : null,
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 16,
                        color: widget.targetCount > 0
                            ? color
                            : scheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),

              // Text field
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: _onTextChanged,
                  onSubmitted: (_) => _focusNode.unfocus(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color, width: 2),
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),

              SizedBox(width: 12),

              // Increment button with long press
              GestureDetector(
                onTap: _increment,
                onLongPressStart: (_) => _startLongPressIncrement(),
                onLongPressEnd: (_) => _stopLongPress(),
                onLongPressCancel: _stopLongPress,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withValues(alpha: 0.5)),
                        color: _isLongPressing
                            ? color.withValues(alpha: 0.1)
                            : null,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}


class DailyTarget extends StatelessWidget {
  const DailyTarget({super.key});

  @override
  Widget build(BuildContext context) {
    return TargetItem(
      label: 'Daily',
      targetCount: g.buildHabitSc.target.daily,
      onChanged: (value) {
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(daily: value),
        );
      },
    );
  }
}

class WeeklyTarget extends StatelessWidget {
  const WeeklyTarget({super.key});

  @override
  Widget build(BuildContext context) {
    return TargetItem(
      label: 'Weekly',
      targetCount: g.buildHabitSc.target.weekly,
      onChanged: (value) {
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(weekly: value),
        );
      },
    );
  }
}

class MonthlyTarget extends StatelessWidget {
  const MonthlyTarget({super.key});

  @override
  Widget build(BuildContext context) {
    return TargetItem(
      label: 'Monthly',
      targetCount: g.buildHabitSc.target.monthly,
      onChanged: (value) {
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(monthly: value),
        );
      },
    );
  }
}

class YearlyTarget extends StatelessWidget {
  const YearlyTarget({super.key});

  @override
  Widget build(BuildContext context) {
    return TargetItem(
      label: 'Yearly',
      targetCount: g.buildHabitSc.target.yearly,
      onChanged: (value) {
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(yearly: value),
        );
      },
    );
  }
}
