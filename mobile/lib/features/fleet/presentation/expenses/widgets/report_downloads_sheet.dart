import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/domain/report_download.dart';
import 'package:mobile/features/fleet/providers/report_downloads_provider.dart';
import 'package:mobile/shared/widgets/fading_button.dart';

class ReportDownloadsSheet extends ConsumerWidget {
  const ReportDownloadsSheet({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReportDownloadsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(reportDownloadsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Загрузки отчетов', style: AppTheme.listTitle),
                  Row(
                    children: [
                      if (downloads.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ref.read(reportDownloadsProvider.notifier).clearAll();
                          },
                          child: const Text(
                            'Очистить все',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: AppTheme.textSecondary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Downloads list
            if (downloads.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.download_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Нет загрузок',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Здесь будут отображаться ваши загрузки отчетов',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: downloads.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final download = downloads[index];
                    return _DownloadItem(download: download);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DownloadItem extends ConsumerWidget {
  final ReportDownload download;

  const _DownloadItem({required this.download});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      download.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      download.formattedDateRange,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              _StatusIcon(status: download.status),
            ],
          ),
          const SizedBox(height: 12),
          _StatusRow(download: download),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final ReportDownloadStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ReportDownloadStatus.initiating:
      case ReportDownloadStatus.processing:
      case ReportDownloadStatus.downloading:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case ReportDownloadStatus.ready:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.buttonColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.download_rounded,
            size: 18,
            color: AppTheme.buttonColor,
          ),
        );
      case ReportDownloadStatus.completed:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 18,
            color: Colors.green,
          ),
        );
      case ReportDownloadStatus.failed:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Colors.red,
          ),
        );
    }
  }
}

class _StatusRow extends ConsumerWidget {
  final ReportDownload download;

  const _StatusRow({required this.download});

  String _getStatusText() {
    switch (download.status) {
      case ReportDownloadStatus.initiating:
        return 'Создание отчета...';
      case ReportDownloadStatus.processing:
        return 'Обработка данных...';
      case ReportDownloadStatus.ready:
        return 'Готов к скачиванию';
      case ReportDownloadStatus.downloading:
        return 'Скачивание...';
      case ReportDownloadStatus.completed:
        return 'Скачан успешно';
      case ReportDownloadStatus.failed:
        return download.error ?? 'Ошибка';
    }
  }

  String _getButtonText() {
    if (download.status == ReportDownloadStatus.completed) {
      return 'Скачать снова';
    }
    return 'Скачать';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusText = _getStatusText();

    return Row(
      children: [
        Expanded(
          child: Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: download.status == ReportDownloadStatus.failed
                      ? Colors.red
                      : Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        if (download.canDownload)
          FadingButton(
            onTap: () async {
              final filePath = await ref
                  .read(reportDownloadsProvider.notifier)
                  .downloadFile(download.operationId);
              
              if (filePath != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Файл сохранен: ${download.fileName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.buttonColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getButtonText(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: Theme.of(context).colorScheme.outline,
          onPressed: () {
            ref
                .read(reportDownloadsProvider.notifier)
                .removeDownload(download.operationId);
          },
        ),
      ],
    );
  }
}
