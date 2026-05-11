import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/fleet/domain/report_download.dart';
import 'package:mobile/features/fleet/data/expenses_repository.dart';
import 'package:mobile/features/fleet/presentation/regular_charges/regular_charges_repository.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/providers/logger_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/legacy.dart';

final reportDownloadsProvider =
    StateNotifierProvider<ReportDownloadsNotifier, List<ReportDownload>>((ref) {
  return ReportDownloadsNotifier(ref);
});

class ReportDownloadsNotifier extends StateNotifier<List<ReportDownload>> {
  final Ref ref;
  final Map<String, Timer> _pollingTimers = {};
  final Map<String, int> _pollingAttempts = {};
  static const int maxPollingAttempts = 100; // 5 minutes at 3s intervals
  static const Duration pollingInterval = Duration(seconds: 3);

  ReportDownloadsNotifier(this.ref) : super([]);

  @override
  void dispose() {
    // Cancel all timers
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();
    super.dispose();
  }

  /// Start a new report download
  Future<void> startReportDownload({
    required String reportType,
    required Map<String, dynamic> filters,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final operationId = const Uuid().v4().replaceAll('-', '');
    final logger = ref.read(loggerProvider);

    logger.i('🚀 Starting report download: $reportType, operation: $operationId');

    final download = ReportDownload(
      operationId: operationId,
      reportType: reportType,
      startedAt: DateTime.now(),
      status: ReportDownloadStatus.initiating,
      filters: filters,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    state = [...state, download];

    try {
      final parkId = await ref.read(secureStorageServiceProvider).getParkId();
      if (parkId == null) {
        throw Exception('Park ID not found');
      }

      // Initiate report generation based on type
      if (reportType == 'regular_charges') {
        final regularChargesRepo = ref.read(regularChargesRepositoryProvider);
        await regularChargesRepo.initiateReportGeneration(
          parkId: parkId,
          operationId: operationId,
          dateType: filters['date_type'] as String? ?? 'date_from',
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
      } else {
        final repository = ref.read(expensesRepositoryProvider);
        await repository.initiateReportGeneration(
          parkId: parkId,
          operationId: operationId,
          reportType: reportType,
          filters: filters,
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
      }

      logger.i('✅ Report generation initiated: $operationId');

      // Update status to processing
      _updateDownload(
        operationId,
        download.copyWith(status: ReportDownloadStatus.processing),
      );

      // Start polling
      _startPolling(operationId);
    } catch (e, stackTrace) {
      logger.e('❌ Failed to initiate report: $e');
      logger.e('Stack trace: $stackTrace');
      _updateDownload(
        operationId,
        download.copyWith(
          status: ReportDownloadStatus.failed,
          error: 'Не удалось создать отчет: $e',
        ),
      );
    }
  }

  /// Start polling for report status
  void _startPolling(String operationId) {
    final logger = ref.read(loggerProvider);
    _pollingAttempts[operationId] = 0;

    _pollingTimers[operationId] = Timer.periodic(pollingInterval, (timer) async {
      final attempts = _pollingAttempts[operationId] ?? 0;

      if (attempts >= maxPollingAttempts) {
        logger.w('⏱️ Polling timeout for operation: $operationId');
        timer.cancel();
        _pollingTimers.remove(operationId);
        _pollingAttempts.remove(operationId);

        final download = state.firstWhere((d) => d.operationId == operationId);
        _updateDownload(
          operationId,
          download.copyWith(
            status: ReportDownloadStatus.failed,
            error: 'Превышено время ожидания создания отчета',
          ),
        );
        return;
      }

      _pollingAttempts[operationId] = attempts + 1;
      await _checkStatus(operationId);
    });
  }

  /// Check report status
  Future<void> _checkStatus(String operationId) async {
    final logger = ref.read(loggerProvider);

    try {
      final parkId = await ref.read(secureStorageServiceProvider).getParkId();
      if (parkId == null) return;

      final repository = ref.read(expensesRepositoryProvider);
      final statusData = await repository.checkReportStatus(
        parkId: parkId,
        operationId: operationId,
      );

      final status = statusData['status'] as String?;
      logger.d('📊 Report status for $operationId: $status');

      if (status == 'uploaded') {
        // Stop polling
        _pollingTimers[operationId]?.cancel();
        _pollingTimers.remove(operationId);
        _pollingAttempts.remove(operationId);

        // Get download link
        final downloadData = await repository.getReportDownloadLink(
          parkId: parkId,
          operationId: operationId,
        );

        final fileName = downloadData['file_name'] as String?;
        final link = downloadData['link'] as String?;

        logger.i('✅ Report ready: $operationId, file: $fileName');

        final download = state.firstWhere((d) => d.operationId == operationId);
        _updateDownload(
          operationId,
          download.copyWith(
            status: ReportDownloadStatus.ready,
            fileName: fileName,
            downloadUrl: link,
          ),
        );
      } else if (status == 'failed') {
        _pollingTimers[operationId]?.cancel();
        _pollingTimers.remove(operationId);
        _pollingAttempts.remove(operationId);

        final download = state.firstWhere((d) => d.operationId == operationId);
        _updateDownload(
          operationId,
          download.copyWith(
            status: ReportDownloadStatus.failed,
            error: 'Ошибка при создании отчета',
          ),
        );
      }
    } catch (e) {
      logger.e('❌ Failed to check status for $operationId: $e');
      // Don't fail the download, just continue polling
    }
  }

  /// Download file to device
  Future<String?> downloadFile(String operationId) async {
    final logger = ref.read(loggerProvider);
    final download = state.firstWhere((d) => d.operationId == operationId);

    if (download.downloadUrl == null) {
      logger.e('❌ No download URL for operation: $operationId');
      return null;
    }

    try {
      logger.i('📥 Starting file download: ${download.fileName}');

      _updateDownload(
        operationId,
        download.copyWith(status: ReportDownloadStatus.downloading),
      );

      final repository = ref.read(expensesRepositoryProvider);
      final filePath = await repository.downloadReportFile(
        url: download.downloadUrl!,
        fileName: download.fileName ?? 'report.csv',
      );

      logger.i('✅ File downloaded: $filePath');

      _updateDownload(
        operationId,
        download.copyWith(status: ReportDownloadStatus.completed),
      );

      return filePath;
    } catch (e, stackTrace) {
      logger.e('❌ Failed to download file: $e');
      logger.e('Stack trace: $stackTrace');

      _updateDownload(
        operationId,
        download.copyWith(
          status: ReportDownloadStatus.failed,
          error: 'Не удалось скачать файл: $e',
        ),
      );

      return null;
    }
  }

  /// Remove download from list
  void removeDownload(String operationId) {
    final logger = ref.read(loggerProvider);
    logger.i('🗑️ Removing download: $operationId');

    _pollingTimers[operationId]?.cancel();
    _pollingTimers.remove(operationId);
    _pollingAttempts.remove(operationId);

    state = state.where((d) => d.operationId != operationId).toList();
  }

  /// Clear all downloads
  void clearAll() {
    final logger = ref.read(loggerProvider);
    logger.i('🧹 Clearing all downloads');

    // Cancel all timers
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();
    _pollingAttempts.clear();

    // Clear all downloads
    state = [];
  }

  /// Update a specific download
  void _updateDownload(String operationId, ReportDownload updatedDownload) {
    state = state.map((d) {
      if (d.operationId == operationId) {
        return updatedDownload;
      }
      return d;
    }).toList();
  }

  /// Get active downloads count
  int get activeDownloadsCount {
    return state.where((d) => d.isActive).length;
  }

  /// Get ready downloads count
  int get readyDownloadsCount {
    return state.where((d) => d.canDownload).length;
  }
}
