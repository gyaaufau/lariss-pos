import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/profile_domain/domain/usecases/get_app_settings.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final Future<void> minimumDelay = Future<void>.delayed(
      const Duration(milliseconds: 1400),
    );
    final result = await sl<GetAppSettings>()();
    await minimumDelay;

    if (!mounted) {
      return;
    }

    result.match(
      (_) => context.go(AppRouter.onboardingPath),
      (settings) => context.go(
        settings.onboardingCompleted
            ? AppRouter.homePath
            : AppRouter.onboardingPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF7FFFB), Color(0xFFE8F7F1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/brand/full logo.png', width: 260),
                  SizedBox(height: 28.h),
                  Text(
                    'POS simpel untuk pantau produk, stok, dan transaksi.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF475569),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
