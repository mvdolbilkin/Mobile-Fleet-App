import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';

enum DatePickerMode { day, month, year }

class CustomDatePickerBottomSheet extends StatefulWidget {
  final String title;
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDatePickerBottomSheet({
    Key? key,
    required this.title,
    this.selectedDate,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  static Future<DateTime?> show({
    required BuildContext context,
    required String title,
    DateTime? selectedDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomDatePickerBottomSheet(
        title: title,
        selectedDate: selectedDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  @override
  State<CustomDatePickerBottomSheet> createState() => _CustomDatePickerBottomSheetState();
}

class _CustomDatePickerBottomSheetState extends State<CustomDatePickerBottomSheet> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  DatePickerMode _mode = DatePickerMode.day;
  late PageController _pageController;
  
  // Начальная страница - большое число, чтобы можно было листать назад
  static const int _initialPage = 10000;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    
    // Не позволяем переходить в будущие месяцы
    if (nextMonth.year > now.year || 
        (nextMonth.year == now.year && nextMonth.month > now.month)) {
      return;
    }
    
    setState(() {
      _displayedMonth = nextMonth;
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
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

  List<DateTime> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    
    final days = <DateTime>[];
    
    // Добавляем пустые дни в начале для выравнивания
    final firstWeekday = firstDayOfMonth.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      days.add(DateTime(0)); // Пустой день
    }
    
    // Добавляем все дни месяца
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_displayedMonth.year, _displayedMonth.month, day));
    }
    
    return days;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  bool _canGoToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    return nextMonth.year < now.year || 
           (nextMonth.year == now.year && nextMonth.month <= now.month);
  }

  String _getMonthName(int month) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderColor, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: AppTheme.listTitle,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Контент в зависимости от режима
            if (_mode == DatePickerMode.day) _buildDayPicker(),
            if (_mode == DatePickerMode.month) _buildMonthPicker(),
            if (_mode == DatePickerMode.year) _buildYearPicker(),

            const SizedBox(height: 16),

            // Кнопка подтверждения (только в режиме выбора дня)
            if (_mode == DatePickerMode.day)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, _selectedDate),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Выбрать ${_formatDate(_selectedDate)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
    final monthYear = '${_getMonthName(_displayedMonth.month)} ${_displayedMonth.year}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Навигация по месяцам
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.textPrimary,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _canGoToNextMonth() ? _nextMonth : null,
                icon: const Icon(Icons.chevron_right),
                color: _canGoToNextMonth()
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary.withOpacity(0.3),
              ),
            ],
          ),
        ),

        // Дни недели
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
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

        // PageView для свайпов между месяцами
        SizedBox(
          height: 320, // Фиксированная высота для календарной сетки
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              final offset = page - _initialPage;
              final newMonth = DateTime(
                _selectedDate.year,
                _selectedDate.month + offset,
              );
              
              // Проверяем, не является ли новый месяц будущим
              final now = DateTime.now();
              if (newMonth.year > now.year ||
                  (newMonth.year == now.year && newMonth.month > now.month)) {
                // Возвращаемся на текущую страницу
                _pageController.jumpToPage(page - 1);
                return;
              }
              
              setState(() {
                _displayedMonth = newMonth;
              });
            },
            itemBuilder: (context, page) {
              final offset = page - _initialPage;
              final monthToDisplay = DateTime(
                _selectedDate.year,
                _selectedDate.month + offset,
              );
              
              return _buildMonthGrid(monthToDisplay);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final days = _getDaysInMonthForDate(month);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          
          // Пустая ячейка
          if (date.year == 0) {
            return const SizedBox();
          }

          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isToday(date);
          final isFuture = _isFutureDate(date);

          return GestureDetector(
            onTap: isFuture ? null : () => _selectDate(date),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.buttonColor
                    : AppTheme.controlsColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
    );
  }

  List<DateTime> _getDaysInMonthForDate(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final days = <DateTime>[];
    
    // Добавляем пустые дни в начале для выравнивания
    final firstWeekday = firstDayOfMonth.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      days.add(DateTime(0)); // Пустой день
    }
    
    // Добавляем все дни месяца
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }
    
    return days;
  }

  Widget _buildMonthPicker() {
    final now = DateTime.now();
    final currentYear = _displayedMonth.year;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Заголовок с годом
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: () => setState(() => _mode = DatePickerMode.year),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$currentYear',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.textPrimary,
                ),
              ],
            ),
          ),
        ),

        // Сетка месяцев
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
              final monthName = _getMonthName(month);
              final isCurrentMonth = currentYear == _displayedMonth.year && 
                                     month == _displayedMonth.month;
              
              // Проверяем, является ли месяц будущим
              final isFutureMonth = currentYear > now.year || 
                                   (currentYear == now.year && month > now.month);

              return GestureDetector(
                onTap: isFutureMonth ? null : () => _selectMonth(month),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrentMonth
                        ? AppTheme.buttonColor
                        : AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrentMonth ? FontWeight.w600 : FontWeight.normal,
                        color: isFutureMonth
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
    final currentYear = now.year;
    final startYear = 1970;
    final years = List.generate(currentYear - startYear + 1, (index) => currentYear - index);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: ListView.builder(
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isCurrentYear = year == _displayedMonth.year;

          return GestureDetector(
            onTap: () => _selectYear(year),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: isCurrentYear
                    ? AppTheme.buttonColor
                    : Colors.transparent,
              ),
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCurrentYear ? FontWeight.w600 : FontWeight.normal,
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
