import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/expense.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/add_expense_sheet.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/expense_details_sheet.dart';
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

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  bool _isLoading = false;
  String? _error;
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

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
      final dateFrom = DateTime(2024, 11, 1);
      final dateTo = DateTime(2026, 6, 30);

      final data = await repository.getCostsList(
        parkId: parkId,
        dateFrom: dateFrom,
        dateTo: dateTo,
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

      ref
          .read(loggerProvider)
          .i('✅ Loaded ${expenses.length} expenses from Yandex Fleet API');
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
                    onChanged: (value) {
                      // TODO: Implement search functionality
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: AnimatedIconButton(
                    onTap: () => showAddExpenseSheet(context),
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
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.download_rounded, size: 20),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.controlsColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.tune_rounded, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16),
                        Text(
                          '27 дек. 2025 г. – 27 янв. 2026 г.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                      ],
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
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Загрузка расходов из Yandex Fleet API...'),
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
                        onTap: () => showExpenseDetailsSheet(context, expense),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        children: [
                                          TextSpan(
                                            text: '${expense.car.number} ',
                                          ),
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.outline,
                                                  ),
                                            ),
                                            Positioned.fill(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: 1.5,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          '${expense.amount} ₽',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_gas_station,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      expense.createdByUserName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
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
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                  ),
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
                            'Расходы за период с 01.11.2025 по 30.06.2026 не найдены',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
