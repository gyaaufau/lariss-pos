import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/product_form_cubit.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({this.productId, super.key});

  final String? productId;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minimumStockController;
  String? _selectedCategoryId;
  bool _isActive = true;
  bool _didHydrate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _minimumStockController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductFormCubit>().initialize(productId: widget.productId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori produk dulu.')),
      );
      return;
    }

    final sellingPrice = int.tryParse(_priceController.text.trim());
    final currentStock = int.tryParse(_stockController.text.trim());
    final minimumStock = int.tryParse(_minimumStockController.text.trim());

    if (sellingPrice == null || currentStock == null || minimumStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga dan stok wajib angka valid.')),
      );
      return;
    }

    final saved = await context.read<ProductFormCubit>().submit(
      categoryId: categoryId,
      name: _nameController.text,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minimumStock: minimumStock,
      isActive: _isActive,
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
        title: Text(widget.productId == null ? 'Tambah produk' : 'Edit produk'),
      ),
      body: BlocConsumer<ProductFormCubit, ProductFormState>(
        listener: (context, state) {
          if (!_didHydrate) {
            if (state.product != null) {
              final product = state.product!;
              _nameController.text = product.name;
              _priceController.text = product.sellingPrice.toString();
              _stockController.text = product.currentStock.toString();
              _minimumStockController.text = product.minimumStock.toString();
              _selectedCategoryId = product.categoryId;
              _isActive = product.isActive;
              _didHydrate = true;
            } else if (state.categories.isNotEmpty) {
              _selectedCategoryId ??= state.categories.first.id;
            }
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == ProductFormStatus.loading ||
              state.status == ProductFormStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool isSubmitting =
              state.status == ProductFormStatus.submitting;
          final bool hasCategories = state.categories.isNotEmpty;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                if (!hasCategories)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: const Text(
                      'Belum ada kategori aktif. Buat kategori dulu sebelum simpan produk.',
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        state.isEditing
                            ? 'Perbarui produk'
                            : 'Buat produk baru',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (hasCategories)
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategoryId,
                          items: state.categories
                              .map(
                                (category) => DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama produk',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga jual',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stok awal',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _minimumStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minimum stok',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: _isActive,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Produk aktif'),
                        subtitle: const Text(
                          'Produk aktif tampil di transaksi dan stok.',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: !hasCategories || isSubmitting ? null : _submit,
                    child: Text(
                      isSubmitting ? 'Menyimpan...' : 'Simpan produk',
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
