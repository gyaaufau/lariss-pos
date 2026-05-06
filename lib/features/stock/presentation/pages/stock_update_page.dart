import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/stock_domain/domain/entities/stock_update_type.dart';
import '../cubit/stock_update_cubit.dart';

class StockUpdatePage extends StatefulWidget {
  const StockUpdatePage({required this.productId, super.key});

  final String productId;

  @override
  State<StockUpdatePage> createState() => _StockUpdatePageState();
}

class _StockUpdatePageState extends State<StockUpdatePage> {
  late final TextEditingController _quantityController;
  StockUpdateType _selectedType = StockUpdateType.stockIn;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockUpdateCubit>().initialize(widget.productId);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan angka stok yang valid.')),
      );
      return;
    }

    final saved = await context.read<StockUpdateCubit>().submit(
      type: _selectedType,
      quantity: quantity,
    );
    if (!mounted || !saved) {
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update stok')),
      body: BlocConsumer<StockUpdateCubit, StockUpdateState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == StockUpdateStatus.loading ||
              state.status == StockUpdateStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = state.product;
          if (product == null) {
            return const Center(child: Text('Produk stok tidak ditemukan.'));
          }

          final bool isAdjustment = _selectedType == StockUpdateType.adjustment;
          final bool isSubmitting =
              state.status == StockUpdateStatus.submitting;

          return SafeArea(
            child: ListView(
              padding: EdgeInsets.all(16.r),
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8.h),
                      Text('Stok sekarang: ${product.currentStock}'),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<StockUpdateType>(
                        initialValue: _selectedType,
                        items: StockUpdateType.values
                            .map(
                              (type) => DropdownMenuItem<StockUpdateType>(
                                value: type,
                                child: Text(type.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedType = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Tipe perubahan',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: isAdjustment ? 'Stok akhir' : 'Jumlah',
                          hintText: isAdjustment ? 'Contoh: 20' : 'Contoh: 5',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSubmitting ? null : _submit,
                    child: Text(
                      isSubmitting ? 'Menyimpan...' : 'Simpan perubahan',
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
