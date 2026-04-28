import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/data/expenses_repository.dart';
import 'package:mobile/features/fleet/domain/expense.dart';
import 'package:mobile/features/fleet/presentation/expenses/expenses_screen.dart' show expenseTypeIcons, svgOther;
import 'package:mobile/features/fleet/presentation/expenses/widgets/add_expense_sheet.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

String _formatIsoDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final dt = DateTime.parse(iso);
    const months = [
      'янв.', 'фев.', 'мар.', 'апр.', 'мая', 'июн.',
      'июл.', 'авг.', 'сен.', 'окт.', 'ноя.', 'дек.',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso;
  }
}

Future<bool?> showExpenseDetailsSheet(BuildContext context, Expense expense) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ExpenseDetailsSheet(expense: expense),
  );
}

class _ExpenseDetailsSheet extends ConsumerStatefulWidget {
  final Expense expense;
  const _ExpenseDetailsSheet({required this.expense});

  @override
  ConsumerState<_ExpenseDetailsSheet> createState() => _ExpenseDetailsSheetState();
}

class _ExpenseDetailsSheetState extends ConsumerState<_ExpenseDetailsSheet> {
  Expense? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final parkId = await ref.read(secureStorageServiceProvider).getParkId();
      if (parkId == null || !mounted) return;
      final data = await ref.read(expensesRepositoryProvider).getCostDetail(
        parkId: parkId,
        costId: widget.expense.id,
      );
      if (mounted) {
        setState(() {
          _detail = Expense.fromYandexApi(data);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = _detail ?? widget.expense;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              Text(
                e.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                    final e = _detail ?? widget.expense;
                    final result = await showAddExpenseSheet(
                      context,
                      costTypes: [],
                      cars: [],
                      expense: e,
                    );
                    if (result == true && mounted) {
                      Navigator.of(context).pop(true);
                    }
                  }),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${e.amount} ₽',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: e.isDeleted ? Theme.of(context).colorScheme.outline : null,
                decoration: e.isDeleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.only(top: 32),
              child: CircularProgressIndicator(),
            ))
          else ...[
            _buildDetailRow(context, 'Автомобиль', '${e.car.number} ${e.car.details}'),
            _buildDetailRow(
              context, 'Тип', e.type.name,
              icon: SvgPicture.string(
                expenseTypeIcons[e.type.id] ?? svgOther,
                width: 20, height: 20,
                colorFilter: const ColorFilter.mode(AppTheme.textPrimary, BlendMode.srcIn),
              ),
            ),
            _buildDetailRow(context, 'Дата оплаты', _formatIsoDate(e.paidAt)),
            _buildDetailRow(
              context, 'Создано',
              e.createdByUserName.isNotEmpty
                  ? '${e.createdByUserName}, ${_formatIsoDate(e.createdAt)}'
                  : _formatIsoDate(e.createdAt),
            ),
            if (e.editedByUserName != null && e.editedByUserName!.isNotEmpty || e.editedAt != null)
              _buildDetailRow(
                context, 'Отредактировано',
                e.editedByUserName != null && e.editedByUserName!.isNotEmpty
                    ? '${e.editedByUserName}, ${_formatIsoDate(e.editedAt)}'
                    : _formatIsoDate(e.editedAt),
              ),
          ],
        ],
      ),
    );
  }
}

Widget _buildDetailRow(BuildContext context, String label, String value, {Widget? icon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
