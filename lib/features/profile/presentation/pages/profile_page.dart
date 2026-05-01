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
  late final TextEditingController _storeNameController;
  late final TextEditingController _ownerNameController;
  bool _didHydrateForm = false;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _ownerNameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  void _syncForm(ProfileState state) {
    final profile = state.profile;
    if (profile == null) {
      return;
    }

    _storeNameController.text = profile.storeName;
    _ownerNameController.text = profile.ownerName;
    _didHydrateForm = true;
  }

  Future<void> _save() async {
    await context.read<ProfileCubit>().saveProfile(
      storeName: _storeNameController.text,
      ownerName: _ownerNameController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & settings')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if ((!_didHydrateForm && state.profile != null) ||
              state.successMessage != null) {
            _syncForm(state);
          }

          final messenger = ScaffoldMessenger.of(context);
          if (state.errorMessage != null) {
            messenger.showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<ProfileCubit>().clearFeedback();
          } else if (state.successMessage != null) {
            messenger.showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context.read<ProfileCubit>().clearFeedback();
          }
        },
        builder: (context, state) {
          final bool isInitialLoading =
              state.status == ProfileStatus.loading && state.profile == null;
          final bool isSubmitting = state.status == ProfileStatus.submitting;

          if (isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().loadProfile(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _StoreProfileCard(
                    storeNameController: _storeNameController,
                    ownerNameController: _ownerNameController,
                  ),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    lowStockAlertEnabled: state.settings.lowStockAlertEnabled,
                    showOutOfStockProducts:
                        state.settings.showOutOfStockProducts,
                    onLowStockChanged: (value) {
                      context.read<ProfileCubit>().updateSettingsDraft(
                        lowStockAlertEnabled: value,
                      );
                    },
                    onShowOutOfStockChanged: (value) {
                      context.read<ProfileCubit>().updateSettingsDraft(
                        showOutOfStockProducts: value,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSubmitting ? null : _save,
                      child: Text(
                        isSubmitting ? 'Menyimpan...' : 'Simpan profile',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ManagementTile(
                    title: 'Kelola kategori',
                    subtitle: 'CRUD kategori produk.',
                    icon: Icons.category_outlined,
                    onTap: () => context.push(AppRouter.categoriesPath),
                  ),
                  const SizedBox(height: 12),
                  _ManagementTile(
                    title: 'Kelola produk',
                    subtitle: 'CRUD produk, status aktif, dan stok minimum.',
                    icon: Icons.inventory_outlined,
                    onTap: () => context.push(AppRouter.productsPath),
                  ),
                  const SizedBox(height: 12),
                  _ManagementTile(
                    title: 'Kelola stok',
                    subtitle: 'Pantau low stock dan movement log.',
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

class _StoreProfileCard extends StatelessWidget {
  const _StoreProfileCard({
    required this.storeNameController,
    required this.ownerNameController,
  });

  final TextEditingController storeNameController;
  final TextEditingController ownerNameController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Profile toko', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Simpan identitas toko untuk dipakai di home, transaksi, dan ringkasan app.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: storeNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nama toko',
              hintText: 'Contoh: KasirLite',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerNameController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nama owner',
              hintText: 'Contoh: Larissa',
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.lowStockAlertEnabled,
    required this.showOutOfStockProducts,
    required this.onLowStockChanged,
    required this.onShowOutOfStockChanged,
  });

  final bool lowStockAlertEnabled;
  final bool showOutOfStockProducts;
  final ValueChanged<bool> onLowStockChanged;
  final ValueChanged<bool> onShowOutOfStockChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Atur perilaku dasar aplikasi untuk operasional harian.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: lowStockAlertEnabled,
            contentPadding: EdgeInsets.zero,
            title: const Text('Aktifkan alert low stock'),
            subtitle: const Text(
              'Tampilkan pengingat stok menipis di home dan halaman stok.',
            ),
            onChanged: onLowStockChanged,
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: showOutOfStockProducts,
            contentPadding: EdgeInsets.zero,
            title: const Text('Tampilkan produk stok habis'),
            subtitle: const Text(
              'Kalau mati, produk stok 0 bisa disembunyikan dari daftar tertentu.',
            ),
            onChanged: onShowOutOfStockChanged,
          ),
        ],
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  const _ManagementTile({
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
