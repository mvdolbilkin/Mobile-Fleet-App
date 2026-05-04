import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/api/dio_provider.dart';

class MailingActionBottomSheet extends ConsumerStatefulWidget {
  final int selectedCount;
  final List<String> selectedStaffIds;

  const MailingActionBottomSheet({
    super.key,
    required this.selectedCount,
    required this.selectedStaffIds,
  });

  static Future<bool?> show({
    required BuildContext context,
    required int selectedCount,
    required List<String> selectedStaffIds,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MailingActionBottomSheet(
          selectedCount: selectedCount,
          selectedStaffIds: selectedStaffIds,
        ),
      ),
    );
  }

  @override
  ConsumerState<MailingActionBottomSheet> createState() => _MailingActionBottomSheetState();
}

class _MailingActionBottomSheetState extends ConsumerState<MailingActionBottomSheet> {
  bool _isLoading = true;
  bool _isPreview = false;
  String _blankName = "Свой";
  int _contractorCount = 0;
  int _maxMessageLength = 1500;
  
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final dio = ref.read(dioProvider);

      // We parallelize to make it faster
      final futures = await Future.wait<dynamic>([
        dio.get('/api/staff/mailings/blanks'),
        dio.get('/api/staff/mailings/limits'),
        dio.post('/api/staff/contractors/count', data: {
          "filter": {
            "contractor_ids": widget.selectedStaffIds,
            "profile_exists": true
          }
        }),
      ]);

      final blanksData = futures[0].data;
      final limitsData = futures[1].data;
      final countData = futures[2].data;

      if (mounted) {
        setState(() {
          if (blanksData != null && blanksData['empty_blank_name'] != null) {
            _blankName = blanksData['empty_blank_name'];
          }
          if (limitsData != null && limitsData['pro']?['restriction']?['max_message_length'] != null) {
            _maxMessageLength = limitsData['pro']['restriction']['max_message_length'];
          }
          if (countData != null && countData['count'] != null) {
            _contractorCount = countData['count'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Mailing Data Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        height: 300,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Новая рассылка',
                style: TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _blankName,
              style: const TextStyle(
                fontFamily: 'Yandex Sans Text',
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Текст',
            style: TextStyle(
              fontFamily: 'Yandex Sans Text',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Заголовок',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.format_bold), onPressed: () {}),
              IconButton(icon: const Icon(Icons.format_italic), onPressed: () {}),
              IconButton(icon: const Icon(Icons.link), onPressed: () {}),
              IconButton(icon: const Icon(Icons.format_list_bulleted), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 6,
            maxLength: _maxMessageLength,
            decoration: InputDecoration(
              hintText: 'Введите текст',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Предпросмотр',
                  style: TextStyle(
                    fontFamily: 'Yandex Sans Text',
                    fontSize: 14,
                  ),
                ),
                Switch(
                  value: _isPreview,
                  activeThumbColor: AppTheme.buttonColor,
                  onChanged: (val) {
                    setState(() {
                      _isPreview = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.buttonColor,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                // Here we would call the Send Mailing API
                Navigator.pop(context, true);
              },
              child: Text(
                'Отправить ($_contractorCount)',
                style: const TextStyle(
                  fontFamily: 'Yandex Sans Text',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
