import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/auth/auth_service.dart';

class ApiSetupScreen extends ConsumerStatefulWidget {
  const ApiSetupScreen({super.key});

  @override
  ConsumerState<ApiSetupScreen> createState() => _ApiSetupScreenState();
}

class _ApiSetupScreenState extends ConsumerState<ApiSetupScreen> {
  final _clidController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _parkIdController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _clidController.dispose();
    _apiKeyController.dispose();
    _parkIdController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final clid = _clidController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final parkId = _parkIdController.text.trim();

    if (clid.isEmpty || apiKey.isEmpty || parkId.isEmpty) {
      setState(() {
        _error = 'Заполните все поля';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await ref
          .read(authServiceProvider)
          .login(clid: clid, apiKey: apiKey, parkId: parkId);

      if (success) {
        if (mounted) {
          context.go('/fleet');
        }
      } else {
        setState(() {
          _error = 'Ошибка входа. Проверьте данные.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Произошла ошибка при подключении';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
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

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const Spacer(),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Продолжить'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: AppTheme.bodyText,
          ),
        ),
      ],
    );
  }
}
