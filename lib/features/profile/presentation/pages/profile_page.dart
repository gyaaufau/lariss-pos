import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
import '../../../../core/widgets/app_section_tile.dart';
import '../cubit/app_settings_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  Future<void> _saveSettings() async {
    final isSuccess = await context.read<ProfileCubit>().saveSettings();
    if (!mounted || !isSuccess) {
      return;
    }
  }

  Future<void> _updateSettings({bool? lowStockAlertEnabled}) async {
    context.read<ProfileCubit>().updateSettingsDraft(
      lowStockAlertEnabled: lowStockAlertEnabled,
    );
    await _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success) {
            context.read<AppSettingsCubit>().syncSettings(state.settings);
          }

          if (state.errorMessage == null) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<ProfileCubit>().clearFeedback();
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          final isInitialLoading =
              state.status == ProfileStatus.loading && state.profile == null;
          final isSubmitting = state.status == ProfileStatus.submitting;

          if (isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().loadProfile(),
              child: ListView(
                padding: AppDesignToken.cardPadding,
                children: <Widget>[
                  AppSectionTile(
                    title: 'Kelola profile',
                    icon: Icons.store_outlined,
                    onTap: () => context.push(AppRouter.storeProfilePath),
                  ),
                  SizedBox(height: AppDesignToken.tileGap),
                  Container(
                    padding: AppDesignToken.cardPadding,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 52.w,
                          height: 52.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF3),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        SizedBox(width: AppDesignToken.cardTitleGap + 2.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      'Backup data ke Google Drive',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical:
                                          AppDesignToken.infoRowGap * 0.75,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF7ED),
                                      borderRadius: BorderRadius.circular(
                                        999.r,
                                      ),
                                    ),
                                    child: Text(
                                      'Coming soon',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: const Color(0xFFEA580C),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDesignToken.infoRowGap),
                              Text(
                                'Backup database toko ke Google Drive akan hadir di update berikutnya.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDesignToken.sectionGap),
                  Container(
                    padding: AppDesignToken.cardPadding,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Settings aplikasi',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: AppDesignToken.infoRowGap),
                        Text(
                          'Atur perilaku dasar aplikasi untuk operasional harian.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: AppDesignToken.subtitleContentGap),
                        SwitchListTile(
                          value: state.settings.lowStockAlertEnabled,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Aktifkan alert low stock',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onChanged: isSubmitting
                              ? null
                              : (value) => _updateSettings(
                                  lowStockAlertEnabled: value,
                                ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDesignToken.sectionGap),
                  AppSectionTile(
                    title: 'Kelola produk',
                    icon: Icons.inventory_outlined,
                    onTap: () => context.push(AppRouter.productsPath),
                  ),
                  SizedBox(height: AppDesignToken.tileGap),
                  AppSectionTile(
                    title: 'Kelola kategori',
                    icon: Icons.category_outlined,
                    onTap: () => context.push(AppRouter.categoriesPath),
                  ),
                  SizedBox(height: AppDesignToken.tileGap),
                  AppSectionTile(
                    title: 'Kelola stok',
                    icon: Icons.inventory_2_outlined,
                    onTap: () => context.push(AppRouter.stockPath),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
