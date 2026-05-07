import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/reports/data/payment_transactions_service.dart';
import 'package:mobile/features/reports/domain/payment_transaction.dart';
import 'package:mobile/features/fleet/providers/report_downloads_provider.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/report_downloads_sheet.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentTransactionsScreen extends ConsumerStatefulWidget {
  const PaymentTransactionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentTransactionsScreen> createState() =>
      _PaymentTransactionsScreenState();
}

class _PaymentTransactionsScreenState
    extends ConsumerState<PaymentTransactionsScreen> {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<PaymentTransaction> _items = [];
  String? _cursor;
  String? _error;
  PaymentTransactionsFilter _filter = PaymentTransactionsFilter();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _cursor != null) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _items = [];
      _cursor = null;
    });
    try {
      final svc = ref.read(paymentTransactionsServiceProvider);
      final res = await svc.getTransactions(filter: _filter);
      if (!mounted) return;
      setState(() {
        _items = res.transactions;
        _cursor = res.cursor;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_cursor == null || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final svc = ref.read(paymentTransactionsServiceProvider);
      final res =
          await svc.getTransactions(filter: _filter, cursor: _cursor);
      if (!mounted) return;
      setState(() {
        _items.addAll(res.transactions);
        _cursor = res.cursor;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  // ─── date range picker ────────────────────────────────────────────────────

  Future<void> _pickDates() async {
    final range = await CustomDateRangePickerBottomSheet.show(
      context: context,
      title: 'Период',
      startDate: _filter.dateFrom,
      endDate: _filter.dateTo,
    );
    if (range != null) {
      setState(() {
        _filter = _filter.copyWith(dateFrom: range.start, dateTo: range.end);
      });
      _load();
    }
  }

  // ─── filter sheet ─────────────────────────────────────────────────────────

  Future<void> _showFilterSheet() async {
    final result = await _PaymentTransactionsFilterSheet.show(
      context: context,
      filter: _filter,
    );
    if (result != null) {
      setState(() => _filter = result);
      _load();
    }
  }

  // ─── date label ───────────────────────────────────────────────────────────

  String _dateLabel(DateTime dt) {
    const months = [
      'янв.', 'февр.', 'мар.', 'апр.', 'мая', 'июня',
      'июля', 'авг.', 'сент.', 'окт.', 'нояб.', 'дек.'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _timeLabel(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  // ─── grouping ─────────────────────────────────────────────────────────────

  List<_ListItem> _buildListItems() {
    final result = <_ListItem>[];
    String? lastGroup;
    for (final tx in _items) {
      final local = tx.createdAt.toLocal();
      final groupKey =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      if (groupKey != lastGroup) {
        lastGroup = groupKey;
        result.add(_ListItem.header(_dateLabel(local)));
      }
      result.add(_ListItem.transaction(tx));
    }
    return result;
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final downloads = ref.watch(reportDownloadsProvider);
    final activeCount =
        downloads.where((d) => d.isActive || d.canDownload).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Расчёты с исполнителями',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.download_rounded),
                onPressed: () => ReportDownloadsSheet.show(context),
              ),
              if (activeCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.buttonColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── toolbar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                // download
                _ToolbarBtn(
                  icon: Icons.download_rounded,
                  onTap: () async {
                    await ref
                        .read(reportDownloadsProvider.notifier)
                        .startReportDownload(
                          reportType: 'transactions',
                          filters: {},
                          dateFrom: _filter.dateFrom ?? DateTime(DateTime.now().year, DateTime.now().month, 1),
                          dateTo: _filter.dateTo ?? DateTime.now(),
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Создание отчёта начато'),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                // date range
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDates,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _filter.dateFrom != null
                            ? AppTheme.buttonColor
                            : AppTheme.controlsColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _filter.dateFrom != null && _filter.dateTo != null
                                  ? '${_dateLabel(_filter.dateFrom!)} — ${_dateLabel(_filter.dateTo!)}'
                                  : 'Период',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // filters
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _filter.isModified
                          ? AppTheme.buttonColor
                          : AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Фильтры',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── list ─────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary)),
                            const SizedBox(height: 12),
                            TextButton(
                                onPressed: _load,
                                child: const Text('Повторить')),
                          ],
                        ),
                      )
                    : _items.isEmpty
                        ? const Center(
                            child: Text('Нет транзакций',
                                style: TextStyle(
                                    color: AppTheme.textSecondary)),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: _buildList(),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final listItems = _buildListItems();
    return ListView.builder(
      controller: _scrollCtrl,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: listItems.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == listItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final item = listItems[i];
        if (item.isHeader) {
          return _buildGroupHeader(item.label!);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildTransactionCard(item.tx!),
        );
      },
    );
  }

  Widget _buildGroupHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(PaymentTransaction tx) {
    final amountColor =
        tx.isTopup ? const Color(0xFF00B341) : AppTheme.textPrimary;

    return GestureDetector(
      onTap: () => _TransactionDetailSheet.show(context, tx, ref),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 0.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── row 1: logo + type + amount ───────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _PaymentLogo(url: tx.paymentSystemLogoUrl, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tx.typeLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${tx.amountFormatted} ₽',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
              ],
            ),

            // ─── row 2: error (if any) ──────────────────────────────────────
            if (tx.errorText != null && tx.errorText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 46), // align with text after logo
                  const Icon(Icons.error_outline,
                      size: 14, color: Color(0xFFFF7B24)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tx.errorText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF7B24),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // ─── row 3: avatar + name + time ───────────────────────────────
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 46), // align with text after logo
                _ContractorAvatar(
                  name: tx.contractor.name,
                  avatarUrl: tx.contractor.avatarUrl,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tx.contractor.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _timeLabel(tx.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── helpers ──────────────────────────────────────────────────────────────────

class _ListItem {
  final bool isHeader;
  final String? label;
  final PaymentTransaction? tx;

  const _ListItem._({required this.isHeader, this.label, this.tx});

  factory _ListItem.header(String label) =>
      _ListItem._(isHeader: true, label: label);

  factory _ListItem.transaction(PaymentTransaction tx) =>
      _ListItem._(isHeader: false, tx: tx);
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.controlsColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 20, color: AppTheme.textPrimary),
      ),
    );
  }
}

class _ContractorAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;

  const _ContractorAvatar({
    required this.name,
    this.avatarUrl,
    this.size = 44,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _fallback(radius),
          placeholder: (_, __) => _fallback(radius),
        ),
      );
    }
    return _fallback(radius);
  }

  Widget _fallback(double radius) {
    final fontSize = size * 0.36;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.controlsColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  final String? url;
  final double size;

  const _PaymentLogo({this.url, this.size = 36});

  bool get _isSvg => url != null && url!.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (url == null) return _fallback();
    final radius = BorderRadius.circular(size / 4);
    if (_isSvg) {
      return ClipRRect(
        borderRadius: radius,
        child: SvgPicture.network(
          url!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => _fallback(),
        ),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => _fallback(),
        placeholder: (_, __) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        Icons.account_balance_wallet_outlined,
        size: size * 0.55,
        color: AppTheme.textSecondary,
      ),
    );
  }
}

// ─── Transaction Detail Sheet ─────────────────────────────────────────────────

class _TransactionDetailSheet extends StatefulWidget {
  final PaymentTransaction tx;
  final WidgetRef ref;

  const _TransactionDetailSheet({required this.tx, required this.ref});

  static void show(BuildContext context, PaymentTransaction tx, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransactionDetailSheet(tx: tx, ref: ref),
    );
  }

  @override
  State<_TransactionDetailSheet> createState() =>
      _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends State<_TransactionDetailSheet> {
  PaymentTransactionDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final svc = widget.ref.read(paymentTransactionsServiceProvider);
      final d = await svc.getTransactionById(
        transactionId: widget.tx.id,
        transactionType: widget.tx.transactionType,
      );
      if (mounted) setState(() { _detail = d; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fullDateLabel(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'янв.', 'февр.', 'мар.', 'апр.', 'мая', 'июня',
      'июля', 'авг.', 'сент.', 'окт.', 'нояб.', 'дек.'
    ];
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '${local.day} ${months[local.month - 1]} ${local.year} г., $time';
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final detail = _detail;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  tx.typeLabel,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          else if (detail != null) ...[
            // date
            Text(
              _fullDateLabel(detail.createdAt),
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 6),

            // big amount
            Text(
              '${detail.amountFormatted} ₽',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: detail.isTopup
                    ? const Color(0xFF00B341)
                    : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // detail rows
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 12),
                  if (detail.isTopup) ...[
                    if (detail.driverBalanceTopup != null)
                      _DetailRow('Перечислено исполнителем',
                          detail.driverBalanceFmt),
                    if (detail.parkReceived != null)
                      _DetailRow('Получено партнёром', detail.parkReceivedFmt),
                  ] else ...[
                    if (detail.driverReceived != null)
                      _DetailRow('Начислено исполнителю',
                          detail.driverReceivedFmt),
                    if (detail.partnerFee != null)
                      _DetailRow('Комиссия партнёра', detail.partnerFeeFmt),
                    if (detail.parkReceived != null)
                      _DetailRow('Получено партнёром', detail.parkReceivedFmt),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 16),

                  // contractor
                  _InfoBlock('Исполнитель', detail.contractor.name),
                  const SizedBox(height: 14),

                  // bank
                  if (detail.paymentSystemProvider != null) ...[
                    _InfoBlock('Банк', detail.paymentSystemProvider!),
                    const SizedBox(height: 14),
                  ],

                  // id
                  _InfoBlock('ID транзакции', detail.id),
                  const SizedBox(height: 8),

                  // error
                  if (detail.errorText != null) ...[
                    const SizedBox(height: 6),
                    _InfoBlock('Ошибка', detail.errorText!,
                        valueColor: const Color(0xFFE64646)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 15, color: AppTheme.textPrimary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoBlock(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppTheme.textPrimary,
              )),
        ],
      ),
    );
  }
}

// ─── Filter bottom sheet ───────────────────────────────────────────────────────

class _PaymentTransactionsFilterSheet extends StatefulWidget {
  final PaymentTransactionsFilter filter;

  const _PaymentTransactionsFilterSheet({required this.filter});

  static Future<PaymentTransactionsFilter?> show({
    required BuildContext context,
    required PaymentTransactionsFilter filter,
  }) {
    return showModalBottomSheet<PaymentTransactionsFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentTransactionsFilterSheet(filter: filter),
    );
  }

  @override
  State<_PaymentTransactionsFilterSheet> createState() =>
      _PaymentTransactionsFilterSheetState();
}

class _PaymentTransactionsFilterSheetState
    extends State<_PaymentTransactionsFilterSheet> {
  late List<String> _types;
  late List<String> _statuses;

  static const _allTypes = [
    ('instant_payout', 'Моментальная выплата'),
    ('topup', 'Пополнение'),
    ('statement_payout', 'Ведомость'),
    ('single_payout', 'Выплата'),
  ];

  static const _allStatuses = [
    ('completed', 'Выполнено'),
    ('error', 'Ошибка'),
    ('processing', 'В обработке'),
  ];

  @override
  void initState() {
    super.initState();
    _types = List.from(widget.filter.transactionTypes);
    _statuses = List.from(widget.filter.statuses);
  }

  void _toggleType(String t) {
    setState(() {
      _types.contains(t) ? _types.remove(t) : _types.add(t);
    });
  }

  void _toggleStatus(String s) {
    setState(() {
      _statuses.contains(s) ? _statuses.remove(s) : _statuses.add(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Фильтры',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Тип транзакции',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allTypes.map((t) {
                final selected = _types.contains(t.$1);
                return GestureDetector(
                  onTap: () => _toggleType(t.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.buttonColor
                          : AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(t.$2,
                        style: const TextStyle(fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Статус',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allStatuses.map((s) {
                final selected = _statuses.contains(s.$1);
                return GestureDetector(
                  onTap: () => _toggleStatus(s.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.buttonColor
                          : AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s.$2,
                        style: const TextStyle(fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _types = [];
                        _statuses = [];
                      });
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.controlsColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Сбросить')),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                        PaymentTransactionsFilter(
                          dateFrom: widget.filter.dateFrom,
                          dateTo: widget.filter.dateTo,
                          transactionTypes: _types,
                          statuses: _statuses,
                          errors: widget.filter.errors,
                          paymentSystemId: widget.filter.paymentSystemId,
                          search: widget.filter.search,
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.buttonColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Применить',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
