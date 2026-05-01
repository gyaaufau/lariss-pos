import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lariss POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: sl<AppRouter>().router,
    );
  }
}
