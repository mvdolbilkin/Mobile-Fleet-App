import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/providers/auth_provider.dart';

class MailingBottomSheet extends ConsumerStatefulWidget {
  final List<String> selectedContractorIds;

  const MailingBottomSheet({Key? key, required this.selectedContractorIds})
      : super(key: key);

  @override
  ConsumerState<MailingBottomSheet> createState() => _MailingBottomSheetState();
}

class _MailingBottomSheetState extends ConsumerState<MailingBottomSheet> {
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

      // Fetch blanks
      final blanksRes = await dio.get('/api/staff/mailings/blanks');
      if (blanksRes.data['empty_blank_name'] != null) {
        _blankName = blanksRes.data['empty_blank_name'];
      }

      // Fetch limit
      final limitsRes = await dio.get('/api/staff/mailings/limits');
      if (limitsRes.data['pro']?['restriction']?['max_message_length'] != null) {
        _maxMessageLength = limitsRes.data['pro']['restriction']['max_message_length'];
      }

      // Fetch count
      final countRes = await dio.post('/api/staff/contractors/count', data: {
        "filter": {
          "contractor_ids": widget.selectedContractorIds,
          "profile_exists": true
        }
      });
      if (countRes.data['count'] != null) {
        _contractorCount = countRes.data['count'];
      }

    } catch (e) {
      debugPrint("Mailing Data Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _sendMailing() async {
      // API call to send...
      debugPrint("Send clicked: Title: ${_titleController.text}, Text: ${_textController.text}");
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Новая рассылка',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_blankName),
          ),
          const SizedBox(height: 16),
          const Text('Текст', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Заголовок',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Formatting buttons placeholder
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
            maxLines: 5,
            maxLength: _maxMessageLength,
            decoration: InputDecoration(
              hintText: 'Введите текст',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Предпросмотр'),
              Switch(
                value: _isPreview,
                onChanged: (val) {
                  setState(() {
                    _isPreview = val;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _sendMailing,
              child: Text('Отправить ($_contractorCount)'),
            ),
          ),
        ],
      ),
    );
  }
}
