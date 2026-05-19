import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryCubit>().loadCategories();
    });
  }

  Future<void> _openCreatePage() async {
    await context.push(AppRouter.categoryCreatePath);
    if (!mounted) {
      return;
    }
    await context.read<CategoryCubit>().loadCategories();
  }

  Future<void> _openDetailPage(String categoryId) async {
    await context.push(AppRouter.categoryDetailPath(categoryId));
    if (!mounted) {
      return;
    }
    await context.read<CategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePage,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state.status == CategoryStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final bool isLoading =
              state.status == CategoryStatus.loading &&
              state.categories.isEmpty;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<CategoryCubit>().loadCategories(),
              child: ListView(
                padding: AppDesignToken.cardPadding,
                children: <Widget>[
                  Text(
                    'Kelola kategori produk.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: AppDesignToken.infoRowGap),
                  Text(
                    'Pisah list, detail, dan form supaya flow lebih rapi untuk app mobile.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: AppDesignToken.subtitleContentGap),
                  if (isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDesignToken.movementGroupGap * 3,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.categories.isEmpty)
                    const _EmptyCategoryState()
                  else
                    ...state.categories.map(
                      (category) => Padding(
                        padding: EdgeInsets.only(bottom: AppDesignToken.itemGap),
                        child: _CategoryCard(
                          name: category.name,
                          onTap: () => _openDetailPage(category.id),
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: AppDesignToken.cardPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppDesignToken.infoRowGap * 1.5),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDesignToken.cardPadding.top * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Belum ada kategori.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppDesignToken.infoRowGap),
          Text(
            'Tambah kategori pertama dari tombol di kanan bawah.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
