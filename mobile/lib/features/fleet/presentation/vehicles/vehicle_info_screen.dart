import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/theme.dart';
import '../../domain/vehicle.dart';
import '../../domain/vehicle_details.dart';
import '../../domain/vehicle_extras.dart';
import 'providers/vehicles_provider.dart';
import 'widgets/tariff_edit_bottom_sheet.dart';
import 'widgets/edit_vehicle_bottom_sheet.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';

class VehicleInfoScreen extends ConsumerStatefulWidget {
  final Vehicle? vehicle;

  const VehicleInfoScreen({super.key, this.vehicle});

  @override
  ConsumerState<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends ConsumerState<VehicleInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _efficiencyFrom;
  late DateTime _efficiencyTo;

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDateDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final now = DateTime.now();
    _efficiencyFrom = DateTime(now.year, now.month, 1);
    _efficiencyTo = now;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.vehicle != null
              ? '${widget.vehicle!.plateNumber} ${widget.vehicle!.model} ${widget.vehicle!.year}'
              : 'Информация об автомобиле',
          style: AppTheme.appBarTitle,
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Главное'),
            Tab(text: 'Детали'),
            Tab(text: 'Водители'),
            Tab(text: 'Фотоконтроль'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMainTab(),
          _buildDetailsTab(),
          _buildDriversTab(),
          _buildPhotoControlTab(),
        ],
      ),
    );
  }

  Widget _buildMainTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.vehicle != null) _buildKeyInfoBlock(widget.vehicle!.id),
        if (widget.vehicle != null) const SizedBox(height: 16),
        _buildSummaryCards(),
        const SizedBox(height: 16),
        _buildBanner(),
        const SizedBox(height: 16),
        _buildTariffsSection(),
        const SizedBox(height: 16),
        _buildRentSection(),
        const SizedBox(height: 24),
        _buildSettingsSection(),
      ],
    );
  }

  Widget _buildKeyInfoBlock(String vehicleId) {
    final keyInfoAsync = ref.watch(vehicleKeyInfoProvider(vehicleId));
    final extrasAsync = ref.watch(vehicleStatusExtrasProvider(vehicleId));

    if (keyInfoAsync is AsyncLoading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (keyInfoAsync is AsyncError) return const SizedBox.shrink();
    final info = keyInfoAsync.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── White main card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                '${info.number} ${info.brand} ${info.model} ${info.year}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              // Action badge pills
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (!info.badges.isOwnershipConfirmed)
                    _actionBadge(
                      label: 'Подтвердите право использования',
                      color: const Color(0xFFFF4500),
                      hasArrow: true,
                    ),
                  if (info.badges.branding == 'no_branding')
                    _actionBadge(
                      label: 'Забрендируйте автомобиль',
                      color: const Color(0xFF3B82F6),
                    ),
                  if (info.vehicleOwnerType == 'park')
                    _actionBadge(
                      label: 'Начните сдавать через Гараж',
                      color: const Color(0xFF2563EB),
                      hasArrow: true,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Info chips: owner type + drivers count
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _keyInfoChip(
                    icon: Icons.home_outlined,
                    label: info.ownerTypeLabel,
                  ),
                  _keyInfoChip(
                    icon: Icons.person_outline,
                    label:
                        '${info.badges.driversTotal} ${_pluralDrivers(info.badges.driversTotal)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Status items
              _buildStatusItem(
                icon: Icons.circle,
                iconSize: 10,
                label: _vehicleStatusLabel(info.status),
                active: false,
              ),
              extrasAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (extras) => Column(
                  children: [
                    _buildStatusItem(
                      icon: Icons.lock_outline,
                      label: 'Ограничить поездки в других парках',
                      active: extras.supplyLockActive,
                    ),
                    _buildStatusItem(
                      icon: Icons.lock_outline,
                      label: 'Запрет на поездки без ОСАГО',
                      active: extras.isPolicyRequired,
                    ),
                    _buildStatusItem(
                      icon: Icons.autorenew,
                      label: 'Компенсация ОСАГО',
                      active: extras.parkCompensationEnabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showChangelogSheet(vehicleId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('История изменений'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black87),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Архивировать'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ── Gray ownership exam panel ──
        if (!info.badges.isOwnershipConfirmed &&
            info.badges.ownershipExam != null) ...
          _buildOwnershipPanel(info.badges.ownershipExam!),
      ],
    );
  }

  List<Widget> _buildOwnershipPanel(VehicleOwnershipExam exam) {
    return [
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            ...exam.descriptionLines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style:
                            TextStyle(fontSize: 13, color: Colors.black45)),
                    Expanded(
                      child: Text(
                        line,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Подтвердить право использования'),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool active,
    double iconSize = 16,
  }) {
    final color = active ? Colors.black87 : Colors.black38;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(label, style: TextStyle(fontSize: 14, color: color))),
        ],
      ),
    );
  }

  Widget _actionBadge({
    required String label,
    required Color color,
    bool hasArrow = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          if (hasArrow) ...
            const [
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 14, color: Colors.white),
            ],
        ],
      ),
    );
  }

  String _vehicleStatusLabel(String status) {
    switch (status) {
      case 'working':
        return 'Работает';
      case 'no_driver':
        return 'Без водителя';
      case 'repairing':
        return 'На ремонте';
      case 'pending':
        return 'Ожидает';
      case 'not_working':
        return 'Не работает';
      case 'unknown':
      default:
        return 'Другое';
    }
  }

  Widget _keyInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  String _pluralDrivers(int n) {
    if (n % 100 >= 11 && n % 100 <= 19) return 'водителей';
    switch (n % 10) {
      case 1:
        return 'водитель';
      case 2:
      case 3:
      case 4:
        return 'водителя';
      default:
        return 'водителей';
    }
  }

  void _showChangelogSheet(String vehicleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _ChangelogSheetContent(
          vehicleId: vehicleId,
          scrollController: scrollController,
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (widget.vehicle == null) {
      return const SizedBox.shrink();
    }
    final params = EfficiencyParams(
      vehicleId: widget.vehicle!.id,
      dateFrom: _fmtDate(_efficiencyFrom),
      dateTo: _fmtDate(_efficiencyTo),
    );
    final efficiencyAsync = ref.watch(vehicleEfficiencyProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Статистика',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () async {
                final result = await CustomDateRangePickerBottomSheet.show(
                  context: context,
                  title: 'Период статистики',
                  startDate: _efficiencyFrom,
                  endDate: _efficiencyTo,
                );
                if (result != null) {
                  setState(() {
                    _efficiencyFrom = result.start;
                    _efficiencyTo = result.end;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      '${_fmtDateDisplay(_efficiencyFrom)} — ${_fmtDateDisplay(_efficiencyTo)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        efficiencyAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (e) => Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildInfoCard('В простое', '${e.inactiveDays} дн.')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInfoCard('Поездок', '${e.successOrdersCount}')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildInfoCard('Время на линии', e.supplyTimeFormatted)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInfoCard('Доход', e.incomeFormatted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Подтвердите право использования и получите полный контроль над автомобилем',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Подтвердить право использования'),
          ),
        ],
      ),
    );
  }

  Widget _buildTariffsSection() {
    if (widget.vehicle == null) {
      return const SizedBox.shrink();
    }

    final vehicleDetailsAsync = ref.watch(
      vehicleDetailsProvider(widget.vehicle!.id),
    );

    return vehicleDetailsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Включенные тарифы',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Загрузка...', style: TextStyle(color: Colors.black87)),
          ],
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Включенные тарифы',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('—', style: TextStyle(color: Colors.black87)),
          ],
        ),
      ),
      data: (details) {
        final vehicleId = widget.vehicle?.id ?? '';
        final categoriesAsync = vehicleId.isNotEmpty ? ref.watch(vehicleCategoriesProvider(vehicleId)) : null;
        final categories = categoriesAsync?.value ?? details.parkProfile?.categories ?? widget.vehicle?.tariffs ?? [];
        final categoryNamesMap = ref.watch(carCategoriesProvider).value ?? {};
        final tariffNames = categories.map((id) => categoryNamesMap[id] ?? id).join(', ');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Включенные тарифы',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showTariffEditSheet(categories),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              categoriesAsync != null && categoriesAsync.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      tariffNames.isEmpty ? '—' : tariffNames,
                      style: const TextStyle(color: Colors.black87),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _showTariffEditSheet(List<String> currentTariffs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: TariffEditBottomSheet(
          currentTariffs: currentTariffs,
          onSave: (selectedTariffs) async {
            final service = ref.read(vehiclesServiceProvider);
            await service.updateCategories(widget.vehicle!.id, selectedTariffs);

            // Refresh categories and details
            ref.invalidate(vehicleCategoriesProvider(widget.vehicle!.id));
            ref.invalidate(vehicleDetailsProvider(widget.vehicle!.id));
          },
        ),
      ),
    );
  }

  Widget _buildRentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Условие аренды', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            '7/0 3000₽ • Схема\n1000₽ • Депозит',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    if (widget.vehicle == null) {
      return const SizedBox.shrink();
    }
    final vehicleId = widget.vehicle!.id;
    final brandingAsync = ref.watch(vehicleBrandingProvider(vehicleId));
    final chairsAsync = ref.watch(childChairsProvider(vehicleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Настройки',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // ─── Брендинг ────────────────────────────────────────────────
        Text(
          'Брендинг',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        const Text(
          'После добавления оклейки или Lightbox, водитель должен пройти фотоконтроль в приложении Про',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        brandingAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (b) {
            final cards = <Widget>[];

            // Оклейка
            if (b.sticker) {
              cards.add(_buildSettingCard(
                title: 'Оклейка',
                status: b.stickerConfirmed ? 'Подтверждено' : 'Ожидаем фотоконтроль',
                description: b.stickerConfirmed
                    ? null
                    : 'Мы автоматически обновим статус, когда водитель пройдет фотоконтроль',
                icon: b.stickerConfirmed ? Icons.check_circle : Icons.warning_rounded,
                iconColor: b.stickerConfirmed ? Colors.green : Colors.orange,
                showDelete: true,
                onDelete: () => _showBrandingDeleteSheet('Оклейка', () {
                  _applyBranding(vehicleId, b, sticker: false);
                }),
              ));
            } else {
              cards.add(_buildActionCard(
                title: 'Оклейка',
                subtitle: 'Нажмите, чтобы добавить',
                onTap: () => _applyBranding(vehicleId, b, sticker: true),
              ));
            }

            // Lightbox — заблокирован если активен Digitalbox
            if (b.lightbox) {
              cards.add(_buildSettingCard(
                title: 'Lightbox',
                status: b.lightboxConfirmed ? 'Подтверждено' : 'Ожидаем фотоконтроль',
                description: b.lightboxConfirmed
                    ? null
                    : 'Мы автоматически обновим статус, когда водитель пройдет фотоконтроль',
                icon: b.lightboxConfirmed ? Icons.check_circle : Icons.warning_rounded,
                iconColor: b.lightboxConfirmed ? Colors.green : Colors.orange,
                showDelete: true,
                onDelete: () => _showBrandingDeleteSheet('Lightbox', () {
                  _applyBranding(vehicleId, b, lightbox: false);
                }),
              ));
            } else {
              final blockedByDigital = b.digitalLightbox;
              cards.add(_buildActionCard(
                title: 'Lightbox',
                subtitle: blockedByDigital
                    ? 'Недоступно: сначала удалите Digitalbox'
                    : 'Нажмите, чтобы добавить',
                disabled: blockedByDigital,
                onTap: blockedByDigital
                    ? null
                    : () => _applyBranding(vehicleId, b,
                          lightbox: true, digitalLightbox: false),
              ));
            }

            // Digitalbox — заблокирован если активен Lightbox
            if (b.digitalLightbox) {
              cards.add(_buildSettingCard(
                title: 'Digitalbox',
                status: b.digitalLightboxConfirmed
                    ? 'Подтверждено'
                    : 'Ожидаем фотоконтроль',
                description: b.digitalLightboxConfirmed
                    ? null
                    : 'Мы автоматически обновим статус, когда водитель пройдет фотоконтроль',
                icon: b.digitalLightboxConfirmed
                    ? Icons.check_circle
                    : Icons.warning_rounded,
                iconColor:
                    b.digitalLightboxConfirmed ? Colors.green : Colors.orange,
                showDelete: true,
                onDelete: () => _showBrandingDeleteSheet('Digitalbox', () {
                  _applyBranding(vehicleId, b, digitalLightbox: false);
                }),
              ));
            } else {
              final blockedByLightbox = b.lightbox;
              cards.add(_buildActionCard(
                title: 'Digitalbox',
                subtitle: blockedByLightbox
                    ? 'Недоступно: сначала удалите Lightbox'
                    : 'Нажмите, чтобы добавить',
                disabled: blockedByLightbox,
                onTap: blockedByLightbox
                    ? null
                    : () => _applyBranding(vehicleId, b,
                          digitalLightbox: true, lightbox: false),
              ));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cards
                      .map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: c))
                      .toList(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // ─── Детские кресла ──────────────────────────────────────────
        Text(
          'Детские кресла',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        const Text(
          'Детские кресла, которые принадлежат водителю, может редактировать только сам водитель в приложении Про',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        chairsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (chairs) {
            final all = chairs.all;
            if (all.isEmpty) {
              return const Text(
                'Кресла не добавлены',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: all
                      .asMap()
                      .entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildChildSeatCard(
                              title: 'Кресло ${e.key + 1}',
                              status: e.value.qcStatusLabel,
                              categories: e.value.categoriesLabel,
                              id: e.value.id,
                            ),
                          ))
                      .toList(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSettingGroup({
    required String title,
    required String subtitle,
    required List<Widget> cards,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards
                  .map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: card,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String status,
    String? description,
    required IconData icon,
    required Color iconColor,
    bool showDelete = false,
    VoidCallback? onDelete,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (showDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          if (description != null) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade50 : Colors.white,
          border: Border.all(
              color: disabled ? Colors.grey.shade200 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(disabled ? Icons.block_outlined : Icons.add,
                    color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: disabled
                        ? Colors.grey.shade400
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: disabled
                      ? Colors.grey.shade400
                      : Colors.grey,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBrandingDeleteSheet(
      String name, VoidCallback onConfirm) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Удалить $name',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$name можно добавить заново, но потребуется время на проверку',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Отмена',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      onConfirm();
                    },
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD600),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Удалить',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyBranding(
    String vehicleId,
    VehicleBranding current, {
    bool? sticker,
    bool? lightbox,
    bool? digitalLightbox,
  }) async {
    final service = ref.read(vehiclesServiceProvider);
    await service.updateVehicleBranding(
      vehicleId,
      sticker: sticker ?? current.sticker,
      lightbox: lightbox ?? current.lightbox,
      digitalLightbox: digitalLightbox ?? current.digitalLightbox,
    );
    ref.invalidate(vehicleBrandingProvider(vehicleId));
  }

  Widget _buildChildSeatCard({
    required String title,
    required String status,
    required String categories,
    required String id,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              const Icon(Icons.delete_outline, size: 20, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: categories,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const TextSpan(
                  text: ' • категории',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$id • ID',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    if (widget.vehicle == null) {
      return const Center(child: Text('Машина не выбрана'));
    }

    final vehicleDetailsAsync = ref.watch(
      vehicleDetailsProvider(widget.vehicle!.id),
    );

    return vehicleDetailsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
      error: (error, stack) =>
          Center(child: Text('Ошибка загрузки данных: $error')),
      data: (details) {
        final specs = details.specifications;
        final licenses = details.licenses;
        final parkProfile = details.parkProfile;

        String parseTransmission(String? tr) {
          switch (tr) {
            case 'mechanical':
              return 'Механика';
            case 'automatic':
              return 'Автомат';
            case 'robotic':
              return 'Робот';
            case 'variator':
              return 'Вариатор';
            default:
              return 'Неизвестный';
          }
        }

        String parseFuel(String? fuel) {
          switch (fuel) {
            case 'petrol':
              return 'Бензин';
            case 'methane':
              return 'Метан';
            case 'propane':
              return 'Пропан';
            case 'electricity':
              return 'Электро';
            default:
              return '—';
          }
        }

        String _getVehicleType(ParkProfile? profile) {
          // Определяем тип ТС по категориям
          final hasCargo = profile?.categories?.contains('cargo') ?? false;
          return hasCargo ? 'Грузовой автомобиль' : 'Легковой автомобиль';
        }

        bool hasConditioner =
            parkProfile?.amenities?.contains('conditioner') ?? false;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildDetailSection(
              'Об автомобиле',
              'Детали',
              _buildDetailGrid([
                {'СТС': licenses?.registrationCertificate ?? '—'},
                {'Год выпуска': specs?.year?.toString() ?? '—'},
                {'Дата выдачи СТС': licenses?.registrationCertIssueDate ?? '—'},
                {'Номер кузова': specs?.bodyNumber ?? '—'},
                {
                  'Госномер':
                      licenses?.licencePlateNumber ??
                      widget.vehicle?.plateNumber ??
                      '—',
                },
                {'Цвет': specs?.color ?? widget.vehicle?.color ?? '—'},
                {'VIN': specs?.vin ?? '—'},
                {'КПП': parseTransmission(specs?.transmission)},
                {'Марка': specs?.brand ?? widget.vehicle?.brand ?? '—'},
                {'Вид топлива': parseFuel(parkProfile?.fuelType)},
                {'Модель': specs?.model ?? '—'},
                {'Тип ТС': _getVehicleType(parkProfile)},
                {
                  'Позывной':
                      parkProfile?.callsign ?? widget.vehicle?.callsign ?? '—',
                },
              ]),
              onEdit: () => _showEditVehicleSheet(details),
            ),
            _buildDetailSection(
              'Комплектация',
              'Дополнительная информация',
              _buildDetailGrid([
                {'Кондиционер': hasConditioner ? 'Да' : 'Нет'},
              ]),
              showDivider: false,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
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

  void _showEditVehicleSheet(VehicleDetails details) {
    if (widget.vehicle == null) return;

    EditVehicleBottomSheet.show(context, widget.vehicle!.id, details);
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

  Widget _buildDriversTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDriverCard(
          status: 'Выполняет заказы',
          statusColor: Colors.green,
          state: 'Офлайн',
          name: 'Большаков Владислав Валерьевич',
          license: '1351770913',
          phone: '+79603646186',
          date: '29.05.2025',
        ),
        _buildDriverCard(
          status: 'Сотрудничество завершено',
          statusColor: Colors.red,
          state: 'Офлайн',
          name: 'Тестов Тест Тестович',
          license: '6882888888',
          phone: '+79998232323',
          date: '19.11.2025',
        ),
      ],
    );
  }

  Widget _buildDriverCard({
    required String status,
    required Color statusColor,
    required String state,
    required String name,
    required String license,
    required String phone,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                state,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFEEEEEE)),
          _buildDriverInfoRow('ВУ', license),
          const SizedBox(height: 8),
          _buildDriverInfoRow('Телефон', phone, isLink: true),
          const SizedBox(height: 8),
          _buildDriverInfoRow('Дата принятия', date),
        ],
      ),
    );
  }

  Widget _buildDriverInfoRow(
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: isLink ? Colors.blue : Colors.black87,
            fontSize: 13,
            decoration: isLink ? TextDecoration.underline : null,
            decorationColor: Colors.blue,
            decorationThickness: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoControlTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/waiting-man.svg', width: 250),
          const SizedBox(height: 24),
          const Text(
            'Ещё нет фотографий',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Подождите, пока водитель загрузит их',
            style: TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 60,
          ), // Add a little extra space to center better optically
        ],
      ),
    );
  }
}

// ─── Changelog bottom sheet ──────────────────────────────────────────────────

class _ChangelogSheetContent extends ConsumerStatefulWidget {
  final String vehicleId;
  final ScrollController scrollController;

  const _ChangelogSheetContent({
    required this.vehicleId,
    required this.scrollController,
  });

  @override
  ConsumerState<_ChangelogSheetContent> createState() =>
      _ChangelogSheetContentState();
}

class _ChangelogSheetContentState
    extends ConsumerState<_ChangelogSheetContent> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final changelogAsync =
        ref.watch(vehicleChangelogProvider(widget.vehicleId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
          child: Row(
            children: [
              const Text(
                'История изменений',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: changelogAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, _) => Center(child: Text('Ошибка: $e')),
            data: (resp) {
              if (resp.changes.isEmpty) {
                return const Center(
                    child: Text('Нет записей',
                        style: TextStyle(color: Colors.grey)));
              }
              return ListView.separated(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: resp.changes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final change = resp.changes[i];
                  final isOpen = _expanded.contains(i);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (isOpen) {
                        _expanded.remove(i);
                      } else {
                        _expanded.add(i);
                      }
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        change.headerTitle,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${change.author.name} · ${change.formattedDate}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isOpen
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          if (isOpen) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: change.values.map((v) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.fieldName,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        if (v.oldValue.isNotEmpty)
                                          Text(
                                            v.oldValue,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black45,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                        const Text('↓',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54)),
                                        Text(
                                          v.newValue.isEmpty ? '—' : v.newValue,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
