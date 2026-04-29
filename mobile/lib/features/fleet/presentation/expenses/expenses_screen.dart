import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/expense.dart';
import 'package:mobile/features/fleet/domain/report_download.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/add_expense_sheet.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/expense_details_sheet.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/expenses_filter_bottom_sheet.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/report_downloads_sheet.dart';
import 'package:mobile/features/fleet/providers/expenses_suggestions_provider.dart';
import 'package:mobile/features/fleet/providers/report_downloads_provider.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/animated_icon_button.dart';
import 'package:mobile/shared/widgets/search_field.dart';
import 'package:mobile/features/fleet/data/expenses_repository.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/providers/logger_provider.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

const expenseTypeIcons = <String, String>{
  'loan': '<svg width="24" height="24" viewBox="0 0 24 24"><path d="M16 15.5c0-.512-.045-1.014-.132-1.502 1.761-.021 3.403-.194 4.678-.488A8.836 8.836 0 0 0 22 13.055V15.5c0 .8-2.713 1.454-6.132 1.498.087-.486.132-.987.132-1.498ZM22 10.5V8.055a8.83 8.83 0 0 1-1.454.455C19.183 8.824 17.4 9 15.5 9c-.93 0-1.832-.042-2.67-.122a8.53 8.53 0 0 1 2.418 3.121L15.5 12c3.59 0 6.5-.671 6.5-1.5ZM9 5.5C9 6.33 11.91 7 15.5 7S22 6.33 22 5.5v-1c0-.828-2.91-1.5-6.5-1.5S9 3.672 9 4.5v1ZM7.5 22a6.5 6.5 0 1 0 0-13 6.5 6.5 0 0 0 0 13Z" fill="currentColor"/></svg>',
  'petrol': '<svg width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" fill-rule="evenodd" d="M20 6a3 3 0 0 0-3-3h-4.9a3 3 0 0 0-1.94.72L5.05 8.1A3 3 0 0 0 4 10.38V19a3 3 0 0 0 3 3h10a3 3 0 0 0 3-3V6Zm-8 10c-1.5 0-2.5-.94-2.5-2.35 0-.68.28-1.38.5-1.86.33-.7.84-1.45 1.33-2.16l.26-.38c.1-.17.26-.25.41-.25.15 0 .3.08.41.25l.24.34c.49.72 1.01 1.49 1.34 2.2.23.47.51 1.17.51 1.86 0 1.4-1 2.35-2.5 2.35Z" clip-rule="evenodd"/></svg>',
  'service': '<svg width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" fill-rule="evenodd" d="m16.73 17.76-1.47 1.74c-.37.45-.6.72-.72.82l-.09.07c-.22.19-.34.28-.47.34-.12.07-.27.1-.56.17l-.1.02c-.34.08-.84.08-1.85.08H7.5c-1.4 0-2.1 0-2.65-.23a3 3 0 0 1-1.62-1.62C3 18.6 3 17.9 3 16.5V6a3 3 0 0 1 3-3h8a7 7 0 0 1 7 7v1.2c0 .95 0 1.43-.07 1.75a2.1 2.1 0 0 1-.55 1.18c-.1.11-.28.29-.57.55-1.1.96-2.15 1.97-3.08 3.08ZM6 5a1 1 0 0 0-1 1v4h14a5 5 0 0 0-5-5H6Z" clip-rule="evenodd"/></svg>',
  'subrent': '<svg width="24" height="24" viewBox="0 0 24 24"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10ZM9.75 11.25a2.25 2.25 0 1 0 0-4.5 2.25 2.25 0 0 0 0 4.5Zm0-1.5a.75.75 0 1 0 0-1.5.75.75 0 0 0 0 1.5Zm4.5-2.25h1.688l-6.188 9H8.062l6.188-9Zm0 9.75a2.25 2.25 0 1 0 0-4.5 2.25 2.25 0 0 0 0 4.5Zm0-1.5a.75.75 0 1 0 0-1.5.75.75 0 0 0 0 1.5Z" fill="currentColor"/></svg>',
  'maintenance': '<svg width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" d="M3.06 21.39c-1.44-1.44-1.45-3.5.2-4.96 1.74-1.57 5-3.27 7.35-5.63 1.85-1.85-.31-4.72 2.56-7.45a5.22 5.22 0 0 1 7.26.2c.36.38.65.8.76 1.13l-3.23.86c-.75.21-1.02.75-.84 1.4l1.45 5.32c-1.67.68-2.8-.1-4.26 1.36-2.22 2.22-5.23 6.32-6.29 7.58-1.4 1.68-3.52 1.62-4.96.19Zm16.49-9.57-.98-3.57c.26.05.5.03.78-.05l2.6-.72c.23 1.09-.32 2.57-1.4 3.56-.34.33-.68.6-1 .78Z"/></svg>',
};

