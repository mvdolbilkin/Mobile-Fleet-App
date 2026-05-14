import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mobile/features/auth/auth_service.dart';
import 'package:mobile/shared/providers/logger_provider.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/api/dio_provider.dart';

class YandexWebViewLoginScreen extends ConsumerStatefulWidget {
  const YandexWebViewLoginScreen({super.key});

  @override
  ConsumerState<YandexWebViewLoginScreen> createState() =>
      _YandexWebViewLoginScreenState();
}

class _YandexWebViewLoginScreenState
    extends ConsumerState<YandexWebViewLoginScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String _currentUrl = '';
  bool _isProcessing = false;
  double _progress = 0;
  bool _cookiesCleared = false;
  DateTime? _pageLoadStartTime;
  static const _loginTimeout = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _clearCookiesBeforeLoad();
  }

  Future<void> _clearCookiesBeforeLoad() async {
    try {
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();

      try {
        await WebStorageManager.instance().android.deleteAllData();
      } catch (_) {}

      ref.read(loggerProvider).i('Cookies & cache cleared before login');
    } catch (e) {
      ref.read(loggerProvider).e('Failed to clear cookies before login: $e');
    }
    if (mounted) {
      setState(() {
        _cookiesCleared = true;
      });
    }
  }

  void _startLoginTimer() {
    _pageLoadStartTime = DateTime.now();
  }

  bool _isLoginTimedOut() {
    if (_pageLoadStartTime == null) return false;
    return DateTime.now().difference(_pageLoadStartTime!) > _loginTimeout;
  }

  Future<void> _handleTimeout() async {
    if (!mounted || _isProcessing) return;
    ref.read(loggerProvider).w('Login timed out — clearing cookies and reloading');

    final cookieManager = CookieManager.instance();
    await cookieManager.deleteAllCookies();

    _pageLoadStartTime = null;
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri('https://fleet.yandex.ru')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход в Яндекс'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_progress < 1.0)
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[200],
                ),
              // Подсказка для пользователя (скрывается когда park_id появляется в URL)
              if (_currentUrl.contains('fleet.yandex.ru') &&
                  !_currentUrl.contains('/parks/') &&
                  !_currentUrl.contains('park_id=') &&
                  !_isProcessing)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.shade50,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ожидание загрузки парка...',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: !_cookiesCleared
                    ? const Center(child: CircularProgressIndicator())
                    : InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri('https://fleet.yandex.ru'),
                  ),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    thirdPartyCookiesEnabled: true,
                    useOnLoadResource: true,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      _currentUrl = url.toString();
                      _isLoading = true;
                    });
                    _pageLoadStartTime ??= DateTime.now();
                    ref.read(loggerProvider).i('Page started loading: $url');
                  },
                  onLoadStop: (controller, url) async {
                    setState(() {
                      _isLoading = false;
                    });
                    ref.read(loggerProvider).i('Page finished loading: $url');

                    // Проверяем только когда пользователь реально залогинился
                    // (URL содержит /parks/ или park_id)
                    final urlStr = url.toString();
                    if (urlStr.contains('fleet.yandex.ru') &&
                        (urlStr.contains('/parks/') || urlStr.contains('park_id=')) &&
                        !_isProcessing) {
                      await _checkAndSaveCookies(urlStr);
                    }
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      _progress = progress / 100;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) async {
                    // Этот callback срабатывает при изменении URL (включая изменения через JavaScript)
                    if (url != null) {
                      setState(() {
                        _currentUrl = url.toString();
                      });
                      ref.read(loggerProvider).i('URL updated: $url');

                      // Проверяем cookies только после логина (URL содержит /parks/ или park_id)
                      final urlStr = url.toString();
                      if (urlStr.contains('fleet.yandex.ru') &&
                          (urlStr.contains('/parks/') || urlStr.contains('park_id=')) &&
                          !_isProcessing) {
                        await _checkAndSaveCookies(urlStr);
                      }
                    }
                  },
                  onLoadError: (controller, url, code, message) {
                    ref.read(loggerProvider).e('WebView error: $message');
                  },
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Сохранение данных...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _checkAndSaveCookies(String url) async {
    if (_isProcessing || _webViewController == null) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      // Получаем все cookies через InAppWebView CookieManager
      final cookieManager = CookieManager.instance();
      final cookies = await cookieManager.getCookies(
        url: WebUri('https://fleet.yandex.ru'),
      );

      ref.read(loggerProvider).i('Found ${cookies.length} cookies');

      // Извлекаем нужные cookies
      String? sessionId;
      String? sessionId2;
      String? loginToken;
      String? yandexLogin;
      String? yandexUid;
      String? parkId;
      
      // Дополнительные cookies для Yandex API
      final Map<String, String> allCookies = {};

      for (final cookie in cookies) {
        ref.read(loggerProvider).d('Cookie: ${cookie.name} = ${cookie.value.substring(0, cookie.value.length > 50 ? 50 : cookie.value.length)}...');
        
        // Сохраняем все cookies
        allCookies[cookie.name] = cookie.value;

        switch (cookie.name) {
          case 'Session_id':
            sessionId = cookie.value;
            break;
          case 'sessionid2':
            sessionId2 = cookie.value;
            break;
          case 'L':
            loginToken = cookie.value;
            break;
          case 'yandex_login':
            yandexLogin = cookie.value;
            break;
          case 'yandexuid':
            yandexUid = cookie.value;
            break;
          case 'park_id':
            parkId = cookie.value;
            break;
        }
      }
      
      // Логируем длину Session_id для проверки
      if (sessionId != null) {
        ref.read(loggerProvider).i('Session_id length: ${sessionId.length}');
      }

      // Извлекаем park_id из URL если не нашли в cookies
      if (parkId == null || parkId.isEmpty) {
        parkId = _extractParkIdFromUrl(url);
      }

      ref
          .read(loggerProvider)
          .i(
            'Extracted: park_id=$parkId, yandex_login=$yandexLogin, '
            'Session_id=${sessionId != null}, sessionid2=${sessionId2 != null}',
          );

      // Проверяем наличие всех необходимых данных
      if (parkId != null &&
          parkId.isNotEmpty &&
          yandexLogin != null &&
          yandexLogin.isNotEmpty &&
          sessionId != null &&
          sessionId.isNotEmpty &&
          sessionId2 != null &&
          sessionId2.isNotEmpty) {
        ref.read(loggerProvider).i('✅ User logged in successfully!');

        // Сохраняем данные локально
        final secureStorage = ref.read(secureStorageServiceProvider);
        await secureStorage.saveYandexCredentials(
          clid: '',
          apiKey: '',
          parkId: parkId,
        );

        // Сохраняем cookies локально
        final authService = ref.read(authServiceProvider);
        await authService.saveYandexCookies(
          sessionId: sessionId,
          sessionId2: sessionId2,
          loginToken: loginToken,
          yandexLogin: yandexLogin,
          yandexUid: yandexUid,
        );
        
        // Сохраняем все cookies как строку для полной передачи в API
        final cookiesString = allCookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
        ref.read(loggerProvider).i('Saving ${allCookies.length} cookies, total length: ${cookiesString.length}');
        await secureStorage.saveAllYandexCookies(cookiesString);

        // Отправляем сессию на backend
        try {
          final dio = ref.read(dioProvider);
          final response = await dio.post(
            '/api/auth/webview-session',
            data: {
              'park_id': parkId,
              'session_id': sessionId,
              'session_id2': sessionId2,
              'login_token': loginToken ?? '',
              'yandex_login': yandexLogin,
              'yandex_uid': yandexUid ?? '',
            },
          );
          
          if (response.statusCode == 200 && response.data['success'] == true) {
             final token = response.data['token'];
             if (token != null) {
               await secureStorage.saveAppToken(token);
               ref.read(loggerProvider).i('✅ Token saved locally: $token');
             }
          }
          
          ref.read(loggerProvider).i('✅ Session saved to backend');
        } catch (e) {
          ref.read(loggerProvider).e('❌ Failed to save session to backend: $e');
          // Продолжаем даже если не удалось сохранить на backend
        }

        if (mounted) {
          // Показываем сообщение об успехе
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Авторизация успешна! Парк: $parkId'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Переходим на главный экран
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            context.go('/fleet');
          }
        }
      } else {
        ref
            .read(loggerProvider)
            .w(
              'Waiting for login... Missing: '
              '${parkId == null ? "park_id " : ""}'
              '${yandexLogin == null ? "yandex_login " : ""}'
              '${sessionId == null ? "Session_id " : ""}'
              '${sessionId2 == null ? "sessionid2 " : ""}',
            );

        // Если слишком долго ждём — возможно застряли с устаревшими куками
        if (_isLoginTimedOut()) {
          await _handleTimeout();
        }

        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      ref.read(loggerProvider).e('Error checking cookies: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String? _extractParkIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Проверяем query параметр park_id
      final queryParkId = uri.queryParameters['park_id'];
      if (queryParkId != null && queryParkId.isNotEmpty) {
        return queryParkId;
      }

      // Проверяем путь вида /parks/{park_id}/...
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2 && pathSegments[0] == 'parks') {
        final parkId = pathSegments[1];
        if (parkId.isNotEmpty) {
          return parkId;
        }
      }
    } catch (e) {
      ref.read(loggerProvider).e('Error extracting park_id: $e');
    }
    return null;
  }
}
