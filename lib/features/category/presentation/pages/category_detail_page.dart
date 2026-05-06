import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../cubit/category_detail_cubit.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({required this.categoryId, super.key});

  final String categoryId;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryDetailCubit>().loadCategory(widget.categoryId);
    });
  }

  Future<void> _openEdit() async {
    await context.push(AppRouter.categoryEditPath(widget.categoryId));
    if (!mounted) {
      return;
    }
    await context.read<CategoryDetailCubit>().loadCategory(widget.categoryId);
  }

  Future<void> _delete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus kategori'),
          content: const Text('Kategori ini akan disembunyikan dari daftar.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final deleted = await context
        .read<CategoryDetailCubit>()
        .deleteCurrentCategory();
    if (!mounted || !deleted) {
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail kategori')),
      body: BlocConsumer<CategoryDetailCubit, CategoryDetailState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == CategoryDetailStatus.loading ||
              state.status == CategoryDetailStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          final category = state.category;
          if (category == null) {
            return const Center(child: Text('Kategori tidak ditemukan.'));
          }

          final bool isDeleting = state.status == CategoryDetailStatus.deleting;

          return SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16.r),
              children: <Widget>[
                _DetailCard(
                  title: category.name,
                  children: <Widget>[
                    _InfoRow(
                      label: 'Dibuat',
                      value: formatDateTime(category.createdAt),
                    ),
                    SizedBox(height: 12.h),
                    _InfoRow(
                      label: 'Diubah',
                      value: formatDateTime(category.updatedAt),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit kategori'),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isDeleting ? null : _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(isDeleting ? 'Menghapus...' : 'Hapus kategori'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16.h),
          ...children,
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
    return Row(
      children: <Widget>[
        Expanded(child: Text(label)),
        SizedBox(width: 16.w),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
