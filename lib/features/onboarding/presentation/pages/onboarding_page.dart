import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
import '../../../../domain/profile_domain/domain/usecases/get_app_settings.dart';
import '../../../../domain/profile_domain/domain/usecases/save_app_settings.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _isSubmitting = false;

  Future<void> _finishOnboarding() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final currentSettingsResult = await sl<GetAppSettings>()();
    final saveResult = await currentSettingsResult.match(
      (_) => sl<SaveAppSettings>()(
        lowStockAlertEnabled: true,
        onboardingCompleted: true,
      ),
      (settings) => sl<SaveAppSettings>()(
        lowStockAlertEnabled: settings.lowStockAlertEnabled,
        onboardingCompleted: true,
      ),
    );

    if (!mounted) {
      return;
    }

    saveResult.match((failure) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }, (_) => context.go(AppRouter.homePath));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppDesignToken.cardPadding.left + 8.r,
            AppDesignToken.cardPadding.top + 2.r,
            AppDesignToken.cardPadding.left + 8.r,
            AppDesignToken.cardPadding.bottom + 8.r,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _isSubmitting ? null : _finishOnboarding,
                  child: const Text('Lewati'),
                ),
              ),
              const Spacer(),
              Center(
              child: Container(
                padding: EdgeInsets.all(AppDesignToken.cardPadding.top * 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.r),
                    border: Border.all(color: const Color(0xFFD7EDE4)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 32,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/brand/full logo.png', width: 240),
                ),
              ),
              SizedBox(height: AppDesignToken.movementGroupGap * 2.5),
              Text(
                'Kelola toko lebih rapi',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: AppDesignToken.subtitleContentGap),
              Text(
                'Cek produk aktif, pantau stok menipis, dan proses transaksi dari satu app.',
                style: theme.textTheme.bodyLarge,
              ),
              SizedBox(height: AppDesignToken.movementGroupGap * 1.5),
              const _FeatureTile(
                icon: Icons.inventory_2_outlined,
                title: 'Produk terstruktur',
              ),
              SizedBox(height: AppDesignToken.subtitleContentGap),
              const _FeatureTile(
                icon: Icons.auto_graph_rounded,
                title: 'Stok lebih aman',
              ),
              SizedBox(height: AppDesignToken.subtitleContentGap),
              const _FeatureTile(
                icon: Icons.point_of_sale_rounded,
                title: 'Transaksi lebih ringkas',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _finishOnboarding,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDesignToken.movementGroupGap,
                    ),
                  ),
                  child: Text(_isSubmitting ? 'Memuat...' : 'Mulai pakai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDesignToken.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD7EDE4)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE7FAF4),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: const Color(0xFF14B88F)),
          ),
          SizedBox(width: AppDesignToken.cardTitleGap + 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
