import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/mailings/data/mailings_repository.dart';
import 'package:mobile/features/mailings/widgets/mailing_list_item.dart';
import 'package:mobile/features/mailings/mailing_details_screen.dart';

class MailingsScreen extends ConsumerWidget {
  const MailingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mailingsAsync = ref.watch(mailingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Рассылки'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: mailingsAsync.when(
        data: (response) {
          if (response.mailings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет рассылок',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Yandex Sans Text',
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(mailingsProvider);
            },
            child: ListView.builder(
              itemCount: response.mailings.length,
              itemBuilder: (context, index) {
                final mailing = response.mailings[index];
                return MailingListItem(
                  mailing: mailing,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MailingDetailsScreen(
                          mailingId: mailing.id,
                          mailing: mailing,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки рассылок',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Yandex Sans Text',
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: 'Yandex Sans Text',
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(mailingsProvider);
                },
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
