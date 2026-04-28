import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/staff/data/staff_repository.dart';
import 'package:mobile/features/staff/domain/staff.dart';
import 'package:mobile/features/staff/widgets/status_badge.dart';
import 'package:mobile/features/staff/widgets/transaction_bottom_sheet.dart';
import 'package:mobile/shared/widgets/fading_button.dart';
import 'package:mobile/shared/widgets/info_block.dart';
import 'package:mobile/shared/widgets/info_card.dart';
import 'package:mobile/shared/widgets/badge.dart';

class StaffDetailsScreen extends ConsumerStatefulWidget {
  final Staff staff;

  const StaffDetailsScreen({super.key, required this.staff});

  @override
  ConsumerState<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends ConsumerState<StaffDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriodDays = 30;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final displayStaff = profileAsync.value?.copyWith(
      balance: widget.staff.balance,
      avatarUrl: widget.staff.avatarUrl,
      timeOnShift: widget.staff.timeOnShift,
      status: widget.staff.status != StaffStatus.offline ? widget.staff.status : profileAsync.value?.status,
    ) ?? widget.staff;

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
          tabs: const [
            Tab(text: 'Главное'),
            Tab(text: 'Детали'),
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
          child: Text('Ошибка загрузки деталей: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (details) {
        // Extract data from API response - data is inside "driver" object
        final driver = details['driver'] as Map<String, dynamic>?;
        final driverProfile = driver?['driver_profile'] as Map<String, dynamic>?;
        final accounts = driver?['accounts'] as List<dynamic>?;
        final car = driver?['car'] as Map<String, dynamic>?;
        final currentStatus = driver?['current_status'] as Map<String, dynamic>?;

        // Parse name from driver_profile
        final firstName = driverProfile?['first_name'] as String? ?? '—';
        final lastName = driverProfile?['last_name'] as String? ?? '—';
        final middleName = driverProfile?['middle_name'] as String? ?? '—';
        
        // Driver license info
        final licenseInfo = driverProfile?['license'] as Map<String, dynamic>?;
        final licenseNumber = licenseInfo?['number'] as String? ?? '—';
        final licenseCountry = licenseInfo?['country'] as String? ?? '—';
        final licenseIssueDate = licenseInfo?['issue_date'] as String? ?? '—';
        final licenseExpiryDate = licenseInfo?['expiration_date'] as String? ?? '—';

        // Work conditions
        final workRule = driverProfile?['work_rule_id'] as String? ?? '—';
        final balanceLimit = accounts?.isNotEmpty == true
            ? (accounts!.first as Map<String, dynamic>)['balance_limit']?.toString() ?? '—'
            : '—';
        final hireDate = driverProfile?['hire_date'] as String? ?? '—';
        final carId = car?['id'] as String? ?? '—';
        final employmentType = driverProfile?['employment_type'] as String? ?? '—';
        final providers = driverProfile?['providers'] as List<dynamic>?;
        final providersStr = providers?.join(', ') ?? 'Да';
        final balanceDenyOnlycard = driverProfile?['balance_deny_onlycard'] as bool? ?? false;

        // Personal data
        final phones = driverProfile?['phones'] as List<dynamic>?;
        final phone = phones?.isNotEmpty == true ? phones!.first as String? ?? '—' : '—';
        final email = driverProfile?['email'] as String? ?? '—';
        final address = driverProfile?['address'] as String? ?? '—';
        final deaf = driverProfile?['deaf'] as bool? ?? false;
        final comment = driverProfile?['comment'] as String? ?? '';
        final taxNumber = driverProfile?['tax_identification_number'] as String? ?? '—';
        final paymentServiceId = driverProfile?['payment_service_id'] as String? ?? '—';

        // Work status
        final workStatus = driverProfile?['work_status'] as String? ?? 'working';
        final statusText = workStatus == 'fired' ? 'Уволен' : 'Работает';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDetailSection(
              'Детали',
              'Некоторые поля недоступны для редактирования, для внесения изменений обратитесь в поддержку',
              _buildDetailGrid([
                {'Фамилия': lastName}, {'Водительский стаж с': '— (MOCK)'},
                {'Имя': firstName}, {'Серия и номер ВУ': licenseNumber},
                {'Отчество': middleName}, {'Страна выдачи ВУ': licenseCountry.toUpperCase()},
                {'Телефон': phone}, {'Дата выдачи ВУ': licenseIssueDate},
                {'Адрес': address}, {'Действует до': licenseExpiryDate},
                {'Статус': statusText}, {'Слабослышащий водитель': deaf ? 'Да' : 'Нет'},
              ]),
              onEdit: () {},
            ),
            _buildDetailSection(
              'Комментарий',
              '',
              Text(comment.isNotEmpty ? comment : 'Нет комментария', style: const TextStyle(fontSize: 15)),
              onEdit: () {},
            ),
            _buildDetailSection(
              'Условия работы',
              '',
              _buildDetailGrid([
                {'Условия работы': employmentType}, {'Заказы от платформы': providersStr},
                {'Лимит по счету': balanceLimit}, {'Запрещать принимать безналичные заказы': balanceDenyOnlycard ? 'Да' : 'Нет'},
                {'Дата принятия': hireDate}, {'Автомобиль ID': carId},
              ]),
            ),
            _buildDetailSection(
              'Личные данные',
              '',
              _buildDetailGrid([
                {'Доверенный контакт': '— (MOCK)'}, {'Дата рождения': '— (MOCK)'},
                {'Email': email}, {'ID для платежа': paymentServiceId},
                {'Отзыв о водителе': '— (MOCK)'},
              ]),
            ),
            _buildDetailSection(
              'Паспортные данные',
              '',
              _buildDetailGrid([
                {'Статус проверки паспорта': '— (MOCK)'}, {'Номер и серия': '— (MOCK)'},
                {'Вид паспорта': '— (MOCK)'}, {'Почтовый индекс': '— (MOCK)'},
                {'Страна': '— (MOCK)'}, {'Дата выдачи': '— (MOCK)'},
                {'Кем выдан': '— (MOCK)'}, {'Действует до': '— (MOCK)'},
                {'Адрес регистрации': '— (MOCK)'}, {'ОГРН': '— (MOCK)'},
                {'ИНН': taxNumber},
              ]),
            ),
            _buildDetailSection(
              'Банковские реквизиты',
              '',
              _buildDetailGrid([
                {'БИК': '— (MOCK)'}, {'Корреспондентский счет': '— (MOCK)'},
                {'Расчетный счет': '— (MOCK)'},
              ]),
              showDivider: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String subtitle, Widget content, {bool showDivider = true, VoidCallback? onEdit}) {
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
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ]
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
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDetailItem(items[i].keys.first, items[i].values.first)),
          const SizedBox(width: 16),
          if (i + 1 < items.length)
            Expanded(child: _buildDetailItem(items[i + 1].keys.first, items[i + 1].values.first))
          else
            const Expanded(child: SizedBox()),
        ],
      ));
      if (i + 2 < items.length) {
        rows.add(const SizedBox(height: 16));
      }
    }
    return Column(children: rows);
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, Staff displayStaff) {
    return InfoCard(
      title: displayStaff.name,
      subtitle: displayStaff.phoneNumber,
      icon: CircleAvatar(
        radius: 36,
        backgroundColor: AppTheme.controlsColor,
        backgroundImage: displayStaff.avatarUrl.isNotEmpty ? NetworkImage(displayStaff.avatarUrl) : null,
        child: displayStaff.avatarUrl.isEmpty
            ? Text(displayStaff.initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))
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
                CustomBadge(type: BadgeType.working, text: displayStaff.employmentType),
              if (displayStaff.vehicleType.isNotEmpty)
                 CustomBadge(type: BadgeType.preparation, text: 'Парковый автомобиль'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    InfoBlock(title: 'ТЕЛЕФОН', value: displayStaff.phoneNumber, icon: Icons.phone_outlined),
                    const SizedBox(height: 8),
                    InfoBlock(title: 'EMAIL', value: displayStaff.email.isNotEmpty ? displayStaff.email : 'Не указан', icon: Icons.email_outlined),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    InfoBlock(title: 'ID', value: displayStaff.id, icon: Icons.badge_outlined),
                    const SizedBox(height: 8),
                    InfoBlock(title: 'ИНН', value: displayStaff.taxNumber.isNotEmpty ? displayStaff.taxNumber : 'Не указан', icon: Icons.receipt_long_outlined),
                  ],
                ),
              ),
            ],
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
          _ActionButton(icon: Icons.chat_bubble_outline, label: 'Написать', onTap: () {}),
          const SizedBox(width: 8),
          _ActionButton(icon: Icons.work_outline, label: 'Сменить тип занятости', onTap: () {}),
          const SizedBox(width: 8),
          _ActionButton(icon: Icons.history, label: 'История изменений', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, Staff displayStaff) {
    final carAsync = ref.watch(carInfoProvider(displayStaff.carId));
    final carTitle = carAsync.value != null 
        ? '${carAsync.value!['brand']} ${carAsync.value!['model']}' 
        : (displayStaff.vehicleType.isNotEmpty ? displayStaff.vehicleType : 'Парковый автомобиль');
    final carValue = carAsync.value != null 
        ? '${carAsync.value!['callsign']}\nГод: ${carAsync.value!['year']}' 
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
                  TransactionBottomSheet.show(context: context, staff: displayStaff);
                },
                onRemoveTap: () {
                  TransactionBottomSheet.show(context: context, staff: displayStaff);
                },
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: _StatCard(title: 'Бонусы', value: 'Нет активных бонусов')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatCard(
                title: 'Комментарий',
                value: displayStaff.comment.isNotEmpty ? displayStaff.comment : 'Нет комментария',
                subtitle: 'Заметка об исполнителе',
                isEditable: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: carAsync.isLoading ? 'Загрузка...' : carTitle,
                value: carAsync.isLoading ? '' : carValue,
                subtitle: 'Детали авто',
                isEditable: true,
                valueFontSize: 13,
                valueColor: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicatorsSection(Staff displayStaff) {
    final ordersAsync = ref.watch(driverOrdersProvider(DriverOrdersParams(displayStaff.id, _selectedPeriodDays)));

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(_getPeriodLabel(), style: AppTheme.captionSecondary),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more, size: 14, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _IndicatorCard(title: 'Доход в Про', value: ordersAsync.isLoading ? '...' : '${totalIncome.toInt()} ₽')),
            const SizedBox(width: 8),
            Expanded(child: _IndicatorCard(title: 'Заказы', value: ordersAsync.isLoading ? '...' : '$totalOrders')),
            const SizedBox(width: 8),
            Expanded(child: _IndicatorCard(title: 'Отмененные', value: ordersAsync.isLoading ? '...' : '$cancelledOrders')),
            const SizedBox(width: 8),
            Expanded(child: _IndicatorCard(title: 'Время на линии', value: '${(workTimeSeconds / 3600).floor()} ч\n${((workTimeSeconds % 3600) / 60).floor()} мин')),
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

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
            Text(label, style: const TextStyle(fontFamily: 'Yandex Sans Text', fontSize: 14, fontWeight: FontWeight.w500)),
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
  final double valueFontSize;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.showBalanceActions = false,
    this.onAddTap,
    this.onRemoveTap,
    this.isEditable = false,
    this.valueFontSize = 20,
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
                        const Icon(Icons.chevron_right, size: 16, color: AppTheme.textSecondary),
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
                            child: Icon(Icons.remove_circle_outline, size: 22, color: AppTheme.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onAddTap,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.add_circle_outline, size: 22, color: AppTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  if (isEditable)
                    const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSecondary),
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
              fontWeight: FontWeight.w600,
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

  const _IndicatorCard({required this.title, required this.value});

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
              const Icon(Icons.chevron_right, size: 14, color: AppTheme.textSecondary),
            ],
          ),
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


