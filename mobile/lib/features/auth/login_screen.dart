import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/app/theme.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 244, 242),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Logo
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent, 
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SvgPicture.asset(
                      'assets/images/icon.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Illustration placeholder
              Container(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/images/unauthenticated-yandex.svg',
                  height: 325,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Войдите в аккаунт Яндекс ID',
                textAlign: TextAlign.center,
                style: AppTheme.headlineLarge,
              ),
              const Spacer(flex: 4),
              // Login Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                     context.go('/fleet');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 252, 224, 0),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    fixedSize: const Size(177.5, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Yandex Sans Text',
                      height: 1.19, // 19px line height / 16px font size
                      letterSpacing: -0.08, // -0.5% of 16px
                    ),
                  ),
                  child: const Text('Войти'),
                ),
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
