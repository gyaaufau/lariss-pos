import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/transaction_domain/domain/entities/transaction_entity.dart';
import '../../features/app/presentation/pages/app_shell_page.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/checkout_cubit.dart';
import '../../features/category/presentation/cubit/category_cubit.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/category/presentation/pages/categories_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';
import '../../features/product/presentation/pages/products_page.dart';
import '../../features/stock/presentation/cubit/stock_cubit.dart';
import '../../features/stock/presentation/pages/stock_page.dart';
import '../../features/trend/presentation/cubit/trend_cubit.dart';
import '../../features/trend/presentation/pages/trend_page.dart';
import '../di/service_locator.dart';

class AppRouter {
  static const String homePath = '/home';
  static const String historyPath = '/history';
  static const String trendPath = '/trend';
  static const String profilePath = '/profile';
  static const String checkoutPath = '/home/checkout';
  static const String checkoutSuccessPath = '/home/checkout/success';
  static const String categoriesPath = '/profile/categories';
  static const String productsPath = '/profile/products';
  static const String stockPath = '/profile/stock';

  late final GoRouter router = GoRouter(
    initialLocation: homePath,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MultiBlocProvider(
          providers: [
            BlocProvider<ProductCubit>(create: (_) => sl<ProductCubit>()),
            BlocProvider<CartCubit>(create: (_) => sl<CartCubit>()),
            BlocProvider<CheckoutCubit>(create: (_) => sl<CheckoutCubit>()),
          ],
          child: AppShellPage(navigationShell: navigationShell),
        ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: homePath,
                builder: (context, state) => const HomePage(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'checkout',
                    builder: (context, state) => const CheckoutPage(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'success',
                        builder: (context, state) {
                          final transaction = state.extra;
                          if (transaction is! TransactionEntity) {
                            return const HomePage();
                          }

                          return CheckoutSuccessPage(transaction: transaction);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: historyPath,
                builder: (context, state) => BlocProvider<HistoryCubit>(
                  create: (_) => sl<HistoryCubit>(),
                  child: const HistoryPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: trendPath,
                builder: (context, state) => BlocProvider<TrendCubit>(
                  create: (_) => sl<TrendCubit>(),
                  child: const TrendPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: profilePath,
                builder: (context, state) => BlocProvider<ProfileCubit>(
                  create: (_) => sl<ProfileCubit>(),
                  child: const ProfilePage(),
                ),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => BlocProvider<CategoryCubit>(
                      create: (_) => sl<CategoryCubit>(),
                      child: const CategoriesPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'products',
                    builder: (context, state) => const ProductsPage(),
                  ),
                  GoRoute(
                    path: 'stock',
                    builder: (context, state) => BlocProvider<StockCubit>(
                      create: (_) => sl<StockCubit>(),
                      child: const StockPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
