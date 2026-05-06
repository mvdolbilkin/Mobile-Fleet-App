import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme.dart';
import 'app/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yandex_maps_mapkit/init.dart' as mapkit_init;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await mapkit_init.initMapkit(
    // apiKey: dotenv.env['MAPKIT_API_KEY'] ?? '',
    apiKey: '3b0e195b-f916-462c-b594-f5ab3ee564df',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flutter Base',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
