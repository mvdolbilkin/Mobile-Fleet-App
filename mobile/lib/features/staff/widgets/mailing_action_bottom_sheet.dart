import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/api/dio_provider.dart';

import 'package:mobile/features/staff/data/staff_repository.dart';

class MailingActionBottomSheet extends ConsumerStatefulWidget {
  final int selectedCount;
  final List<String> selectedStaffIds;
  final String searchQuery;

  const MailingActionBottomSheet({
    super.key,
    required this.selectedCount,
    required this.selectedStaffIds,
    this.searchQuery = '',
  });

  static Future<bool?> show({
    required BuildContext context,
    required int selectedCount,
    required List<String> selectedStaffIds,
    String searchQuery = '',
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
          searchQuery: searchQuery,
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
  String _previousText = '';
  
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _fetchInitialData();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    // Проверка, что добавлен перенос строки
    if (text.length == _previousText.length + 1) {
      final selection = _textController.selection;
      if (selection.baseOffset > 0 && text.substring(selection.baseOffset - 1, selection.baseOffset) == '\n') {
        final beforeCursor = text.substring(0, selection.baseOffset - 1);
        final lines = beforeCursor.split('\n');
        if (lines.isNotEmpty) {
          final lastLine = lines.last;
          final match = RegExp(r'^(\d+)\.\s').firstMatch(lastLine);
          if (match != null) {
            // Если предыдущая строка была пустой с номером, можно её очистить при нажатии enter,
            // но пока реализуем просто автонумерацию
            if (lastLine.trim() == '${match.group(1)}.') {
              // Если строка содержала только номер, удаляем его
              final newText = text.substring(0, selection.baseOffset - 1 - lastLine.length) + '\n' + text.substring(selection.baseOffset);
               _textController.value = _textController.value.copyWith(
                 text: newText,
                 selection: TextSelection.collapsed(offset: selection.baseOffset - lastLine.length),
               );
               _previousText = _textController.text;
               return;
            }

            final num = int.tryParse(match.group(1)!) ?? 0;
            final insertion = '${num + 1}. ';
            final newText = text.substring(0, selection.baseOffset) + insertion + text.substring(selection.baseOffset);
            _textController.value = _textController.value.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: selection.baseOffset + insertion.length),
            );
            _previousText = _textController.text;
            return;
          }
        }
      }
    }
    _previousText = text;
  }

  void _insertFormatting(String prefix, [String? suffix]) {
    final text = _textController.text;
    final selection = _textController.selection;
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      _textController.text = text + prefix + (suffix ?? prefix);
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length - (suffix ?? prefix).length);
      return;
    }
    
    final start = selection.start;
    final end = selection.end;
    
    final selectedText = text.substring(start, end);
    final newText = text.substring(0, start) + prefix + selectedText + (suffix ?? prefix) + text.substring(end);
    
    _textController.text = newText;
    _textController.selection = TextSelection(
      baseOffset: start + prefix.length,
      extentOffset: start + prefix.length + selectedText.length,
    );
  }

  void _insertLink() {
    final text = _textController.text;
    final selection = _textController.selection;
    const linkTemplate = '[введите текст](вставьте ссылку)';
    
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      _textController.text = text + linkTemplate;
      _textController.selection = TextSelection(
        baseOffset: _textController.text.length - linkTemplate.length + 1,
        extentOffset: _textController.text.length - linkTemplate.length + 14,
      );
      return;
    }
    
    final start = selection.start;
    final end = selection.end;
    final newText = text.substring(0, start) + linkTemplate + text.substring(end);
    _textController.text = newText;
    _textController.selection = TextSelection(
      baseOffset: start + 1,
      extentOffset: start + 14,
    );
  }

  void _insertList() {
    final text = _textController.text;
    final selection = _textController.selection;
    
    final insertion = '1. ';
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      final prefix = text.isEmpty || text.endsWith('\n') ? '' : '\n';
      _textController.text = text + prefix + insertion;
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
      return;
    }
    
    final start = selection.start;
    // Find beginning of the line
    int lineStart = start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }
    
    final newText = text.substring(0, lineStart) + insertion + text.substring(lineStart);
    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(offset: selection.baseOffset + insertion.length);
  }

  Future<void> _fetchInitialData() async {
    try {
      final dio = ref.read(dioProvider);

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
              IconButton(
                icon: const Icon(Icons.format_bold),
                onPressed: () => _insertFormatting('**'),
              ),
              IconButton(
                icon: const Icon(Icons.format_italic),
                onPressed: () => _insertFormatting('_'),
              ),
              IconButton(
                icon: const Icon(Icons.link),
                onPressed: () => _insertLink(),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: () => _insertList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isPreview)
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MarkdownBody(
                data: _textController.text.isEmpty ? 'Нет текста для предпросмотра' : _textController.text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontFamily: 'Yandex Sans Text', fontSize: 16),
                ),
              ),
            )
          else
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
              onPressed: () async {
                if (_textController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите сообщение')),
                  );
                  return;
                }
                if (_titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Укажите тему')),
                  );
                  return;
                }
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  final data = {
                    "action": {
                      "communication_type": "pro", // or pass from selected tab if it can change
                      "title": _titleController.text.trim(),
                      "message": _textController.text.trim(),
                    },
                    "filters": {
                      if (widget.searchQuery.isNotEmpty) "text": widget.searchQuery,
                      if (widget.selectedStaffIds.isNotEmpty) "contractor_ids": widget.selectedStaffIds,
                      "profile_exists": true,
                    }
                  };
                  
                  await ref.read(staffRepositoryProvider).sendMailing(data);
                  
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop(); // close dialog
                    Navigator.of(context).pop(true); // close bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Рассылка успешно отправлена')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop(); // close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка отправки: $e')),
                    );
                  }
                }
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
