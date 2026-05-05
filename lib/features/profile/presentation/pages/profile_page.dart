import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
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

  Future<void> _updateSettings({
    bool? lowStockAlertEnabled,
    bool? showOutOfStockProducts,
  }) async {
    context.read<ProfileCubit>().updateSettingsDraft(
      lowStockAlertEnabled: lowStockAlertEnabled,
      showOutOfStockProducts: showOutOfStockProducts,
    );
    await _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.errorMessage == null) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<ProfileCubit>().clearFeedback();
        },
        builder: (context, state) {
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
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _SectionTile(
                    title: 'Kelola profile',
                    subtitle: 'Lihat dan ubah identitas toko.',
                    icon: Icons.store_outlined,
                    onTap: () => context.push(AppRouter.storeProfilePath),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Settings aplikasi',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Atur perilaku dasar aplikasi untuk operasional harian.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: state.settings.lowStockAlertEnabled,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Aktifkan alert low stock'),
                          subtitle: const Text(
                            'Tampilkan pengingat stok menipis di home dan halaman stok.',
                          ),
                          onChanged: isSubmitting
                              ? null
                              : (value) => _updateSettings(
                                  lowStockAlertEnabled: value,
                                ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          value: state.settings.showOutOfStockProducts,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Tampilkan produk stok habis'),
                          subtitle: const Text(
                            'Kalau mati, produk stok 0 bisa disembunyikan dari daftar tertentu.',
                          ),
                          onChanged: isSubmitting
                              ? null
                              : (value) => _updateSettings(
                                  showOutOfStockProducts: value,
                                ),
                        ),
                      ],
                    ),
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

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
