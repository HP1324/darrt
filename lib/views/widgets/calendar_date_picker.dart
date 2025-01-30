import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MiniCalendarDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime minDate;
  final DateTime maxDate;
  final ValueChanged<DateTime> onDateChanged;

  const MiniCalendarDatePicker({
    super.key,
    required this.selectedDate,
    required this.minDate,
    required this.maxDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _YearSelector(
            selectedDate: selectedDate,
            minDate: minDate,
            maxDate: maxDate,
            onYearSelected: (year) => _handleYearChange(context, year),
          ),
          const SizedBox(height: 16),
          _MonthGrid(
            selectedDate: selectedDate,
            onDateSelected: onDateChanged,
          ),
        ],
      ),
    );
  }

  void _handleYearChange(BuildContext context, int year) {
    final newDate = DateTime(
      year,
      selectedDate.month,
      selectedDate.day.clamp(1, DateUtils.getDaysInMonth(year, selectedDate.month)),
    );

    if (newDate.isAfter(maxDate) || newDate.isBefore(minDate)) return;
    onDateChanged(newDate);
  }
}

class _YearSelector extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime minDate;
  final DateTime maxDate;
  final ValueChanged<int> onYearSelected;

  const _YearSelector({
    required this.selectedDate,
    required this.minDate,
    required this.maxDate,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: colorScheme.primary),
              onPressed: () => onYearSelected(selectedDate.year - 1),
            ),
            Text(
              selectedDate.year.toString(),
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: colorScheme.primary),
              onPressed: () => onYearSelected(selectedDate.year + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _MonthGrid({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    return Table(
      children: [
        TableRow(
          children: DateFormat.E().dateSymbols.SHORTWEEKDAYS.map((day) =>
              Center(child: Text(day, style: Theme.of(context).textTheme.bodySmall))
          ).toList(),
        ),
        ..._buildCalendarRows(firstDay, lastDay, selectedDate, colorScheme),
      ],
    );
  }

  List<TableRow> _buildCalendarRows(DateTime firstDay, DateTime lastDay, DateTime selectedDate, ColorScheme colors) {
    final rows = <TableRow>[];
    DateTime currentDay = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    while (currentDay.isBefore(lastDay) || rows.length < 6) {
      final cells = <Widget>[];

      for (int i = 0; i < 7; i++) {
        final isSelected = currentDay.year == selectedDate.year &&
            currentDay.month == selectedDate.month &&
            currentDay.day == selectedDate.day;

        cells.add(
          GestureDetector(
            onTap: () => onDateSelected(currentDay),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  currentDay.day.toString(),
                  style: TextStyle(
                    color: isSelected ? colors.onPrimary : colors.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
        currentDay = currentDay.add(const Duration(days: 1));
      }

      rows.add(TableRow(children: cells));
    }

    return rows;
  }
}