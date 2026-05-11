import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/features/staff/widgets/status_badge.dart';
import 'package:mobile/features/staff/widgets/transaction_bottom_sheet.dart';
import 'package:mobile/features/staff/widgets/vehicle_selector_bottom_sheet.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/shared/widgets/pulse_box.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/shared/widgets/badge.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';

class StaffDetailsScreen extends ConsumerStatefulWidget {
  final Staff staff;

  const StaffDetailsScreen({super.key, required this.staff});

  @override
  ConsumerState<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends ConsumerState<StaffDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriodDays = 30;

  DateTime _historyDateFrom = DateTime.now()
      .subtract(const Duration(days: 6))
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  DateTime _historyDateTo = DateTime.now().copyWith(
    hour: 23,
    minute: 59,
    second: 59,
    millisecond: 0,
    microsecond: 0,
  );
  int _historyPage = 1;

  DateTime _gpsDateFrom = DateTime.now()
      .subtract(const Duration(days: 1))
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  DateTime _gpsDateTo = DateTime.now().copyWith(
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(staffProfileProvider(widget.staff.id));

    // Пока данные загружаются, используем базовые данные из списка (staff).
    // Если данные загрузились, объединяем их, сохраняя баланс и аватар из списка
    final displayStaff =
        profileAsync.value?.copyWith(
          balance: widget.staff.balance,
          avatarUrl: widget.staff.avatarUrl,
          timeOnShift: widget.staff.timeOnShift,
          status: widget.staff.status != StaffStatus.offline
              ? widget.staff.status
              : profileAsync.value?.status,
        ) ??
        widget.staff;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(displayStaff.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          tabs: const [
            Tab(text: 'Главное'),
            Tab(text: 'Детали'),
            Tab(text: 'Автомобиль'),
            Tab(text: 'Ведомость'),
            Tab(text: 'История баланса'),
            Tab(text: 'GPS'),
          ],
        ),
      ),
      body: profileAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMainTab(displayStaff),
                _buildDetailsTab(displayStaff),
                _buildCarTab(displayStaff),
                _buildLedgerTab(displayStaff),
                _buildBalanceHistoryTab(displayStaff),
                _buildGpsTab(displayStaff),
              ],
            ),
    );
  }

  Widget _buildMainTab(Staff displayStaff) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, displayStaff),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildDetailsGrid(context, displayStaff),
          const SizedBox(height: 24),
          _buildIndicatorsSection(displayStaff),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Staff displayStaff) {
    final detailsAsync = ref.watch(driverDetailsProvider(displayStaff.id));

    return detailsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Ошибка загрузки деталей: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (details) {
        // Extract data from API response - data is inside "driver" object
        final driver = details['driver'] as Map<String, dynamic>?;
        final driverProfile =
            driver?['driver_profile'] as Map<String, dynamic>?;
        final accounts = driver?['accounts'] as List<dynamic>?;
        final car = driver?['car'] as Map<String, dynamic>?;
        final currentStatus =
            driver?['current_status'] as Map<String, dynamic>?;

        // Parse name from driver_profile
        final firstName = driverProfile?['first_name'] as String? ?? '—';
        final lastName = driverProfile?['last_name'] as String? ?? '—';
        final middleName = driverProfile?['middle_name'] as String? ?? '—';

        // Driver license info
        final licenseInfo = driverProfile?['license'] as Map<String, dynamic>?;
        final licenseNumber = licenseInfo?['number'] as String? ?? '—';
        final licenseCountry = licenseInfo?['country'] as String? ?? '—';
        final licenseIssueDate = licenseInfo?['issue_date'] as String? ?? '—';
        final licenseExpiryDate =
            licenseInfo?['expiration_date'] as String? ?? '—';

        // Work conditions
        final workRule = driverProfile?['work_rule_id'] as String? ?? '—';
        final balanceLimit = accounts?.isNotEmpty == true
            ? (accounts!.first as Map<String, dynamic>)['balance_limit']
                      ?.toString() ??
                  '—'
            : '—';
        final hireDate = driverProfile?['hire_date'] as String? ?? '—';
        final carId = car?['id'] as String? ?? '—';
        final employmentType =
            driverProfile?['employment_type'] as String? ?? '—';
        final providers = driverProfile?['providers'] as List<dynamic>?;
        final providersStr = providers?.join(', ') ?? 'Да';
        final balanceDenyOnlycard =
            driverProfile?['balance_deny_onlycard'] as bool? ?? false;

        // Personal data
        final phones = driverProfile?['phones'] as List<dynamic>?;
        final phone = phones?.isNotEmpty == true
            ? phones!.first as String? ?? '—'
            : '—';
        final email = driverProfile?['email'] as String? ?? '—';
        final address = driverProfile?['address'] as String? ?? '—';
        final deaf = driverProfile?['deaf'] as bool? ?? false;
        final comment = driverProfile?['comment'] as String? ?? '';
        final taxNumber =
            driverProfile?['tax_identification_number'] as String? ?? '—';
        final paymentServiceId =
            driverProfile?['payment_service_id'] as String? ?? '—';

        // Work status
        final workStatus =
            driverProfile?['work_status'] as String? ?? 'working';
        final statusText = workStatus == 'fired' ? 'Уволен' : 'Работает';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDetailSection(
              'Детали',
              'Некоторые поля недоступны для редактирования, для внесения изменений обратитесь в поддержку',
              _buildDetailGrid([
                {'Фамилия': lastName},
                {'Водительский стаж с': '— (MOCK)'},
                {'Имя': firstName},
                {'Серия и номер ВУ': licenseNumber},
                {'Отчество': middleName},
                {'Страна выдачи ВУ': licenseCountry.toUpperCase()},
                {'Телефон': phone},
                {'Дата выдачи ВУ': licenseIssueDate},
                {'Адрес': address},
                {'Действует до': licenseExpiryDate},
                {'Статус': statusText},
                {'Слабослышащий водитель': deaf ? 'Да' : 'Нет'},
              ]),
              onEdit: () {},
            ),
            _buildDetailSection(
              'Комментарий',
              '',
              Text(
                comment.isNotEmpty ? comment : 'Нет комментария',
                style: const TextStyle(fontSize: 15),
              ),
              onEdit: () {},
            ),
            _buildDetailSection(
              'Условия работы',
              '',
              _buildDetailGrid([
                {'Условия работы': employmentType},
                {'Заказы от платформы': providersStr},
                {'Лимит по счету': balanceLimit},
                {
                  'Запрещать принимать безналичные заказы': balanceDenyOnlycard
                      ? 'Да'
                      : 'Нет',
                },
                {'Дата принятия': hireDate},
                {'Автомобиль ID': carId},
              ]),
            ),
            _buildDetailSection(
              'Личные данные',
              '',
              _buildDetailGrid([
                {'Доверенный контакт': '— (MOCK)'},
                {'Дата рождения': '— (MOCK)'},
                {'Email': email},
                {'ID для платежа': paymentServiceId},
                {'Отзыв о водителе': '— (MOCK)'},
              ]),
            ),
            _buildDetailSection(
              'Паспортные данные',
              '',
              _buildDetailGrid([
                {'Статус проверки паспорта': '— (MOCK)'},
                {'Номер и серия': '— (MOCK)'},
                {'Вид паспорта': '— (MOCK)'},
                {'Почтовый индекс': '— (MOCK)'},
                {'Страна': '— (MOCK)'},
                {'Дата выдачи': '— (MOCK)'},
                {'Кем выдан': '— (MOCK)'},
                {'Действует до': '— (MOCK)'},
                {'Адрес регистрации': '— (MOCK)'},
                {'ОГРН': '— (MOCK)'},
                {'ИНН': taxNumber},
              ]),
            ),
            _buildDetailSection(
              'Банковские реквизиты',
              '',
              _buildDetailGrid([
                {'БИК': '— (MOCK)'},
                {'Корреспондентский счет': '— (MOCK)'},
                {'Расчетный счет': '— (MOCK)'},
              ]),
              showDivider: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarTab(Staff displayStaff) {
    if (displayStaff.carId.isEmpty) {
      return const Center(child: Text('Автомобиль не привязан'));
    }

    final carAsync = ref.watch(carInfoProvider(displayStaff.carId));

    return carAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Ошибка загрузки данных автомобиля: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (data) {
        if (data == null) {
          return const Center(child: Text('Данные автомобиля не найдены'));
        }

        final car = data['car'] as Map<String, dynamic>?;
        if (car == null)
          return const Center(child: Text('Нет информации об автомобиле'));

        final brand = car['brand'] as String? ?? '';
        final model = car['model'] as String? ?? '';
        final number = car['number'] as String? ?? '';
        final year = car['year']?.toString() ?? '—';
        final transmission = car['transmission'] == 'mechanical'
            ? 'Механика'
            : (car['transmission'] == 'auto' ? 'Автомат' : '—');
        final isParkVehicle = car['vehicle_owner_type'] == 'park';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Переключатель Парковый / Частный
            Container(
              decoration: BoxDecoration(
                color: AppTheme.controlsColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isParkVehicle
                            ? AppTheme.cardColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isParkVehicle
                            ? Border.all(color: AppTheme.borderColor)
                            : null,
                        boxShadow: isParkVehicle
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Парковый',
                        style: TextStyle(
                          color: isParkVehicle
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontWeight: isParkVehicle
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !isParkVehicle
                            ? AppTheme.cardColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: !isParkVehicle
                            ? Border.all(color: AppTheme.borderColor)
                            : null,
                        boxShadow: !isParkVehicle
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Частный',
                        style: TextStyle(
                          color: !isParkVehicle
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontWeight: !isParkVehicle
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Основная карточка авто
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    AppTheme.controlsColor, // Цвет карточки авто из скриншота
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$number $brand ${model}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(year, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.settings,
                        size: 16,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(transmission, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Списания
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Периодические списания',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Списание за аренду',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Списание за депозит',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ограничить поездки без ОСАГО
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.controlsColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ограничить поездки без ОСАГО',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Доступно после подтверждения\nправа использования в карточке\nавтомобиля',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ограничить поездки в других парках
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.controlsColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ограничить поездки в других\nпарках',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Доступно после подтверждения\nправа использования в карточке\nавтомобиля',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLedgerTab(Staff displayStaff) {
    final params = DriverTransactionsParams(
      displayStaff.id,
      _selectedPeriodDays,
    );
    final transactionsAsync = ref.watch(driverTransactionsProvider(params));
    final balancesAsync = ref.watch(driverBalancesProvider(params));

    return transactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Ошибка: $e')),
      data: (transactionsData) {
        final transactions =
            transactionsData['transactions'] as List<dynamic>? ?? [];

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: AppTheme.borderColor),
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  final date = DateTime.tryParse(
                    t['event_at'] ?? '',
                  )?.toLocal();
                  String dateStr = '';
                  if (date != null) {
                    final months = [
                      'янв.',
                      'фев.',
                      'мар.',
                      'апр.',
                      'мая',
                      'июн.',
                      'июл.',
                      'авг.',
                      'сен.',
                      'окт.',
                      'ноя.',
                      'дек.',
                    ];
                    dateStr =
                        '${date.day} ${months[date.month - 1]} ${date.year} г., ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                  }

                  final amount =
                      double.tryParse(t['amount']?.toString() ?? '0') ?? 0;
                  final amountColor = amount > 0
                      ? const Color(0xFF34C759)
                      : const Color(0xFFFF3B30);
                  final amountStr = amount > 0
                      ? '+${amount.toStringAsFixed(2)}'
                      : amount.toStringAsFixed(2);

                  final balance =
                      double.tryParse(t['balance']?.toString() ?? '0') ?? 0;

                  return InkWell(
                    onTap: () => _showTransactionDetails(
                      context,
                      t,
                      dateStr,
                      amountStr,
                      amountColor,
                      balance,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['event_title']?.toString().isNotEmpty ==
                                          true
                                      ? t['event_title']
                                      : (t['category_name'] ??
                                            'Неизвестное событие'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                amountStr,
                                style: TextStyle(
                                  color: amountColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Баланс: ${balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            balancesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
              error: (e, st) => const SizedBox(),
              data: (balancesData) {
                final balances =
                    balancesData['driver_balances'] as List<dynamic>? ?? [];
                double driverBefore = 0;
                double driverAfter = 0;
                for (var b in balances) {
                  if (b['key'] == 'driver_before') {
                    driverBefore =
                        double.tryParse(b['value']?.toString() ?? '0') ?? 0;
                  }
                  if (b['key'] == 'driver_after') {
                    driverAfter =
                        double.tryParse(b['value']?.toString() ?? '0') ?? 0;
                  }
                }
                final diff = driverAfter - driverBefore;
                final diffStr = diff >= 0
                    ? '+${diff.toStringAsFixed(2)}'
                    : diff.toStringAsFixed(2);
                final diffColor = diff >= 0
                    ? const Color(0xFF34C759)
                    : const Color(0xFFFF3B30);

                double totalSum = transactions.fold(
                  0.0,
                  (sum, t) =>
                      sum +
                      (double.tryParse(t['amount']?.toString() ?? '0') ?? 0),
                );

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Количество: ${transactions.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${totalSum > 0 ? '+' : ''}${totalSum.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF34C759),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Text(
                        'Итоги 0,00',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Баланс исполнителя на начальную дату ${driverBefore.toStringAsFixed(2)}',
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Баланс исполнителя на конечную дату ${driverAfter.toStringAsFixed(2)} ',
                          ),
                          Text(
                            '($diffStr)',
                            style: TextStyle(color: diffColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection(
    String title,
    String subtitle,
    Widget content, {
    bool showDivider = true,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          content,
          if (showDivider) ...[
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailGrid(List<Map<String, String>> items) {
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailItem(
                items[i].keys.first,
                items[i].values.first,
              ),
            ),
            const SizedBox(width: 16),
            if (i + 1 < items.length)
              Expanded(
                child: _buildDetailItem(
                  items[i + 1].keys.first,
                  items[i + 1].values.first,
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < items.length) {
        rows.add(const SizedBox(height: 16));
      }
    }
    return Column(children: rows);
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, color: valueColor)),
      ],
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    dynamic t,
    String dateStr,
    String amountStr,
    Color amountColor,
    double balance,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['event_title']?.toString().isNotEmpty == true
                      ? t['event_title']
                      : (t['category_name'] ?? 'Детали события'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailItem('Дата', dateStr),
                const SizedBox(height: 16),
                _buildDetailItem('Категория', t['category_name'] ?? ''),
                const SizedBox(height: 16),
                _buildDetailItem('Сумма', amountStr, valueColor: amountColor),
                const SizedBox(height: 16),
                _buildDetailItem('Баланс', balance.toStringAsFixed(2)),
                const SizedBox(height: 16),
                if ((t['description'] ?? '').toString().isNotEmpty) ...[
                  _buildDetailItem('Комментарий', t['description']),
                  const SizedBox(height: 16),
                ],
                _buildDetailItem('Инициатор', t['created_by'] ?? ''),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD900),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Закрыть',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Staff displayStaff) {
    return InfoCard(
      title: displayStaff.name,
      subtitle: displayStaff.phoneNumber,
      icon: CircleAvatar(
        radius: 36,
        backgroundColor: AppTheme.controlsColor,
        backgroundImage: displayStaff.avatarUrl.isNotEmpty
            ? NetworkImage(displayStaff.avatarUrl)
            : null,
        child: displayStaff.avatarUrl.isEmpty
            ? Text(
                displayStaff.initials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(status: displayStaff.status),
              if (displayStaff.employmentType.isNotEmpty)
                CustomBadge(
                  type: BadgeType.working,
                  text: displayStaff.employmentType,
                ),
              if (displayStaff.vehicleType.isNotEmpty)
                CustomBadge(
                  type: BadgeType.preparation,
                  text: 'Парковый автомобиль',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildContactRow(
                  icon: Icons.phone_outlined,
                  label: 'Телефон',
                  value: displayStaff.phoneNumber,
                ),
                const Divider(height: 1, indent: 44),
                _buildContactRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: displayStaff.email.isNotEmpty
                      ? displayStaff.email
                      : 'Не указан',
                ),
                const Divider(height: 1, indent: 44),
                _buildContactRow(
                  icon: Icons.badge_outlined,
                  label: 'ID',
                  value: displayStaff.id,
                ),
                const Divider(height: 1, indent: 44),
                _buildContactRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'ИНН',
                  value: displayStaff.taxNumber.isNotEmpty
                      ? displayStaff.taxNumber
                      : 'Не указан',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Yandex Sans Text',
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Yandex Sans Text',
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Написать',
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.work_outline,
            label: 'Сменить тип занятости',
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _ActionButton(
            icon: Icons.history,
            label: 'История изменений',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, Staff displayStaff) {
    final carAsync = ref.watch(carInfoProvider(displayStaff.carId));
    final carData = carAsync.value?['car'] as Map<String, dynamic>?;
    final carTitle = carData != null
        ? '${carData['brand']} ${carData['model']}'
        : (displayStaff.vehicleType.isNotEmpty
              ? displayStaff.vehicleType
              : 'Парковый автомобиль');
    final carValue = carData != null
        ? '${carData['callsign']}\nГод: ${carData['year']}'
        : 'Ограничить поездки без ОСАГО\nОграничить поездки в других парках';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Баланс',
                value: displayStaff.balance,
                showBalanceActions: true,
                onAddTap: () {
                  TransactionBottomSheet.show(
                    context: context,
                    staff: displayStaff,
                  );
                },
                onRemoveTap: () {
                  TransactionBottomSheet.show(
                    context: context,
                    staff: displayStaff,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Бонусы',
                value: 'Нет активных бонусов',
                valueFontSize: 15,
                valueFontWeight: FontWeight.w400,
                valueColor: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatCard(
                title: 'Комментарий',
                value: displayStaff.comment.isNotEmpty
                    ? displayStaff.comment
                    : 'Нет комментария',
                subtitle: 'Заметка об исполнителе',
                isEditable: false,
                valueFontSize: 14,
                valueFontWeight: FontWeight.w400,
                valueColor: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: carAsync.isLoading ? 'Загрузка...' : carTitle,
                value: carAsync.isLoading ? '' : carValue,
                subtitle: 'Детали авто',
                isEditable: true,
                onEditTap: () {
                  print('🚗 Edit button tapped for vehicle card');
                  VehicleSelectorBottomSheet.show(
                    context: context,
                    onVehicleSelected: (vehicle) {
                      // TODO: Implement vehicle assignment API call
                      print('Selected vehicle: ${vehicle['id']}');
                      // Refresh the car info after selection
                      ref.invalidate(carInfoProvider(displayStaff.carId));
                    },
                  );
                },
                valueFontSize: 13,
                valueFontWeight: FontWeight.w400,
                valueColor: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicatorsSection(Staff displayStaff) {
    final ordersAsync = ref.watch(
      driverOrdersProvider(
        DriverOrdersParams(displayStaff.id, _selectedPeriodDays),
      ),
    );

    double totalIncome = 0;
    int totalOrders = 0;
    int cancelledOrders = 0;
    double workTimeSeconds = 0;

    ordersAsync.whenData((data) {
      totalOrders = (data['orders_count'] as num?)?.toInt() ?? 0;
      cancelledOrders = (data['cancelled_orders_count'] as num?)?.toInt() ?? 0;
      totalIncome = (data['income'] as num?)?.toDouble() ?? 0.0;
      workTimeSeconds = (data['work_time_seconds'] as num?)?.toDouble() ?? 0.0;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Показатели',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Yandex Sans Text',
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _showPeriodSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(_getPeriodLabel(), style: AppTheme.captionSecondary),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _IndicatorCard(
                    title: 'Доход в Про',
                    value: '${totalIncome.toInt()} ₽',
                    isLoading: ordersAsync.isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _IndicatorCard(
                    title: 'Заказы',
                    value: '$totalOrders',
                    isLoading: ordersAsync.isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _IndicatorCard(
                    title: 'Отмененные',
                    value: '$cancelledOrders',
                    isLoading: ordersAsync.isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _IndicatorCard(
                    title: 'Время на линии',
                    value:
                        '${(workTimeSeconds / 3600).floor()} ч ${((workTimeSeconds % 3600) / 60).floor()} мин',
                    isLoading: ordersAsync.isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriodDays) {
      case 7:
        return 'За 7 дней';
      case 14:
        return 'За 14 дней';
      case 30:
        return 'За 30 дней';
      case 90:
        return 'За 90 дней';
      default:
        return 'За $_selectedPeriodDays дней';
    }
  }

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Выберите период',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Yandex Sans Text',
              ),
            ),
            const SizedBox(height: 16),
            _buildPeriodOption(7, 'За 7 дней'),
            _buildPeriodOption(14, 'За 14 дней'),
            _buildPeriodOption(30, 'За 30 дней'),
            _buildPeriodOption(90, 'За 90 дней'),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodOption(int days, String label) {
    final isSelected = _selectedPeriodDays == days;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriodDays = days;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardColor : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFF34C759), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceHistoryTab(Staff displayStaff) {
    final params = DriverBalancesHistoryParams(
      displayStaff.id,
      _historyDateFrom,
      _historyDateTo,
      _historyPage,
    );
    final historyAsync = ref.watch(driverBalancesHistoryProvider(params));

    final fromDateStr =
        '${_historyDateFrom.day} ${_getMonthStr(_historyDateFrom.month)}';
    final toDateStr =
        '${_historyDateTo.day} ${_getMonthStr(_historyDateTo.month)}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  icon: Icons.calendar_today,
                  label: '$fromDateStr – $toDateStr',
                  onTap: () async {
                    final range = await CustomDateRangePickerBottomSheet.show(
                      context: context,
                      title: 'Выберите период',
                      startDate: _historyDateFrom,
                      endDate: _historyDateTo,
                    );

                    if (range != null) {
                      setState(() {
                        _historyDateFrom = range.start.copyWith(
                          hour: _historyDateFrom.hour,
                          minute: _historyDateFrom.minute,
                        );
                        _historyDateTo = range.end.copyWith(
                          hour: _historyDateTo.hour,
                          minute: _historyDateTo.minute,
                        );
                        _historyPage = 1;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  icon: Icons.access_time,
                  label:
                      'Время начала: ${_historyDateFrom.hour.toString().padLeft(2, '0')}:${_historyDateFrom.minute.toString().padLeft(2, '0')}',
                  onTap: () => _showTimePickerFor(true),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  icon: Icons.access_time,
                  label:
                      'Время окончания: ${_historyDateTo.hour.toString().padLeft(2, '0')}:${_historyDateTo.minute.toString().padLeft(2, '0')}',
                  onTap: () => _showTimePickerFor(false),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Дата',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Баланс',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Изменение',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Ошибка: $e')),
            data: (data) {
              final balances = data['balances'] as List<dynamic>? ?? [];
              final total = data['total'] as int? ?? 0;
              final pageSize = data['page_size'] as int? ?? 25;
              final totalPages = (total / pageSize).ceil();

              if (balances.isEmpty) {
                return const Center(child: Text('Нет данных за этот период'));
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: balances.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final b = balances[index];
                        final date = DateTime.tryParse(
                          b['date'] ?? '',
                        )?.toLocal();
                        String dateStr = '';
                        if (date != null) {
                          dateStr =
                              '${date.day} ${_getMonthStr(date.month)} ${date.year} г., ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                        }

                        final balance =
                            double.tryParse(b['balance']?.toString() ?? '0') ??
                            0;
                        final diff =
                            double.tryParse(b['diff']?.toString() ?? '0') ?? 0;

                        final diffStr = diff > 0
                            ? '+${diff.toStringAsFixed(2)}'
                            : diff.toStringAsFixed(2);
                        final diffColor = diff > 0
                            ? const Color(0xFF34C759)
                            : (diff < 0
                                  ? const Color(0xFFFF3B30)
                                  : Colors.grey);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  dateStr,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  balance.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF34C759),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  diffStr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: diffColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (totalPages > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _historyPage > 1
                                ? () => setState(() => _historyPage--)
                                : null,
                          ),
                          Text(
                            'Стр. $_historyPage из $totalPages',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _historyPage < totalPages
                                ? () => setState(() => _historyPage++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMonthStr(int month) {
    const months = [
      'янв.',
      'фев.',
      'мар.',
      'апр.',
      'мая',
      'июн.',
      'июл.',
      'авг.',
      'сен.',
      'окт.',
      'ноя.',
      'дек.',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePickerFor(bool isStart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> times = [];
        for (int h = 0; h < 24; h++) {
          for (int m = 0; m < 60; m += 15) {
            if (!isStart && h == 23 && m == 45) {
              times.add('23:45');
              times.add('23:59'); // Always offer 23:59 for end time
              break;
            }
            times.add(
              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
            );
          }
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isStart ? 'Время начала' : 'Время окончания',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    final timeParts = times[index].split(':');
                    final h = int.parse(timeParts[0]);
                    final m = int.parse(timeParts[1]);
                    return ListTile(
                      title: Text(times[index], textAlign: TextAlign.center),
                      onTap: () {
                        setState(() {
                          if (isStart) {
                            _historyDateFrom = _historyDateFrom.copyWith(
                              hour: h,
                              minute: m,
                            );
                          } else {
                            _historyDateTo = _historyDateTo.copyWith(
                              hour: h,
                              minute: m,
                              second: m == 59 ? 59 : 0,
                            );
                          }
                          _historyPage = 1;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showGpsDateRangePicker() async {
    final range = await CustomDateRangePickerBottomSheet.show(
      context: context,
      title: 'Выберите период',
      startDate: _gpsDateFrom,
      endDate: _gpsDateTo,
    );
    if (range != null) {
      setState(() {
        _gpsDateFrom = range.start.copyWith(hour: 0, minute: 0);
        _gpsDateTo = range.end.copyWith(hour: 0, minute: 0);
      });
    }
  }

  Widget _buildGpsDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Icon(Icons.calendar_today_outlined, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsDistanceCard({
    required String title,
    required String value,
    bool isPrimary = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFFFFD900) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsTab(Staff displayStaff) {
    final params = DriverGpsParams(displayStaff.id, _gpsDateFrom, _gpsDateTo);
    final gpsAsync = ref.watch(driverGpsProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildGpsDateSelector(
                label: 'Начало периода',
                date: _gpsDateFrom,
                onTap: _showGpsDateRangePicker,
              ),
              const SizedBox(height: 12),
              _buildGpsDateSelector(
                label: 'Конец периода',
                date: _gpsDateTo,
                onTap: _showGpsDateRangePicker,
              ),
            ],
          ),
        ),
        Expanded(
          child: gpsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Ошибка: $e')),
            data: (data) {
              final summary =
                  data['summary_distance'] as Map<String, dynamic>? ?? {};
              final common = (summary['common'] as num?)?.toDouble() ?? 0;
              final inOrder = (summary['in_order'] as num?)?.toDouble() ?? 0;
              final free = (summary['free'] as num?)?.toDouble() ?? 0;
              final offline = (summary['offline'] as num?)?.toDouble() ?? 0;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildGpsDistanceCard(
                          title: 'Общий пробег',
                          value: '${common.toInt()} км',
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGpsDistanceCard(
                          title: 'Полезный пробег',
                          value: '${inOrder.toInt()} км',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGpsDistanceCard(
                          title: 'Холостой пробег',
                          value: '${free.toInt()} км',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGpsDistanceCard(
                          title: 'Офлайн',
                          value: '${offline.toInt()} км',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadingButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF34C759)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Yandex Sans Text',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final bool showBalanceActions;
  final VoidCallback? onAddTap;
  final VoidCallback? onRemoveTap;
  final bool isEditable;
  final VoidCallback? onEditTap;
  final double valueFontSize;
  final FontWeight valueFontWeight;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.showBalanceActions = false,
    this.onAddTap,
    this.onRemoveTap,
    this.isEditable = false,
    this.onEditTap,
    this.valueFontSize = 20,
    this.valueFontWeight = FontWeight.w600,
    this.valueColor = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Yandex Sans Text',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  if (showBalanceActions)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onRemoveTap,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.remove_circle_outline,
                              size: 22,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onAddTap,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 22,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (isEditable)
                    GestureDetector(
                      onTap: () {
                        print('📝 Edit icon tapped in _StatCard');
                        onEditTap?.call();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTheme.captionSecondary),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: valueFontWeight,
              fontFamily: 'Yandex Sans Text',
              color: valueColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isLoading;

  const _IndicatorCard({
    required this.title,
    required this.value,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Yandex Sans Text',
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 14,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          if (isLoading)
            const PulseBox(height: 22, width: 72, borderRadius: 6)
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Yandex Sans Text',
              ),
            ),
        ],
      ),
    );
  }
}
