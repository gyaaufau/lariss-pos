import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
import '../../../../domain/profile_domain/domain/entities/store_profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class StoreProfilePage extends StatefulWidget {
  const StoreProfilePage({super.key});

  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  Future<void> _openEditPage() async {
    final shouldReload = await context.push<bool>(AppRouter.profileEditPath);
    if (!mounted || shouldReload != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil toko berhasil diperbarui.')),
    );
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil toko')),
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

          if (isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().loadProfile(),
              child: ListView(
                padding: AppDesignToken.cardPadding,
                children: <Widget>[
                  _StoreProfileCard(
                    profile: state.profile,
                    onEdit: _openEditPage,
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
  const _StoreProfileCard({required this.profile, required this.onEdit});

  final StoreProfileEntity? profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDesignToken.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Profil toko', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: AppDesignToken.infoRowGap),
          Text(
            'Lihat identitas toko di sini. Ubah data lewat halaman terpisah.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: AppDesignToken.cardTitleGap),
          _InfoRow(label: 'Nama toko', value: profile?.storeName ?? '-'),
          SizedBox(height: AppDesignToken.infoRowGap),
          _InfoRow(label: 'Nama owner', value: profile?.ownerName ?? '-'),
          SizedBox(height: AppDesignToken.cardTitleGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Ubah profil toko'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B)),
        ),
        SizedBox(height: AppDesignToken.infoRowGap * 0.5),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
