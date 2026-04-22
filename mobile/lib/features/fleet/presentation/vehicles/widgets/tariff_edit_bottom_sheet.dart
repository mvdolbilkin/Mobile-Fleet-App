import 'package:flutter/material.dart';
import '../../../domain/tariff_utils.dart';
import '../../../../../shared/widgets/custom_switch.dart';
import '../../../../../shared/widgets/fading_button.dart';
import '../../../../../app/theme.dart';

class TariffEditBottomSheet extends StatefulWidget {
  final List<String>? currentTariffs;
  final Function(List<String>) onSave;

  const TariffEditBottomSheet({
    super.key,
    this.currentTariffs,
    required this.onSave,
  });

  @override
  State<TariffEditBottomSheet> createState() => _TariffEditBottomSheetState();
}

class _TariffEditBottomSheetState extends State<TariffEditBottomSheet> {
  late Map<String, bool> _tariffStates;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Инициализируем состояния тарифов
    _tariffStates = {};
    for (var key in TariffUtils.tariffNames.keys) {
      _tariffStates[key] = widget.currentTariffs?.contains(key) ?? false;
    }
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedTariffs = _tariffStates.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      await widget.onSave(selectedTariffs);
      
      // Если успешно - закрываем sheet
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Если ошибка - оставляем sheet открытым
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Редактировать тарифы',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Spacer to center the title
              ],
            ),
          ),
          const Divider(height: 1),
          // Список тарифов
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: TariffUtils.tariffNames.length,
              itemBuilder: (context, index) {
                final key = TariffUtils.tariffNames.keys.elementAt(index);
                final name = TariffUtils.tariffNames[key]!;
                return _buildTariffItem(key, name);
              },
            ),
          ),
          // Кнопка сохранить
          _buildSaveButton(context),
        ],
      ),
    );
  }

  Widget _buildTariffItem(String key, String name) {
    final iconPath = TariffUtils.tariffIcons[key] ?? 'assets/images/TariffEditSheet/fallback-9U2fbpSe.png';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 1, 16, 1),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 56,
            height: 56,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.local_taxi, size: 38),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'YSText-Regular',
              ),
            ),
          ),
          CustomSwitch(
            value: _tariffStates[key] ?? false,
            onChanged: (value) {
              setState(() {
                _tariffStates[key] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: FadingButton(
        onTap: _isLoading ? null : _handleSave,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isLoading ? AppTheme.buttonColor.withOpacity(0.6) : AppTheme.buttonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 20,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Text(
                      'Сохранить',
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
      ),
    );
  }
}
