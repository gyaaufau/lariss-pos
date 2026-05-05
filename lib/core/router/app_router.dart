import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/transaction_domain/domain/entities/transaction_entity.dart';
import '../../features/app/presentation/pages/app_shell_page.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/checkout_cubit.dart';
import '../../features/category/presentation/cubit/category_cubit.dart';
import '../../features/category/presentation/cubit/category_detail_cubit.dart';
import '../../features/category/presentation/cubit/category_form_cubit.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/category/presentation/pages/categories_page.dart';
import '../../features/category/presentation/pages/category_detail_page.dart';
import '../../features/category/presentation/pages/category_form_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/history/presentation/pages/transaction_detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/manage/presentation/pages/manage_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/edit_store_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/store_profile_page.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';
import '../../features/product/presentation/cubit/product_detail_cubit.dart';
import '../../features/product/presentation/cubit/product_form_cubit.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/product/presentation/pages/product_form_page.dart';
import '../../features/product/presentation/pages/products_page.dart';
import '../../features/stock/presentation/cubit/stock_detail_cubit.dart';
import '../../features/stock/presentation/cubit/stock_cubit.dart';
import '../../features/stock/presentation/cubit/stock_update_cubit.dart';
import '../../features/stock/presentation/pages/stock_detail_page.dart';
import '../../features/stock/presentation/pages/stock_page.dart';
import '../../features/stock/presentation/pages/stock_update_page.dart';
import '../../features/trend/presentation/cubit/trend_cubit.dart';
import '../../features/trend/presentation/pages/trend_page.dart';
import '../di/service_locator.dart';

class AppRouter {
  static const String homePath = '/home';
  static const String historyPath = '/history';
  static const String trendPath = '/trend';
  static const String managePath = '/manage';
  static const String profilePath = '/profile';
  static const String storeProfilePath = '/profile/store';
  static const String profileEditPath = '/profile/edit';
  static const String checkoutPath = '/home/checkout';
  static const String checkoutSuccessPath = '/home/checkout/success';
  static const String categoriesPath = '/profile/categories';
  static const String productsPath = '/profile/products';
  static const String stockPath = '/profile/stock';
  static const String categoryCreatePath = '/profile/categories/create';
  static const String productCreatePath = '/profile/products/create';

  static String historyDetailPath(String id) => '/history/$id';

  static String categoryDetailPath(String id) => '/profile/categories/$id';

  static String categoryEditPath(String id) => '/profile/categories/$id/edit';

  static String productDetailPath(String id) => '/profile/products/$id';

  static String productEditPath(String id) => '/profile/products/$id/edit';

  static String stockDetailPath(String id) => '/profile/stock/$id';

  static String stockUpdatePath(String id) => '/profile/stock/$id/update';

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
                routes: <RouteBase>[
                  GoRoute(
                    path: ':transactionId',
                    builder: (context, state) => BlocProvider<HistoryCubit>(
                      create: (_) => sl<HistoryCubit>(),
                      child: TransactionDetailPage(
                        transactionId: state.pathParameters['transactionId']!,
                        initialTransaction: state.extra is TransactionEntity
                            ? state.extra! as TransactionEntity
                            : null,
                      ),
                    ),
                  ),
                ],
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
                path: managePath,
                builder: (context, state) => const ManagePage(),
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
                    path: 'store',
                    builder: (context, state) => BlocProvider<ProfileCubit>(
                      create: (_) => sl<ProfileCubit>(),
                      child: const StoreProfilePage(),
                    ),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => BlocProvider<ProfileCubit>(
                      create: (_) => sl<ProfileCubit>(),
                      child: const EditStoreProfilePage(),
                    ),
                  ),
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => BlocProvider<CategoryCubit>(
                      create: (_) => sl<CategoryCubit>(),
                      child: const CategoriesPage(),
                    ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'create',
                        builder: (context, state) =>
                            BlocProvider<CategoryFormCubit>(
                              create: (_) => sl<CategoryFormCubit>(),
                              child: const CategoryFormPage(),
                            ),
                      ),
                      GoRoute(
                        path: ':categoryId',
                        builder: (context, state) =>
                            BlocProvider<CategoryDetailCubit>(
                              create: (_) => sl<CategoryDetailCubit>(),
                              child: CategoryDetailPage(
                                categoryId: state.pathParameters['categoryId']!,
                              ),
                            ),
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) =>
                                BlocProvider<CategoryFormCubit>(
                                  create: (_) => sl<CategoryFormCubit>(),
                                  child: CategoryFormPage(
                                    categoryId:
                                        state.pathParameters['categoryId']!,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'products',
                    builder: (context, state) => const ProductsPage(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'create',
                        builder: (context, state) =>
                            BlocProvider<ProductFormCubit>(
                              create: (_) => sl<ProductFormCubit>(),
                              child: const ProductFormPage(),
                            ),
                      ),
                      GoRoute(
                        path: ':productId',
                        builder: (context, state) =>
                            BlocProvider<ProductDetailCubit>(
                              create: (_) => sl<ProductDetailCubit>(),
                              child: ProductDetailPage(
                                productId: state.pathParameters['productId']!,
                              ),
                            ),
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) =>
                                BlocProvider<ProductFormCubit>(
                                  create: (_) => sl<ProductFormCubit>(),
                                  child: ProductFormPage(
                                    productId:
                                        state.pathParameters['productId']!,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'stock',
                    builder: (context, state) => BlocProvider<StockCubit>(
                      create: (_) => sl<StockCubit>(),
                      child: const StockPage(),
                    ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':productId',
                        builder: (context, state) =>
                            BlocProvider<StockDetailCubit>(
                              create: (_) => sl<StockDetailCubit>(),
                              child: StockDetailPage(
                                productId: state.pathParameters['productId']!,
                              ),
                            ),
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'update',
                            builder: (context, state) =>
                                BlocProvider<StockUpdateCubit>(
                                  create: (_) => sl<StockUpdateCubit>(),
                                  child: StockUpdatePage(
                                    productId:
                                        state.pathParameters['productId']!,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ],
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
