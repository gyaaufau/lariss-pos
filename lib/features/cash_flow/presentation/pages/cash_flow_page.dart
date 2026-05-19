import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/tokens/app_design_token.dart';
import '../../../../core/widgets/app_section_tile.dart';

class CashFlowPage extends StatelessWidget {
  const CashFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola')),
      body: SafeArea(
        child: ListView(
          padding: AppDesignToken.cardPadding,
          children: <Widget>[],
        ),
      ),
    );
  }
}
