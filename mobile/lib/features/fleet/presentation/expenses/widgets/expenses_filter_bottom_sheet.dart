import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/widgets/custom_date_range_picker_bottom_sheet.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class ExpensesFilter {
  final DateTime dateFrom;
  final DateTime dateTo;

  const ExpensesFilter({required this.dateFrom, required this.dateTo});

  static ExpensesFilter get defaultFilter => ExpensesFilter(
        dateFrom: DateTime(2024, 11, 1),
        dateTo: DateTime(2026, 6, 30),
      );
}

class ExpensesFilterBottomSheet extends StatefulWidget {
  final ExpensesFilter initialFilter;

  const ExpensesFilterBottomSheet({Key? key, required this.initialFilter})
      : super(key: key);

  static Future<ExpensesFilter?> show({
    required BuildContext context,
    required ExpensesFilter initialFilter,
  }) {
    return showModalBottomSheet<ExpensesFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ExpensesFilterBottomSheet(initialFilter: initialFilter),
    );
  }

  @override
  State<ExpensesFilterBottomSheet> createState() =>
      _ExpensesFilterBottomSheetState();
}

class _ExpensesFilterBottomSheetState
    extends State<ExpensesFilterBottomSheet> {
  late DateTime _dateFrom;
  late DateTime _dateTo;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialFilter.dateFrom;
    _dateTo = widget.initialFilter.dateTo;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppTheme.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Фильтры', style: AppTheme.listTitle),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppTheme.textSecondary, size: 24),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Период',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () async {
                final range = await CustomDateRangePickerBottomSheet.show(
                  context: context,
                  title: 'Выберите период',
                  startDate: _dateFrom,
                  endDate: _dateTo,
                );
                if (range != null) {
                  setState(() {
                    _dateFrom = range.start;
                    _dateTo = range.end;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 20, color: AppTheme.textPrimary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_formatDate(_dateFrom)} — ${_formatDate(_dateTo)}',
                        style: const TextStyle(
                            fontSize: 16, color: AppTheme.textPrimary),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_right,
                        color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FadingButton(
                onTap: () => Navigator.pop(
                  context,
                  ExpensesFilter(dateFrom: _dateFrom, dateTo: _dateTo),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Применить',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
}
