// lib/providers/logger_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    level: kDebugMode ? Level.trace : Level.off,
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
  );
});
