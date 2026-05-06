import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_section_tile.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: <Widget>[
            AppSectionTile(
              title: 'Kelola produk',
              icon: Icons.inventory_outlined,
              onTap: () => context.push(AppRouter.productsPath),
            ),
            SizedBox(height: 12.h),
            AppSectionTile(
              title: 'Kelola kategori',
              icon: Icons.category_outlined,
              onTap: () => context.push(AppRouter.categoriesPath),
            ),
            SizedBox(height: 12.h),
            AppSectionTile(
              title: 'Kelola stok',
              icon: Icons.inventory_2_outlined,
              onTap: () => context.push(AppRouter.stockPath),
            ),
          ],
        ),
      ),
    );
  }
}