const svgOther = '<svg width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" fill-rule="evenodd" d="M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0ZM9 12a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Zm4.5 0a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Zm3 1.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Z" clip-rule="evenodd"/></svg>';

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  bool _isLoading = false;
  String? _error;
  List<Expense> _expenses = [];
  ExpensesFilter _filter = ExpensesFilter.defaultFilter;
  String _searchText = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _searchText = value);
      _loadExpenses();
    });
  }

  bool get _filterIsModified {
    final def = ExpensesFilter.defaultFilter;
    return _filter.dateFrom != def.dateFrom || _filter.dateTo != def.dateTo;
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _formatDateRange() => '${_fmt(_filter.dateFrom)} – ${_fmt(_filter.dateTo)}';

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final secureStorage = ref.read(secureStorageServiceProvider);
      final parkId = await secureStorage.getParkId();

      if (parkId == null || parkId.isEmpty) {
        setState(() {
          _error = 'Park ID не найден. Пожалуйста, авторизуйтесь заново.';
          _isLoading = false;
        });
        return;
      }

      final repository = ref.read(expensesRepositoryProvider);
      
      // Используем указанные даты: 2025-11-01 до 2026-06-30
      final data = await repository.getCostsList(
        parkId: parkId,
        dateFrom: _filter.dateFrom,
        dateTo: _filter.dateTo,
        nameSearchText: _searchText.isNotEmpty ? _searchText : null,
      );

      // Парсим ответ в список Expense объектов
      final List<Expense> expenses = [];
      if (data['costs'] != null && data['costs'] is List) {
        for (final costJson in data['costs']) {
          try {
            ref.read(loggerProvider).d('📦 Parsing cost JSON: $costJson');
            expenses.add(Expense.fromYandexApi(costJson));
          } catch (e, stackTrace) {
            ref.read(loggerProvider).w('⚠️ Failed to parse expense: $e');
            ref.read(loggerProvider).w('Stack trace: $stackTrace');
            ref.read(loggerProvider).w('JSON data: $costJson');
          }
        }
      }

      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });

      ref.read(loggerProvider).i('✅ Loaded ${expenses.length} expenses from Yandex Fleet API');
    } catch (e) {
      ref.read(loggerProvider).e('❌ Failed to load expenses: $e');
      setState(() {
        _error = 'Не удалось загрузить расходы: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Поддерживаем провайдеры кэшированными (живыми), пока открыт этот экран.
    // При выходе с экрана (pop) они автоматически очистятся из-за .autoDispose
    ref.watch(costTypesProvider);
    ref.watch(suggestCarsProvider);

    final downloads = ref.watch(reportDownloadsProvider);
    final activeCount = downloads.where((d) => d.isActive || d.canDownload).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Расходы по автомобилям'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.download_rounded),
                onPressed: () {
                  ReportDownloadsSheet.show(context);
                },
              ),
              if (activeCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.buttonColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    hint: 'Поиск по расходам',
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: AnimatedIconButton(
                    onTap: () async {
                      final result = await showAddExpenseSheet(
                        context,
                      );
                      if (result == true && mounted) {
                        _loadExpenses();
                      }
                    },
                    icon: const Icon(Icons.add, size: 28, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    // Start report download
                    await ref.read(reportDownloadsProvider.notifier).startReportDownload(
                      reportType: 'costs',
                      filters: {},
                      dateFrom: _filter.dateFrom,
                      dateTo: _filter.dateTo,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Создание отчета начато'),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.download_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await ExpensesFilterBottomSheet.show(
                      context: context,
                      initialFilter: _filter,
                    );
                    if (result != null) {
                      setState(() => _filter = result);
                      _loadExpenses();
                    }
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: _filterIsModified
                          ? AppTheme.buttonColor
                          : AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final range = await CustomDateRangePickerBottomSheet.show(
                        context: context,
                        title: 'Выберите период',
                        startDate: _filter.dateFrom,
                        endDate: _filter.dateTo,
                      );
                      if (range != null) {
                        setState(() => _filter = ExpensesFilter(
                          dateFrom: range.start,
                          dateTo: range.end,
                        ));
                        _loadExpenses();
                      }
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _filterIsModified
                            ? AppTheme.buttonColor.withOpacity(0.15)
                            : AppTheme.controlsColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16),
                          Text(
                            _formatDateRange(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Сбросить все фильтры',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator()
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadExpenses,
                                child: const Text('Повторить'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _expenses.isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _expenses.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final expense = _expenses[index];
                              return GestureDetector(
                                onTap: () async {
                                  final result = await showExpenseDetailsSheet(
                                    context, 
                                    expense,
                                  );
                                  if (result == true && mounted) {
                                    _loadExpenses();
                                  }
                                },
                                child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  children: [
                                    TextSpan(text: '${expense.car.number} '),
                                    TextSpan(
                                      text: expense.car.details,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            expense.isDeleted
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        '${expense.amount} ₽',
                                        style: Theme.of(context).textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.outline,
                                            ),
                                      ),
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 1.5,
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    '${expense.amount} ₽',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            SvgPicture.string(
                              expenseTypeIcons[expense.type.id] ?? svgOther,
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppTheme.textPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.controlsColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                expense.type.name,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                expense.createdByUserName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              expense.formattedDate,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Нет расходов за выбранный период',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Расходы за период с ${_fmt(_filter.dateFrom)} по ${_fmt(_filter.dateTo)} не найдены',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
