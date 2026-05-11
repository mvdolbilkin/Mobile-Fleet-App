import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/rents_repository.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/rents_calendar_models.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/rents_filters_sheet.dart';
import 'package:mobile/features/fleet/providers/rents_filters_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/features/fleet/presentation/rents_calendar/expense_detail_bottom_sheet.dart';
import 'package:mobile/shared/widgets/badge.dart';
import 'package:mobile/shared/widgets/search_field.dart';

class RentsCalendarScreen extends ConsumerStatefulWidget {
  const RentsCalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RentsCalendarScreen> createState() => _RentsCalendarScreenState();
}

class _RentsCalendarScreenState extends ConsumerState<RentsCalendarScreen> {
  DateTime _currentDate = DateTime.now();
  int _daysToShow = 2; // Как на дизайне - две колонки
  bool _isLoading = false;
  RentsCalendarResponse? _data;
  String _searchQuery = '';
  RentsFilter _filter = RentsFilter.defaultFilter;
  int _currentPage = 0;
  Map<String, String> _statusNames = {};
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Нормализуем текущую дату, убираем время
    _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final parkId = await ref.read(secureStorageServiceProvider).getParkId();
      if (parkId == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      final dbResponse = await ref.read(rentsRepositoryProvider).getVehiclesByDays(
        parkId: parkId,
        dateFrom: _currentDate,
        days: _daysToShow,
        limit: _filter.pageSize,
        offset: _currentPage * _filter.pageSize,
        searchText: _searchQuery.isNotEmpty ? _searchQuery : null,
        isRental: _filter.isRental,
        categories: _filter.categories.isNotEmpty ? _filter.categories : null,
        statuses: _filter.statuses.isNotEmpty ? _filter.statuses : null,
      );

      // Check if widget is still mounted
      if (!mounted) return;

      setState(() {
        _data = dbResponse;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading rents calendar: $e");
      setState(() => _isLoading = false);
    }
  }

  void _nextDays() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: _daysToShow));
    });
    _loadData();
  }

  void _prevDays() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: _daysToShow));
    });
    _loadData();
  }

  String _formatDateRange() {
    final endDate = _currentDate.add(Duration(days: _daysToShow - 1));
    final months = [
      'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня', 
      'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'
    ];
    
    if (_currentDate.month == endDate.month) {
      return '${_currentDate.day}-${endDate.day} ${months[_currentDate.month - 1]} ${_currentDate.year} г';
    } else {
      return '${_currentDate.day} ${months[_currentDate.month - 1]} - ${endDate.day} ${months[endDate.month - 1]} ${_currentDate.year} г';
    }
  }

  String _formatDayHeader(DateTime date) {
    final weekdays = ['пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс'];
    final wd = weekdays[date.weekday - 1];
    return '$wd, ${date.day}';
  }

  BadgeType _getStatusBadgeType(String? status) {
    switch (status) {
      case 'working': return BadgeType.working;
      case 'service': return BadgeType.service;
      case 'no_driver': return BadgeType.noDriver;
      default: return BadgeType.preparation;
    }
  }

  RentDriver? _findDriver(String id) {
    if (_data == null) return null;
    for (var d in _data!.drivers) {
      if (d.id == id) return d;
    }
    return null;
  }

  Color _getDriverColor(String lastName) {
    final colors = [
      Colors.red.shade900,
      Colors.orange.shade700,
      Colors.blue.shade800,
      Colors.green.shade800,
      Colors.purple.shade900,
      Colors.brown.shade800,
      Colors.pink.shade300,
      const Color(0xFF6B7280),
    ];
    
    if (lastName.isEmpty) return colors[0];
    final charCode = lastName.codeUnitAt(0);
    return colors[charCode % colors.length];
  }

  String _getDriverInitials(RentDriver? driver) {
    if (driver == null) return "?";
    String res = "";
    if (driver.firstName != null && driver.firstName!.isNotEmpty) {
      res += driver.firstName![0].toUpperCase();
    }
    if (driver.lastName != null && driver.lastName!.isNotEmpty) {
      res += driver.lastName![0].toUpperCase();
    }
    if (res.isEmpty) return "?";
    return res;
  }

  @override
  Widget build(BuildContext context) {
    // Поддерживаем провайдеры кэшированными (живыми), пока открыт этот экран.
    // При выходе с экрана они автоматически очистятся из-за .autoDispose
    ref.watch(carCategoriesProvider);
    final statusesAsync = ref.watch(carStatusesProvider);
    ref.watch(regularChargeTariffsProvider);

    statusesAsync.when(
      data: (statuses) => _statusNames = { for (final s in statuses) s.id: s.name },
      error: (_, __) {},
      loading: () {},
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Календарь списаний'),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Поиск и кнопка фильтра
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Поиск',
                    height: 40.0,
                    borderRadius: 20.0,
                    onChanged: (val) {
                      _searchQuery = val.trim();
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() => _currentPage = 0);
                          _loadData();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _filter.isModified
                        ? AppTheme.buttonColor
                        : AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: SvgPicture.string(
                      '''<svg width="15" height="12" viewBox="0 0 15 12" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0.75 3H9.75M9.75 3C9.75 4.24264 10.7573 5.25 12 5.25C13.2427 5.25 14.25 4.24264 14.25 3C14.25 1.75736 13.2427 0.75 12 0.75C10.7573 0.75 9.75 1.75736 9.75 3ZM5.25 9H14.25M5.25 9C5.25 10.2427 4.24264 11.25 3 11.25C1.75736 11.25 0.75 10.2427 0.75 9C0.75 7.75732 1.75736 6.75 3 6.75C4.24264 6.75 5.25 7.75732 5.25 9Z" stroke="#21201F" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>''',
                      width: 20,
                      height: 16,
                    ),
                    onPressed: () async {
                      final result = await RentsFiltersSheet.show(
                        context: context,
                        initialFilter: _filter,
                      );
                      if (result != null) {
                        setState(() {
                          _filter = result;
                          _currentPage = 0;
                        });
                        _loadData();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Селектор даты
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.controlsColor, // Тот же цвет что и у поиска
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: _isLoading ? null : _prevDays,
                        child: const SizedBox(
                          width: 48,
                          child: Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                        ),
                      ),
                      Center(
                        child: Container(width: 1, height: 24, color: Colors.black.withOpacity(0.1)),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _formatDateRange(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(width: 1, height: 24, color: Colors.black.withOpacity(0.1)),
                      ),
                      InkWell(
                        onTap: _isLoading ? null : _nextDays,
                        child: const SizedBox(
                          width: 48,
                          child: Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Таблица
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildTable(),
          ),

          // Пагинация
          if (!_isLoading && _data != null)
            _buildPagination(),
        ],
      ),
    );
  }

  List<int?> _buildPageRange(int current, int total) {
    if (total <= 7) return List.generate(total, (i) => i);
    final Set<int> pages = {0, total - 1};
    for (int i = current - 2; i <= current + 2; i++) {
      if (i >= 0 && i < total) pages.add(i);
    }
    final sorted = pages.toList()..sort();
    final result = <int?>[];
    for (int i = 0; i < sorted.length; i++) {
      result.add(sorted[i]);
      if (i + 1 < sorted.length && sorted[i + 1] - sorted[i] > 1) {
        result.add(null);
      }
    }
    return result;
  }

  Widget _buildPagination() {
    final total = _data?.total ?? 0;
    final totalPages = (total / _filter.pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    final pageRange = _buildPageRange(_currentPage, totalPages);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          // Стрелка влево
          _PageButton(
            label: '<',
            enabled: _currentPage > 0,
            onTap: () {
              setState(() => _currentPage--);
              _loadData();
            },
          ),
          const SizedBox(width: 2),

          // Номера страниц
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: pageRange.map((page) {
                  if (page == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('...', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    );
                  }
                  final isCurrent = page == _currentPage;
                  return GestureDetector(
                    onTap: isCurrent ? null : () {
                      setState(() => _currentPage = page);
                      _loadData();
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: isCurrent
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.buttonColor, width: 2),
                            )
                          : null,
                      child: Center(
                        child: Text(
                          '${page + 1}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 2),
          // Стрелка вправо
          _PageButton(
            label: '>',
            enabled: _currentPage < totalPages - 1,
            onTap: () {
              setState(() => _currentPage++);
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (_data == null) {
      return const Center(child: Text("Нет данных"));
    }

    final filteredVehicles = _data!.vehicles;

    return Column(
      children: [
        // Заголовок таблицы
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 16),
          child: Row(
            children: [
              // Левая колонка - Автомобиль
              Container(
                width: 120,
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Автомобиль',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Дни
              Expanded(
                child: Row(
                  children: List.generate(_daysToShow, (index) {
                    final d = _currentDate.add(Duration(days: index));
                    return Expanded(
                      child: Text(
                        _formatDayHeader(d),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        
        // Линия под заголовком
        const Divider(height: 1, color: AppTheme.borderColor),

        // Тело таблицы
        Expanded(
          child: ListView.builder(
            itemCount: filteredVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = filteredVehicles[index];
              final isEven = index % 2 == 0;
              
              return Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.borderColor, width: 0.5)),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Левая колонка (не скроллится)
                      Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: const Color(0xFFF2F2F2), // Light gray bg for left col like in design
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${vehicle.brand ?? ''} ${vehicle.model ?? ''}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehicle.number ?? '',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            CustomBadge(
                              type: _getStatusBadgeType(vehicle.status),
                              text: _statusNames[vehicle.status] ?? vehicle.status ?? '—',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Данные дней (скролл внутри колонки, если дней больше, но в нашем случае 2 колонки помещаются на экран)
                      // Если нужно свайпить именно _горизонтально_ всю таблицу - тогда надо SingleChildScrollView
                      // Но так как у нас 2 дня - они спокойно влезут в Expanded
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Row(
                            children: List.generate(_daysToShow, (dayIndex) {
                              // В данных дни могут не совпадать по индексу если length < daysToShow
                              final dayData = (vehicle.dataByDay.length > dayIndex) 
                                  ? vehicle.dataByDay[dayIndex] 
                                  : VehicleRentDataDay(rents: []);
                              final currentCellDate = _currentDate.add(Duration(days: dayIndex));
                                  
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: dayData.rents.map((r) => _buildRentCell(r, currentCellDate, vehicle)).toList(),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRentCell(RentInfo rent, DateTime cellDate, VehicleWithRents vehicle) {
    final driver = _findDriver(rent.driverId);
    
    // Определяем статус списания: будущее (серые часы) или нет (черная галочка)
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final isFuture = cellDate.isAfter(todayStart);

    final String clockSvg = '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" fill-rule="evenodd" clip-rule="evenodd" d="M12 22C17.523 22 22 17.523 22 12C22 6.477 17.523 2 12 2C6.477 2 2 6.477 2 12C2 17.523 6.477 22 12 22ZM12 20C14.1217 20 16.1566 19.1571 17.6569 17.6569C19.1571 16.1566 20 14.1217 20 12C20 9.87827 19.1571 7.84344 17.6569 6.34315C16.1566 4.84285 14.1217 4 12 4C9.87827 4 7.84344 4.84285 6.34315 6.34315C4.84285 7.84344 4 9.87827 4 12C4 14.1217 4.84285 16.1566 6.34315 17.6569C7.84344 19.1571 9.87827 20 12 20ZM16.42 14.894C16.4717 14.7733 16.4991 14.6435 16.5006 14.5122C16.5022 14.3808 16.4778 14.2505 16.429 14.1285C16.3801 14.0066 16.3078 13.8955 16.216 13.8015C16.1242 13.7076 16.0148 13.6327 15.894 13.581L13 12.34V7C13 6.73478 12.8946 6.48043 12.7071 6.29289C12.5196 6.10536 12.2652 6 12 6C11.7348 6 11.4804 6.10536 11.2929 6.29289C11.1054 6.48043 11 6.73478 11 7V12.67C11 13.27 11.358 13.813 11.91 14.049L15.106 15.419C15.3497 15.5235 15.625 15.5268 15.8712 15.4284C16.1174 15.3299 16.3145 15.1377 16.419 14.894H16.42Z"></path></svg>''';
    final String checkSvg = '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill="currentColor" fill-rule="evenodd" clip-rule="evenodd" d="M12 22C17.523 22 22 17.523 22 12C22 6.477 17.523 2 12 2C6.477 2 2 6.477 2 12C2 17.523 6.477 22 12 22ZM12 20C14.1217 20 16.1566 19.1571 17.6569 17.6569C19.1571 16.1566 20 14.1217 20 12C20 9.87827 19.1571 7.84344 17.6569 6.34315C16.1566 4.84285 14.1217 4 12 4C9.87827 4 7.84344 4.84285 6.34315 6.34315C4.84285 7.84344 4 9.87827 4 12C4 14.1217 4.84285 16.1566 6.34315 17.6569C7.84344 19.1571 9.87827 20 12 20ZM16.66 8.251C16.4605 8.07668 16.1999 7.98867 15.9356 8.0063C15.6712 8.02392 15.4246 8.14574 15.25 8.345L10.733 13.8L8.737 11.325C8.5554 11.14 8.30908 11.0328 8.04997 11.026C7.79085 11.0191 7.5392 11.1131 7.34805 11.2882C7.1569 11.4632 7.0412 11.7057 7.02533 11.9644C7.00946 12.2231 7.09468 12.4779 7.263 12.675L9.636 15.5C9.90455 15.7934 10.272 16.0335 10.733 16.0335C11.2565 16.0335 11.7881 15.7493 12 15.5C12.2119 15.2507 16.754 9.662 16.754 9.662C16.9284 9.4626 17.0166 9.20212 16.9992 8.93776C16.9817 8.6734 16.8601 8.42676 16.661 8.252L16.66 8.251Z"></path></svg>''';

    return GestureDetector(
      onTap: () => ExpenseDetailBottomSheet.show(
        context: context,
        rent: rent,
        driver: driver,
        vehicle: vehicle,
        cellDate: cellDate,
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isFuture ? const Color.fromRGBO(231, 229, 225, 0.6) : const Color.fromRGBO(195, 206, 219, 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: _getDriverColor(driver?.lastName ?? ''),
                child: Text(
                  _getDriverInitials(driver),
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SvgPicture.string(
                isFuture ? clockSvg : checkSvg,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rent.isDayOff ? 'Выходной' : '${rent.dailyPrice} ₽',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 13,
              color: rent.isDayOff ? Colors.grey.shade600 : null,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.controlsColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
