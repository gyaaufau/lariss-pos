import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditStoreProfilePage extends StatefulWidget {
  const EditStoreProfilePage({super.key});

  @override
  State<EditStoreProfilePage> createState() => _EditStoreProfilePageState();
}

class _EditStoreProfilePageState extends State<EditStoreProfilePage> {
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
    final isSuccess = await context.read<ProfileCubit>().saveProfile(
      storeName: _storeNameController.text,
      ownerName: _ownerNameController.text,
    );
    if (!mounted || !isSuccess) {
      return;
    }

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah profil toko')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if ((!_didHydrateForm && state.profile != null) ||
              state.successMessage != null) {
            _syncForm(state);
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
                  _StoreProfileFormCard(
                    storeNameController: _storeNameController,
                    ownerNameController: _ownerNameController,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSubmitting ? null : _save,
                      child: Text(
                        isSubmitting ? 'Menyimpan...' : 'Simpan perubahan',
                      ),
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

class _StoreProfileFormCard extends StatelessWidget {
  const _StoreProfileFormCard({
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
          Text('Profil toko', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Ubah identitas toko untuk dipakai di home, transaksi, dan ringkasan app.',
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
