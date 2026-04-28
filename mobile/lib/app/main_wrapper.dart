import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/report_download.dart';
import 'package:mobile/features/fleet/providers/report_downloads_provider.dart';
import 'package:mobile/features/fleet/presentation/expenses/widgets/report_downloads_sheet.dart';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Widget _buildTabItem(String path, String label, Color color) {
    final double iconSize = 28.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          path,
          fit: BoxFit.contain,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            fontFamily: 'Yandex Sans Text',
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Global listener for report downloads
    ref.listen<List<ReportDownload>>(
      reportDownloadsProvider,
      (previous, current) {
        // Check for newly ready downloads
        for (final download in current) {
          final wasReady = previous?.any(
                (p) => p.operationId == download.operationId &&
                       p.status == ReportDownloadStatus.ready,
              ) ?? false;

          if (download.status == ReportDownloadStatus.ready && !wasReady) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Отчет "${download.displayName}" готов к скачиванию'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Открыть',
                  textColor: Colors.white,
                  onPressed: () {
                    ReportDownloadsSheet.show(context);
                  },
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      },
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: NavigationBar(
            height: 60,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            destinations: [
              NavigationDestination(
                icon: _buildTabItem('assets/images/autopark.svg', 'Автопарк', AppTheme.textSecondary),
                selectedIcon: _buildTabItem('assets/images/autopark.svg', 'Автопарк', Colors.black),
                label: 'Автопарк',
              ),
              NavigationDestination(
                icon: _buildTabItem('assets/images/personal.svg', 'Персонал', AppTheme.textSecondary),
                selectedIcon: _buildTabItem('assets/images/personal.svg', 'Персонал', Colors.black),
                label: 'Персонал',
              ),
              NavigationDestination(
                icon: _buildTabItem('assets/images/map.svg', 'Карта', AppTheme.textSecondary),
                selectedIcon: _buildTabItem('assets/images/map.svg', 'Карта', Colors.black),
                label: 'Карта',
              ),
              NavigationDestination(
                icon: _buildTabItem('assets/images/analytics.svg', 'Аналитика', AppTheme.textSecondary),
                selectedIcon: _buildTabItem('assets/images/analytics.svg', 'Аналитика', Colors.black),
                label: 'Аналитика',
              ),
              NavigationDestination(
                icon: _buildTabItem('assets/images/menu.svg', 'Меню', AppTheme.textSecondary),
                selectedIcon: _buildTabItem('assets/images/menu.svg', 'Меню', Colors.black),
                label: 'Меню',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
