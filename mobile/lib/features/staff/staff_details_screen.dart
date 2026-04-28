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
    final nameParts = displayStaff.name.split(' ');
    final lastName = nameParts.isNotEmpty ? nameParts[0] : '—';
    final firstName = nameParts.length > 1 ? nameParts[1] : '—';
    final middleName = nameParts.length > 2 ? nameParts.sublist(2).join(' ') : '—';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailSection(
          'Детали',
          'Некоторые поля недоступны для редактирования, для внесения изменений обратитесь в поддержку',
          _buildDetailGrid([
            {'Фамилия': lastName}, {'Водительский стаж с': displayStaff.driverLicenseIssueDate.isNotEmpty ? displayStaff.driverLicenseIssueDate : '—'},
            {'Имя': firstName}, {'Серия и номер ВУ': displayStaff.driverLicenseNumber.isNotEmpty ? displayStaff.driverLicenseNumber : '—'},
            {'Отчество': middleName}, {'Страна выдачи ВУ': displayStaff.driverLicenseCountry.isNotEmpty ? displayStaff.driverLicenseCountry.toUpperCase() : '—'},
            {'Телефон': displayStaff.phoneNumber.isNotEmpty ? displayStaff.phoneNumber : '—'}, {'Дата выдачи ВУ': displayStaff.driverLicenseIssueDate.isNotEmpty ? displayStaff.driverLicenseIssueDate : '—'},
            {'Адрес': displayStaff.address.isNotEmpty ? displayStaff.address : '—'}, {'Действует до': displayStaff.driverLicenseExpiryDate.isNotEmpty ? displayStaff.driverLicenseExpiryDate : '—'},
            {'Статус': displayStaff.status == StaffStatus.fired ? 'Уволен' : 'Работает'}, {'Слабослышащий водитель': 'Нет'},
          ]),
          onEdit: () {},
        ),
        _buildDetailSection(
          'Комментарий',
          '',
          Text(displayStaff.comment.isNotEmpty ? displayStaff.comment : 'Нет комментария', style: const TextStyle(fontSize: 15)),
          onEdit: () {},
        ),
        _buildDetailSection(
          'Условия работы',
          '',
          _buildDetailGrid([
            {'Условия работы': displayStaff.employmentType.isNotEmpty ? displayStaff.employmentType : '—'}, {'Заказы от платформы': 'Да'},
            {'Лимит по счету': displayStaff.balanceLimit.isNotEmpty ? displayStaff.balanceLimit : '—'}, {'Запрещать принимать безналичные заказы': 'Нет'},
            {'Дата принятия': displayStaff.hireDate.isNotEmpty ? displayStaff.hireDate : '—'}, {'Автомобиль ID': displayStaff.carId.isNotEmpty ? displayStaff.carId : '—'},
          ]),
        ),
        _buildDetailSection(
          'Личные данные',
          '',
          _buildDetailGrid([
            {'Доверенный контакт': '—'}, {'Дата рождения': '—'},
            {'Email': displayStaff.email.isNotEmpty ? displayStaff.email : '—'}, {'ID для платежа': displayStaff.id},
            {'Отзыв о водителе': '—'},
          ]),
        ),
        _buildDetailSection(
          'Паспортные данные',
          '',
          _buildDetailGrid([
            {'Статус проверки паспорта': 'Не пройдено'}, {'Номер и серия': '—'},
            {'Вид паспорта': 'Не указано'}, {'Почтовый индекс': '—'},
            {'Страна': 'Не указано'}, {'Дата выдачи': '—'},
            {'Кем выдан': '—'}, {'Действует до': '—'},
            {'Адрес регистрации': '—'}, {'ОГРН': '—'},
            {'ИНН': displayStaff.taxNumber.isNotEmpty ? displayStaff.taxNumber : '—'},
          ]),
        ),
        _buildDetailSection(
          'Банковские реквизиты',
          '',
          _buildDetailGrid([
            {'БИК': '—'}, {'Корреспондентский счет': '—'},
            {'Расчетный счет': '—'},
          ]),
          showDivider: false,
        ),
      ],
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
    final ordersAsync = ref.watch(driverOrdersProvider(displayStaff.id));

    double totalIncome = 0;
    int totalOrders = 0;
    int cancelledOrders = 0;

    ordersAsync.whenData((orders) {
      for (var order in orders) {
        final driverProfile = order['driver_profile'] as Map<String, dynamic>?;
        if (driverProfile != null && driverProfile['id'] == displayStaff.id) {
          totalOrders++;
          if (order['status'] == 'complete') {
            totalIncome += double.tryParse(order['price']?.toString() ?? '0') ?? 0;
          } else if (order['status'] == 'cancelled') {
            cancelledOrders++;
          }
        }
      }
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                  SizedBox(width: 6),
                  Text('За 30 дней', style: AppTheme.captionSecondary),
                  SizedBox(width: 4),
                  Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
                ],
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
            const Expanded(child: _IndicatorCard(title: 'Время на линии', value: '0 мин')),
          ],
        ),
      ],
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
