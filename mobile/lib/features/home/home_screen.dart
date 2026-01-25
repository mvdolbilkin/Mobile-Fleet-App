import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mobile/shared/providers/logger_provider.dart';
import '../../shared/api/dio_provider.dart';

final postProvider = FutureProvider.autoDispose<String>((ref) async {
  final dio = ref.watch(dioProvider);

  final logger = ref.watch(loggerProvider);
  final response = await dio.get('test');
  logger.t('Response: $response');
  return response.data['status'] as String;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Базовый проект')),
      body: Center(
        child: postAsync.when(
          data: (title) => Text(
            'Данные с сервера:\n$title',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
          error: (err, stack) => Text('Ошибка: $err'),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.refresh(postProvider);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
