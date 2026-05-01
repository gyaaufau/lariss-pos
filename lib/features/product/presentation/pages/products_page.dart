import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../domain/category_domain/domain/entities/category_entity.dart';
import '../../../../domain/product_domain/domain/entities/product_entity.dart';
import '../../../../domain/product_domain/domain/usecases/create_product.dart';
import '../../../../domain/product_domain/domain/usecases/update_product.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minimumStockController;

  ProductEntity? _editingProduct;
  String? _selectedCategoryId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _minimumStockController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadProducts();
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

  bool get _isEditing => _editingProduct != null;

  void _resetForm({String? defaultCategoryId}) {
    setState(() {
      _editingProduct = null;
      _selectedCategoryId = defaultCategoryId;
      _isActive = true;
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
      _minimumStockController.clear();
    });
  }

  void _startEditing(ProductEntity product) {
    setState(() {
      _editingProduct = product;
      _selectedCategoryId = product.categoryId;
      _isActive = product.isActive;
      _nameController.text = product.name;
      _priceController.text = product.sellingPrice.toString();
      _stockController.text = product.currentStock.toString();
      _minimumStockController.text = product.minimumStock.toString();
    });
  }

  Future<void> _submit(ProductState state) async {
    final String? selectedCategoryId =
        _selectedCategoryId ??
        (state.categories.isNotEmpty ? state.categories.first.id : null);

    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buat kategori dulu sebelum tambah produk.'),
        ),
      );
      return;
    }

    final int? price = int.tryParse(_priceController.text.trim());
    final int? stock = int.tryParse(_stockController.text.trim());
    final int? minimumStock = int.tryParse(_minimumStockController.text.trim());

    if (price == null || stock == null || minimumStock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga dan stok harus berupa angka valid.'),
        ),
      );
      return;
    }

    final ProductCubit cubit = context.read<ProductCubit>();
    final bool wasEditing = _isEditing;
    final bool saved;

    if (wasEditing) {
      saved = await cubit.updateProduct(
        UpdateProductParams(
          id: _editingProduct!.id,
          categoryId: selectedCategoryId,
          name: _nameController.text,
          sellingPrice: price,
          currentStock: stock,
          minimumStock: minimumStock,
          isActive: _isActive,
          createdAt: _editingProduct!.createdAt,
        ),
      );
    } else {
      saved = await cubit.createProduct(
        CreateProductParams(
          categoryId: selectedCategoryId,
          name: _nameController.text,
          sellingPrice: price,
          currentStock: stock,
          minimumStock: minimumStock,
          isActive: _isActive,
        ),
      );
    }

    if (!mounted || !saved) {
      return;
    }

    _resetForm(defaultCategoryId: selectedCategoryId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasEditing
              ? 'Produk berhasil diperbarui.'
              : 'Produk berhasil ditambahkan.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ProductEntity product, ProductState state) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus produk'),
          content: Text('Hapus ${product.name} dari daftar produk?'),
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

    if (shouldDelete != true || !mounted) {
      return;
    }

    final bool deleted = await context.read<ProductCubit>().deleteProduct(
      product,
    );

    if (!mounted || !deleted) {
      return;
    }

    if (_editingProduct?.id == product.id) {
      final String? fallbackCategoryId =
          _selectedCategoryId ??
          (state.categories.isNotEmpty ? state.categories.first.id : null);
      _resetForm(defaultCategoryId: fallbackCategoryId);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus.')));
  }

  String _categoryName(List<CategoryEntity> categories, String categoryId) {
    for (final CategoryEntity category in categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }

    return 'Tanpa kategori';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state.status == ProductStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          if (!_isEditing &&
              _selectedCategoryId == null &&
              state.categories.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _selectedCategoryId != null) {
                return;
              }

              setState(() {
                _selectedCategoryId = state.categories.first.id;
              });
            });
          }
        },
        builder: (context, state) {
          final bool isSubmitting = state.status == ProductStatus.submitting;
          final bool isLoading =
              state.status == ProductStatus.loading && state.products.isEmpty;
          final String? selectedCategoryId =
              _selectedCategoryId ??
              (state.categories.isNotEmpty ? state.categories.first.id : null);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Kelola produk untuk transaksi harian.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Day 4 dan Day 5 fokus: list, tambah, edit, hapus, dan status aktif produk.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        _FormCard(
                          nameController: _nameController,
                          priceController: _priceController,
                          stockController: _stockController,
                          minimumStockController: _minimumStockController,
                          categories: state.categories,
                          selectedCategoryId: selectedCategoryId,
                          onCategoryChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                          isActive: _isActive,
                          onActiveChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          isEditing: _isEditing,
                          isSubmitting: isSubmitting,
                          onSubmit: () => _submit(state),
                          onCancel: _isEditing
                              ? () => _resetForm(
                                  defaultCategoryId: selectedCategoryId,
                                )
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Daftar produk',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        if (state.categories.isEmpty)
                          _MissingCategoryCard(
                            onTap: () => context.push(AppRouter.categoriesPath),
                          )
                        else if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (state.products.isEmpty)
                          const _EmptyProductState()
                        else
                          ...state.products.map(
                            (ProductEntity product) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ProductCard(
                                product: product,
                                categoryName: _categoryName(
                                  state.categories,
                                  product.categoryId,
                                ),
                                onEdit: () => _startEditing(product),
                                onDelete: () => _confirmDelete(product, state),
                              ),
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

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.nameController,
    required this.priceController,
    required this.stockController,
    required this.minimumStockController,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.isActive,
    required this.onActiveChanged,
    required this.isEditing,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController minimumStockController;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final bool isEditing;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isEditing ? 'Edit produk' : 'Tambah produk',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedCategoryId,
            items: categories
                .map(
                  (CategoryEntity category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  ),
                )
                .toList(growable: false),
            onChanged: categories.isEmpty ? null : onCategoryChanged,
            decoration: const InputDecoration(labelText: 'Kategori'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nama produk',
              hintText: 'Contoh: Es Teh Manis',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Harga jual',
              hintText: 'Contoh: 12000',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Stok saat ini',
                    hintText: '0',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: minimumStockController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Minimum stok',
                    hintText: '5',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: isActive,
            onChanged: onActiveChanged,
            contentPadding: EdgeInsets.zero,
            title: const Text('Produk aktif'),
            subtitle: const Text(
              'Produk nonaktif tetap tersimpan tapi tidak dijual.',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  child: Text(
                    isSubmitting
                        ? 'Menyimpan...'
                        : isEditing
                        ? 'Simpan perubahan'
                        : 'Tambah produk',
                  ),
                ),
              ),
              if (onCancel != null) ...<Widget>[
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: isSubmitting ? null : onCancel,
                  child: const Text('Batal'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductEntity product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _Badge(
                          label: categoryName,
                          backgroundColor: const Color(0xFFDBEAFE),
                          foregroundColor: const Color(0xFF1E40AF),
                        ),
                        _Badge(
                          label: product.isActive ? 'Aktif' : 'Nonaktif',
                          backgroundColor: product.isActive
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFE2E8F0),
                          foregroundColor: product.isActive
                              ? const Color(0xFF166534)
                              : const Color(0xFF475569),
                        ),
                        if (product.isOutOfStock)
                          const _Badge(
                            label: 'Stok habis',
                            backgroundColor: Color(0xFFFEE2E2),
                            foregroundColor: Color(0xFFB91C1C),
                          )
                        else if (product.isLowStock)
                          const _Badge(
                            label: 'Stok menipis',
                            backgroundColor: Color(0xFFFEF3C7),
                            foregroundColor: Color(0xFFB45309),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                    return;
                  }

                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                  PopupMenuItem<String>(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _InfoTile(
                  label: 'Harga',
                  value: 'Rp ${product.sellingPrice}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  label: 'Stok',
                  value: '${product.currentStock}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  label: 'Min stok',
                  value: '${product.minimumStock}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyProductState extends StatelessWidget {
  const _EmptyProductState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Belum ada produk.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah produk pertama supaya flow transaksi bisa lanjut ke cart dan checkout.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MissingCategoryCard extends StatelessWidget {
  const _MissingCategoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Kategori belum ada.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Produk butuh kategori. Selesaikan kategori dulu, lalu kembali ke halaman ini.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onTap,
            child: const Text('Buka kelola kategori'),
          ),
        ],
      ),
    );
  }
}
