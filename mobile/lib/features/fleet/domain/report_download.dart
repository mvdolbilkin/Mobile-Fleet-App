enum ReportDownloadStatus {
  initiating,
  processing,
  ready,
  downloading,
  completed,
  failed,
}

class ReportDownload {
  final String operationId;
  final String reportType;
  final DateTime startedAt;
  final ReportDownloadStatus status;
  final String? fileName;
  final String? downloadUrl;
  final String? error;
  final Map<String, dynamic> filters;
  final DateTime dateFrom;
  final DateTime dateTo;
  final double? progress;

  const ReportDownload({
    required this.operationId,
    required this.reportType,
    required this.startedAt,
    required this.status,
    this.fileName,
    this.downloadUrl,
    this.error,
    required this.filters,
    required this.dateFrom,
    required this.dateTo,
    this.progress,
  });

  ReportDownload copyWith({
    String? operationId,
    String? reportType,
    DateTime? startedAt,
    ReportDownloadStatus? status,
    String? fileName,
    String? downloadUrl,
    String? error,
    Map<String, dynamic>? filters,
    DateTime? dateFrom,
    DateTime? dateTo,
    double? progress,
  }) {
    return ReportDownload(
      operationId: operationId ?? this.operationId,
      reportType: reportType ?? this.reportType,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      progress: progress ?? this.progress,
    );
  }

  String get formattedDateRange {
    final from = '${dateFrom.day.toString().padLeft(2, '0')}.${dateFrom.month.toString().padLeft(2, '0')}.${dateFrom.year}';
    final to = '${dateTo.day.toString().padLeft(2, '0')}.${dateTo.month.toString().padLeft(2, '0')}.${dateTo.year}';
    return '$from – $to';
  }

  String get displayName {
    switch (reportType) {
      case 'costs':
        return 'Отчет по расходам';
      default:
        return 'Отчет';
    }
  }

  bool get isActive => status == ReportDownloadStatus.initiating ||
      status == ReportDownloadStatus.processing ||
      status == ReportDownloadStatus.downloading;

  bool get canDownload => status == ReportDownloadStatus.ready ||
      status == ReportDownloadStatus.completed;

  // Можно удалить любой отчет в любом статусе
  bool get canRemove => true;
}
