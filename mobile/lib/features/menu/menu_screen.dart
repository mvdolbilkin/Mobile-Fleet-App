import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/widgets/cars_card.dart';
import 'package:mobile/features/menu/widgets/executors_card.dart';
import 'package:mobile/features/menu/widgets/loyalty_program_card.dart';
import 'package:mobile/features/menu/widgets/problems_card.dart';
import 'package:mobile/features/menu/widgets/date_range_selector.dart';
import 'package:mobile/features/auth/auth_service.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  'Дополнительно',
                  style: TextStyle(
                    fontFamily: 'Yandex Sans Text',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppTheme.borderColor),
              ListTile(
                leading: const Icon(Icons.home_outlined, color: AppTheme.textPrimary),
                title: const Text(
                  'Главная',
                  style: TextStyle(fontFamily: 'Yandex Sans Text', fontSize: 16, color: AppTheme.textPrimary),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.analytics_outlined, color: AppTheme.textPrimary),
                title: const Text(
                  'Сводка',
                  style: TextStyle(fontFamily: 'Yandex Sans Text', fontSize: 16, color: AppTheme.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/menu/summary');
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: AppTheme.textPrimary),
                title: const Text(
                  'Цели',
                  style: TextStyle(fontFamily: 'Yandex Sans Text', fontSize: 16, color: AppTheme.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/menu/goals');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppTheme.textPrimary),
                title: const Text(
                  'Профиль партнера',
                  style: TextStyle(fontFamily: 'Yandex Sans Text', fontSize: 16, color: AppTheme.textPrimary),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: SvgPicture.asset(
              'assets/images/menu.svg',
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Главная'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const DateRangeSelector(),
              const ExecutorsCard(),
              const SizedBox(height: 16),
              const CarsCard(),
              const SizedBox(height: 16),
              const LoyaltyProgramCard(),
              const SizedBox(height: 16),
              const ProblemsCard(),
              const SizedBox(height: 16),
              // Кнопка выхода
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _handleLogout(context, ref),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Выйти из аккаунта',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Удалить сессию и ключи',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.red.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.red.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
