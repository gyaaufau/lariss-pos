import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/tokens/app_design_token.dart';
import '../cubit/category_form_cubit.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({this.categoryId, super.key});

  final String? categoryId;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  late final TextEditingController _nameController;
  bool _didHydrate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryFormCubit>().initialize(
        categoryId: widget.categoryId,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final saved = await context.read<CategoryFormCubit>().submit(
      _nameController.text,
    );
    if (!mounted || !saved) {
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryId == null ? 'Tambah kategori' : 'Edit kategori',
        ),
      ),
      body: BlocConsumer<CategoryFormCubit, CategoryFormState>(
        listener: (context, state) {
          if (!_didHydrate && state.category != null) {
            _nameController.text = state.category!.name;
            _didHydrate = true;
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == CategoryFormStatus.loading ||
              state.status == CategoryFormStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool isSubmitting =
              state.status == CategoryFormStatus.submitting;

          return SafeArea(
            child: ListView(
              padding: AppDesignToken.cardPadding,
              children: <Widget>[
                Container(
                  padding: AppDesignToken.cardPadding,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        state.isEditing
                            ? 'Perbarui kategori'
                            : 'Buat kategori baru',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: AppDesignToken.infoRowGap),
                      TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Nama kategori',
                          hintText: 'Contoh: Minuman',
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDesignToken.buttonSectionGap),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSubmitting ? null : _submit,
                    child: Text(
                      isSubmitting ? 'Menyimpan...' : 'Simpan kategori',
                    ),
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
