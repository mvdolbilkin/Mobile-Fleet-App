import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';

enum DatePickerMode { day, month, year }

class DateRange {
  final DateTime start;
  final DateTime end;
  const DateRange({required this.start, required this.end});
}

class CustomDateRangePickerBottomSheet extends StatefulWidget {
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;

  const CustomDateRangePickerBottomSheet({
    Key? key,
    required this.title,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  static Future<DateRange?> show({
    required BuildContext context,
    required String title,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return showModalBottomSheet<DateRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomDateRangePickerBottomSheet(
        title: title,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  State<CustomDateRangePickerBottomSheet> createState() =>
      _CustomDateRangePickerBottomSheetState();
}

class _CustomDateRangePickerBottomSheetState
    extends State<CustomDateRangePickerBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSelectingEnd = false;
  late DateTime _displayedMonth;
  DatePickerMode _mode = DatePickerMode.day;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _isSelectingEnd = _startDate != null && _endDate == null;
    final base = widget.startDate ?? DateTime.now();
    _displayedMonth = DateTime(base.year, base.month);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isFutureDate(DateTime date) {
    final today = DateTime.now();
    return date.isAfter(DateTime(today.year, today.month, today.day));
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  void _onDayTapped(DateTime date) {
    if (_isFutureDate(date)) return;
    setState(() {
      if (!_isSelectingEnd) {
        _startDate = date;
        _endDate = null;
        _isSelectingEnd = true;
      } else {
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
        _isSelectingEnd = false;
      }
    });
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    setState(() => _displayedMonth = next);
  }

  bool _canGoNext() {
    final now = DateTime.now();
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    return !next.isAfter(DateTime(now.year, now.month));
  }

  String _getMonthName(int m) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
    ];
    return months[m - 1];
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  List<DateTime?> _getDays() {
    final first = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final last = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final days = <DateTime?>[];
    for (int i = 1; i < first.weekday; i++) days.add(null);
    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(_displayedMonth.year, _displayedMonth.month, d));
    }
    while (days.length % 7 != 0) days.add(null);
    return days;
  }

  void _selectMonth(int month) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, month);
      _mode = DatePickerMode.day;
    });
  }

  void _selectYear(int year) {
    setState(() {
      _displayedMonth = DateTime(year, _displayedMonth.month);
      _mode = DatePickerMode.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasRange = _startDate != null && _endDate != null;
    final stepText = _startDate == null
        ? 'Выберите начало периода'
        : _isSelectingEnd
            ? 'Теперь выберите конец периода'
            : hasRange
                ? '${_formatDate(_startDate!)}  —  ${_formatDate(_endDate!)}'
                : _formatDate(_startDate!);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppTheme.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: AppTheme.listTitle),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppTheme.textSecondary, size: 24),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _startDate != null
                          ? AppTheme.buttonColor
                          : AppTheme.borderColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stepText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (hasRange)
                    GestureDetector(
                      onTap: () => setState(() {
                        _startDate = null;
                        _endDate = null;
                        _isSelectingEnd = false;
                      }),
                      child: const Text(
                        'Сбросить',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                ],
              ),
            ),

            if (_mode == DatePickerMode.day) _buildDayPicker(),
            if (_mode == DatePickerMode.month) _buildMonthPicker(),
            if (_mode == DatePickerMode.year) _buildYearPicker(),

            const SizedBox(height: 8),

            if (_mode == DatePickerMode.day && hasRange)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(
                    context,
                    DateRange(start: _startDate!, end: _endDate!),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Применить',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    final days = _getDays();
    final monthYear =
        '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                color: AppTheme.textPrimary,
              ),
              GestureDetector(
                onTap: () => setState(() => _mode = DatePickerMode.month),
                child: Row(
                  children: [
                    Text(
                      monthYear,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              IconButton(
                onPressed: _canGoNext() ? _nextMonth : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: _canGoNext()
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildDaysGrid(days),
        ),
      ],
    );
  }

  Widget _buildDaysGrid(List<DateTime?> days) {
    final rows = <Widget>[];
    for (int r = 0; r < days.length ~/ 7; r++) {
      rows.add(_buildWeekRow(days.sublist(r * 7, (r + 1) * 7)));
      if (r < days.length ~/ 7 - 1) rows.add(const SizedBox(height: 4));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _buildWeekRow(List<DateTime?> week) {
    return Row(
      children: week.map((d) => Expanded(child: _buildDayCell(d))).toList(),
    );
  }

  Widget _buildDayCell(DateTime? date) {
    if (date == null) return const SizedBox(height: 40);

    final isStart = _startDate != null && _isSameDay(date, _startDate!);
    final isEnd = _endDate != null && _isSameDay(date, _endDate!);
    final inRange = _isInRange(date);
    final isFuture = _isFutureDate(date);
    final isSelected = isStart || isEnd;

    final rangeColor = AppTheme.buttonColor.withOpacity(0.2);

    final showLeft = inRange ||
        (isEnd &&
            _startDate != null &&
            !_isSameDay(_startDate!, date));
    final showRight = inRange ||
        (isStart &&
            _endDate != null &&
            !_isSameDay(_endDate!, date));

    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                  child: Container(
                      color:
                          showLeft ? rangeColor : Colors.transparent)),
              Expanded(
                  child: Container(
                      color:
                          showRight ? rangeColor : Colors.transparent)),
            ],
          ),
          Center(
            child: GestureDetector(
              onTap: isFuture ? null : () => _onDayTapped(date),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.buttonColor
                      : inRange
                          ? rangeColor
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isFuture
                          ? AppTheme.textSecondary.withOpacity(0.3)
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    final now = DateTime.now();
    final currentYear = _displayedMonth.year;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: () => setState(() => _mode = DatePickerMode.year),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$currentYear',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isCurrent = month == _displayedMonth.month &&
                  currentYear == _displayedMonth.year;
              final isFuture = currentYear > now.year ||
                  (currentYear == now.year && month > now.month);
              return GestureDetector(
                onTap: isFuture ? null : () => _selectMonth(month),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppTheme.buttonColor
                        : AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getMonthName(month),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isFuture
                            ? AppTheme.textSecondary.withOpacity(0.3)
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearPicker() {
    final now = DateTime.now();
    final years =
        List.generate(now.year - 1970 + 1, (i) => now.year - i);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView.builder(
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == _displayedMonth.year;
          return GestureDetector(
            onTap: () => _selectYear(year),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              color:
                  isSelected ? AppTheme.buttonColor : Colors.transparent,
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
