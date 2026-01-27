import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme.dart';

class ApiSetupScreen extends StatefulWidget {
  const ApiSetupScreen({super.key});

  @override
  State<ApiSetupScreen> createState() => _ApiSetupScreenState();
}

class _ApiSetupScreenState extends State<ApiSetupScreen> {
  final _clidController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _parkIdController = TextEditingController();

  @override
  void dispose() {
    _clidController.dispose();
    _apiKeyController.dispose();
    _parkIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Настройка доступа',
                style: AppTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Введите данные для подключения к API вашего таксопарка',
                style: AppTheme.bodyText,
              ),
              const SizedBox(height: 32),
              
              _buildTextField(
                controller: _clidController,
                label: 'Clid',
                hint: 'Введите CLID парка',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _apiKeyController,
                label: 'API-ключ',
                hint: 'Введите API-ключ',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _parkIdController,
                label: 'ID парка',
                hint: 'Введите ID парка',
              ),
              
              const Spacer(),
              
              ElevatedButton(
                onPressed: () {
                  // Здесь будет логика сохранения и валидации
                  context.go('/fleet');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buttonColor,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  fixedSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
                child: const Text('Продолжить'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
            fontFamily: 'Yandex Sans Text',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.searchHint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: AppTheme.bodyText,
          ),
        ),
      ],
    );
  }
}
