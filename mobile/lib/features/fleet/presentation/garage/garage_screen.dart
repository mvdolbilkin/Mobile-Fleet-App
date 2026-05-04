import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/fleet/data/garage_repository.dart';
import 'package:mobile/features/fleet/domain/posting.dart';
import 'package:mobile/features/fleet/presentation/garage/widgets/garage_filter_sheet.dart';
import 'package:mobile/features/fleet/providers/garage_providers.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/providers/logger_provider.dart';

const _carPlaceholderSvg = '''
<svg viewBox="0 0 306 135" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M303.43 70.7h-16.37a4 4 0 0 0-3.24 1.65l-5.16 7.14m6.66-22.37-27.16.8m-25.3-29.83c.75 2.57 2 7.02 3.12 11.78a829 829 0 0 1 2.74 11.92m61.69 2.93-5.5 2.08c.7 1.66 1.57 4.3 2.64 7.1 1.31 3.5 1.81 6.8 4.28 6.8m-165.9-50.06s.02-2.06.12-3.49q.12-1.91.86-3.69c.4-.92.85-1.81 6.13-8.37 1.35-1.66 2.54-2.36 4.24-2.56a252 252 0 0 1 27.41-1.33c11.7 0 20.87.59 27.82 1.33m-.47 17.87c.08-1.66.18-4.33.12-5.47-.07-1.2-.39-2.61-1.07-5.1-.89-3.24-1.17-3.84-1.24-5.29-.08-1.67.67-2.41 2.56-2.26 1.8.15 3.11.91 4.44 2.59 2.98 3.77 5.29 7.26 5.92 8.71q.88 1.85.92 3.89c.02 1-.11 3.17-.11 3.17m41.41 102.25h8.85M143.13 99.46c0 12.94-8.22 23.43-18.38 23.43m-27.69-14.91c1.64 6.67 5.92 11.66 10.5 13.53 2.04.88 4.24 1.35 6.47 1.38h8.91m46.82-14.82c2.47 8.45 8.4 14.29 15.3 14.29 6.93 0 12.85-5.94 15.32-14.38m-43.14 0c1.9 6.5 5.86 11.53 10.74 13.52a17 17 0 0 0 6.47 1.39h8.93c2.18-.01 4.34-.47 6.35-1.34m-162.7-13.84c2.1 9.27 8.57 14.65 15.16 14.65s12.82-5.19 15.2-14.59m-42.88-.06c1.82 7.65 5.98 11.94 10.54 13.8 2.04.88 4.24 1.35 6.46 1.38h8.9c2.17-.01 4.32-.46 6.32-1.33m120.9-94.8h-64.45m54.32 30.1-11.18.79M254.7 39.28l-1.88 6.05c-.97 3.12-1.5 5.91-5.21 6.13-15.62.93-51.82 3.13-76.26 4.6m-14.64-14.39c.2 1.27.54 3.2.8 5.06m-8.16 47.63c.21-8.27.4-18.65.28-22.6-.19-6.45-1.07-9.38-1.07-9.38s-2.24-2.26-2.32-4.9c.52-4.63 5.66-10.71 10.49-16.04 3.58-3.96 10.01-10.94 19.5-14.17 7.24-2.46 15.27-3.22 32.59-2.8 11.04.28 17.67 1.55 23.7 3.44 8 2.5 16.25 7.32 22.5 11.5 1.8 1.21 2.94 2.61 3.06 5.28.14 3.4.1 12.43-.15 13.61-.55 2.5-5 11.17-11.83 24.65a324 324 0 0 1-7.36 13.97 6.7 6.7 0 0 1-5.6 3.46l-89.75 2m59.92-48.2c.69 2.69 2.57 4.1 2.8 5.92.2 1.63.16 10.96-.1 19.95-.11 3.86-.32 8.4-.52 12.22M43 64.84s3.4-2.43 13.22-5.03c9.64-2.97 24.98-6 34.18-7.49m48.2-.53c-2.22 4.03-3.58 6.5-7.45 8.22-3.93 1.75-20.38 4.82-31.96 7.23m0 0-4.65 9.8s-25.38 4.03-36.4 5.56c-3.96.56-4.9.88-14.98.88H16.4c-2.29 0-3.57-.85-4.5-2.02a84 84 0 0 1-3.26-4.73m90.54-9.5-24.77 1.21c-15.65.78-31.62 1.58-34.32 1.94a7.6 7.6 0 0 0-4.13 1.7H29.1a3.9 3.9 0 0 0-3.31-2.03c-1.78-.09-5.71 0-10.8-.54a26 26 0 0 1-3.46-.6M5.4 91.16v9.02s1.04.68 2.4 1.46c1.03.59 1.95 1 3.33 1h48.68c8.26 0 24.35-2.31 24.35-2.31l4.56-9.54s-19.53 1.7-27.97 1.7H11.03c-.96 0-2.1-.3-3.73-.88-1.28-.47-2.64-.93-2.64-1.74v-4.04a11 11 0 0 1 4.14-8.9q.56-2.65 1.63-5.13c.87-2.05 1.46-3.55 2.79-4.54 3.39-2.47 8.74-4.95 16.16-7.58 15.17-5.4 27-5.74 32.13-8.08 4.38-2 11.19-8.46 23.39-15.66C100 27 110.67 23.87 119.86 22.25c6.41-1.12 16.83-1.88 25.67-1.88l55.11.03m-58.85 87.58h104.5c.23-2.86-.05-8.35 2-16.34 3.59-13.98 13.31-19.62 23.4-16.28 9.66 3.19 15.12 16.75 12.4 30.97 3.18-.3 4.8-.5 9.76-1.36q2.08-.37 4.18-.91c2.07-.53 4.28-2.46 6-6.46 1.43-3.34 1.77-5.77 1.93-9.46.09-2.08.13-7.61.13-7.61q.04-1.96-.52-3.86c-.78-2.62-2.1-6-2.1-6q-.3-4.96-1.26-9.83c-.94-4.44-1.7-6.56-2.94-9a5.9 5.9 0 0 0-4.36-3.16l-10.03-1.58c-2.55-.4-5-1.28-7.21-2.6-8.48-4.94-29.51-16.9-43.52-20.5a95 95 0 0 0-15.74-2.86c-8.45-.83-14.47-.78-19.3-.76-10.42.03-16.53.98-22.55 2.9-10.91 3.5-15.63 8.15-20.94 13.06-3.53 3.28-7.42 7.76-10.78 11.15a15.4 15.4 0 0 1-11.75 4.88H59.25M67.5 69.1 55.8 82.95M15.7 70.3v12.65M5.04 99.99c-1.64 1.4-1.44 1.82-1.44 2.16 0 .46 1.43 1.74 3.71 3.23 2.76 1.81 4.09 2.17 7.03 2.17h89.47c.28-4.87 0-8.28 2.48-17.04 3.7-13.04 12.34-18.6 21.63-16.83 9.42 1.8 15.12 11.5 15.2 25.54.03 5.3-.63 8.76-.63 8.76M1.2 122.89h304.38M1.2 134.87h304.37m-20.78-35.41c.07 12.74-7.89 23.43-18.04 23.43m-27.69-14.91c1.64 6.67 5.92 11.66 10.5 13.53 2.04.88 4.24 1.35 6.47 1.38m2.66-30.37c1.04-2.34 2.57-4.13 4.37-5.05l1.22 9.32zm10-5.05-1.21 9.32 5.6-4.15c-1.03-2.42-2.57-4.25-4.39-5.17m-9.9 18.9a17 17 0 0 1-1.43-6.91l6.13 1.01zm10.29 4.81-3.14-8.53-3.25 8.5a6.7 6.7 0 0 0 6.39.03m5.32-11.72c.02 2.38-.47 4.74-1.44 6.92l-4.68-5.93zm-149.78 17.3c-6.99 0-12.65-7.8-12.65-17.43s5.66-17.45 12.65-17.45 12.65 7.81 12.65 17.45-5.65 17.44-12.65 17.44m-6.8-24.24c1-2.34 2.46-4.13 4.17-5.05l1.17 9.32zm9.54-5.05-1.28 9.32 5.86-4.15c-1.06-2.42-2.68-4.26-4.58-5.17m-9.69 18.9a17 17 0 0 1-1.44-6.91l6.13 1.01zm10.01 4.81-3-8.53-3.12 8.5a6.2 6.2 0 0 0 6.11.03zm5.6-11.72c.02 2.38-.5 4.75-1.52 6.92l-4.88-5.93zm39.9-46.03c-.8 2.29-2.34 3.4-5.4 3.4l-11.85.02c-.8 0-1.58-.52-1.7-1.3-.19-1.12-.18-2.63-.19-3.85 0-2.23 2.56-4.76 4.8-5.38 2.7-.75 14.16 2.18 14.86 3.85.17.45-.13 2.18-.51 3.26m28.8-29.06s2.34 7.79 3.66 14.14 2.6 15.21 2.45 15.16-8.26.52-8.26.52-.46-10.46-1.15-15.2c-.77-5.25-2.3-14.5-2.3-14.5zM46.2 83.47H20.37v8.8H46.2zm219.55 33.3c-6.99 0-12.65-7.82-12.65-17.44s5.66-17.45 12.65-17.45 12.64 7.81 12.64 17.45-5.64 17.44-12.64 17.44" stroke="rgba(138, 135, 132, 0.4)" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  List<Posting> _postings = [];
  int _total = 0;
  String? _cursor;
  GarageFilter _filter = GarageFilter.empty;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPostings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _cursor != null &&
        _postings.length < _total) {
      _loadMore();
    }
  }

  Future<void> _loadPostings() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _postings = [];
      _cursor = null;
    });

    try {
      final secureStorage = ref.read(secureStorageServiceProvider);
      final parkId = await secureStorage.getParkId();

      if (parkId == null || parkId.isEmpty) {
        setState(() {
          _error = 'Park ID не найден. Пожалуйста, авторизуйтесь заново.';
          _isLoading = false;
        });
        return;
      }

      final repository = ref.read(garageRepositoryProvider);
      final result = await repository.getPostingsList(
        parkId: parkId,
        query: _filter.toQuery(),
      );

      setState(() {
        _postings = result.postings;
        _total = result.total;
        _cursor = result.cursor;
        _isLoading = false;
      });

      ref.read(loggerProvider).i('✅ Loaded ${result.postings.length} postings, total: ${result.total}');
    } catch (e) {
      ref.read(loggerProvider).e('❌ Failed to load postings: $e');
      setState(() {
        _error = 'Не удалось загрузить данные: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _cursor == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final secureStorage = ref.read(secureStorageServiceProvider);
      final parkId = await secureStorage.getParkId();
      if (parkId == null) {
        setState(() => _isLoadingMore = false);
        return;
      }

      final repository = ref.read(garageRepositoryProvider);
      final result = await repository.getPostingsList(
        parkId: parkId,
        cursor: _cursor,
        query: _filter.toQuery(),
      );

      setState(() {
        _postings.addAll(result.postings);
        _cursor = result.cursor;
        _isLoadingMore = false;
      });
    } catch (e) {
      ref.read(loggerProvider).e('❌ Failed to load more postings: $e');
      setState(() => _isLoadingMore = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'posted':
        return AppTheme.statusGreen;
      case 'not_posted':
        return AppTheme.textSecondary;
      case 'without_rent_rule':
        return AppTheme.statusOrange;
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _buildStatusBadge(Posting posting) {
    final color = _statusColor(posting.status);
    final isWarning = posting.status == 'without_rent_rule';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            posting.statusLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
          if (isWarning) ...[
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 14, color: Colors.white),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.controlsColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
              fontFamily: 'Yandex Sans Text',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostingCard(Posting posting) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _buildStatusBadge(posting),
          ),
          // Car image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: posting.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      posting.images.first,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                    ),
                  )
                : _buildPlaceholderImage(),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              posting.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Yandex Sans Text',
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          // Chips row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildChip(Icons.settings, posting.transmission.label),
                _buildChip(Icons.local_gas_station, posting.fuelType.label),
                _buildChip(Icons.directions_car, posting.availabilityText),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Address
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    posting.office.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontFamily: 'Yandex Sans Text',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Button
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
              ),
              child: const Text(
                'Заполнить',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Yandex Sans Text',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Center(
        child: SvgPicture.string(
          _carPlaceholderSvg,
          width: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(garageOfficesProvider);
    ref.watch(garageCarsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Гараж'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Filters row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await GarageFilterSheet.show(
                      context: context,
                      initialFilter: _filter,
                    );
                    if (result != null) {
                      setState(() => _filter = result);
                      _loadPostings();
                    }
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: _filter.isModified
                          ? AppTheme.buttonColor
                          : AppTheme.controlsColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                if (_filter.isModified)
                  GestureDetector(
                    onTap: () {
                      setState(() => _filter = GarageFilter.empty);
                      _loadPostings();
                    },
                    child: Text(
                      'Сбросить фильтры',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  'Всего: $_total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontFamily: 'Yandex Sans Text',
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadPostings,
                                child: const Text('Повторить'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _postings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/garage-no-data.png',
                                  width: 200,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Нет объявлений',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Попробуйте изменить фильтры',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            itemCount: _postings.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _postings.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildPostingCard(_postings[index]),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
