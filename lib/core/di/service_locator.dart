import 'package:get_it/get_it.dart';

import '../../domain/cart_domain/domain/usecases/add_cart_item.dart';
import '../../domain/cart_domain/domain/usecases/get_cart_total_amount.dart';
import '../../domain/cart_domain/domain/usecases/get_cart_total_items.dart';
import '../../domain/cart_domain/domain/usecases/remove_cart_item.dart';
import '../../domain/cart_domain/domain/usecases/update_cart_item_quantity.dart';
import '../database/app_database.dart';
import '../../domain/category_domain/data/datasources/category_local_datasource.dart';
import '../../domain/category_domain/data/datasources/category_local_datasource_impl.dart';
import '../../domain/category_domain/data/repositories/category_repository_impl.dart';
import '../../domain/category_domain/domain/repositories/category_repository.dart';
import '../../domain/category_domain/domain/usecases/create_category.dart';
import '../../domain/category_domain/domain/usecases/delete_category.dart';
import '../../domain/category_domain/domain/usecases/get_category_by_id.dart';
import '../../domain/category_domain/domain/usecases/get_categories.dart';
import '../../domain/category_domain/domain/usecases/update_category.dart';
import '../../domain/product_domain/data/datasources/product_local_datasource.dart';
import '../../domain/product_domain/data/datasources/product_local_datasource_impl.dart';
import '../../domain/product_domain/data/repositories/product_repository_impl.dart';
import '../../domain/product_domain/domain/repositories/product_repository.dart';
import '../../domain/product_domain/domain/usecases/create_product.dart';
import '../../domain/product_domain/domain/usecases/delete_product.dart';
import '../../domain/product_domain/domain/usecases/get_product_by_id.dart';
import '../../domain/product_domain/domain/usecases/get_products.dart';
import '../../domain/product_domain/domain/usecases/update_product.dart';
import '../../domain/profile_domain/data/datasources/profile_local_datasource.dart';
import '../../domain/profile_domain/data/datasources/profile_local_datasource_impl.dart';
import '../../domain/profile_domain/data/repositories/profile_repository_impl.dart';
import '../../domain/profile_domain/domain/repositories/profile_repository.dart';
import '../../domain/profile_domain/domain/usecases/get_app_settings.dart';
import '../../domain/profile_domain/domain/usecases/get_store_profile.dart';
import '../../domain/profile_domain/domain/usecases/save_app_settings.dart';
import '../../domain/profile_domain/domain/usecases/save_store_profile.dart';
import '../../domain/stock_domain/data/datasources/stock_local_datasource.dart';
import '../../domain/stock_domain/data/datasources/stock_local_datasource_impl.dart';
import '../../domain/stock_domain/data/repositories/stock_repository_impl.dart';
import '../../domain/stock_domain/domain/repositories/stock_repository.dart';
import '../../domain/stock_domain/domain/usecases/get_low_stock_products.dart';
import '../../domain/stock_domain/domain/usecases/get_stock_movements_by_product_id.dart';
import '../../domain/stock_domain/domain/usecases/get_stock_product_by_id.dart';
import '../../domain/stock_domain/domain/usecases/get_stock_products.dart';
import '../../domain/stock_domain/domain/usecases/update_stock.dart';
import '../../domain/transaction_domain/data/datasources/transaction_local_datasource.dart';
import '../../domain/transaction_domain/data/datasources/transaction_local_datasource_impl.dart';
import '../../domain/transaction_domain/data/repositories/transaction_repository_impl.dart';
import '../../domain/transaction_domain/domain/repositories/transaction_repository.dart';
import '../../domain/transaction_domain/domain/usecases/checkout_transaction.dart';
import '../../domain/transaction_domain/domain/usecases/get_transaction_detail.dart';
import '../../domain/transaction_domain/domain/usecases/get_transaction_history.dart';
import '../../domain/trend_domain/data/datasources/trend_local_datasource.dart';
import '../../domain/trend_domain/data/datasources/trend_local_datasource_impl.dart';
import '../../domain/trend_domain/data/repositories/trend_repository_impl.dart';
import '../../domain/trend_domain/domain/repositories/trend_repository.dart';
import '../../domain/trend_domain/domain/usecases/get_trend_dashboard.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/checkout_cubit.dart';
import '../../features/category/presentation/cubit/category_cubit.dart';
import '../../features/category/presentation/cubit/category_detail_cubit.dart';
import '../../features/category/presentation/cubit/category_form_cubit.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/profile/presentation/cubit/app_settings_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/product/presentation/cubit/product_detail_cubit.dart';
import '../../features/product/presentation/cubit/product_form_cubit.dart';
import '../../features/product/presentation/cubit/product_cubit.dart';
import '../../features/stock/presentation/cubit/stock_detail_cubit.dart';
import '../../features/stock/presentation/cubit/stock_cubit.dart';
import '../../features/stock/presentation/cubit/stock_update_cubit.dart';
import '../../features/trend/presentation/cubit/trend_cubit.dart';
import '../router/app_router.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  }

  if (!sl.isRegistered<AppRouter>()) {
    sl.registerLazySingleton<AppRouter>(() => AppRouter());
  }

  if (!sl.isRegistered<CategoryLocalDatasource>()) {
    sl.registerLazySingleton<CategoryLocalDatasource>(
      () => CategoryLocalDatasourceImpl(
        sl<AppDatabase>().categoriesDao,
        sl<AppDatabase>().productsDao,
      ),
    );
  }

  if (!sl.isRegistered<CategoryRepository>()) {
    sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl<CategoryLocalDatasource>()),
    );
  }

  if (!sl.isRegistered<GetCategories>()) {
    sl.registerLazySingleton<GetCategories>(
      () => GetCategories(sl<CategoryRepository>()),
    );
  }

  if (!sl.isRegistered<CreateCategory>()) {
    sl.registerLazySingleton<CreateCategory>(
      () => CreateCategory(sl<CategoryRepository>()),
    );
  }

  if (!sl.isRegistered<GetCategoryById>()) {
    sl.registerLazySingleton<GetCategoryById>(
      () => GetCategoryById(sl<CategoryRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateCategory>()) {
    sl.registerLazySingleton<UpdateCategory>(
      () => UpdateCategory(sl<CategoryRepository>()),
    );
  }

  if (!sl.isRegistered<DeleteCategory>()) {
    sl.registerLazySingleton<DeleteCategory>(
      () => DeleteCategory(sl<CategoryRepository>()),
    );
  }

  if (!sl.isRegistered<CategoryCubit>()) {
    sl.registerFactory<CategoryCubit>(
      () => CategoryCubit(getCategories: sl<GetCategories>()),
    );
  }

  if (!sl.isRegistered<CategoryDetailCubit>()) {
    sl.registerFactory<CategoryDetailCubit>(
      () => CategoryDetailCubit(
        getCategoryById: sl<GetCategoryById>(),
        deleteCategory: sl<DeleteCategory>(),
      ),
    );
  }

  if (!sl.isRegistered<CategoryFormCubit>()) {
    sl.registerFactory<CategoryFormCubit>(
      () => CategoryFormCubit(
        createCategory: sl<CreateCategory>(),
        getCategoryById: sl<GetCategoryById>(),
        updateCategory: sl<UpdateCategory>(),
      ),
    );
  }

  if (!sl.isRegistered<ProductLocalDatasource>()) {
    sl.registerLazySingleton<ProductLocalDatasource>(
      () => ProductLocalDatasourceImpl(sl<AppDatabase>().productsDao),
    );
  }

  if (!sl.isRegistered<ProductRepository>()) {
    sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl<ProductLocalDatasource>()),
    );
  }

  if (!sl.isRegistered<GetProducts>()) {
    sl.registerLazySingleton<GetProducts>(
      () => GetProducts(sl<ProductRepository>()),
    );
  }

  if (!sl.isRegistered<CreateProduct>()) {
    sl.registerLazySingleton<CreateProduct>(
      () => CreateProduct(sl<ProductRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateProduct>()) {
    sl.registerLazySingleton<UpdateProduct>(
      () => UpdateProduct(sl<ProductRepository>()),
    );
  }

  if (!sl.isRegistered<DeleteProduct>()) {
    sl.registerLazySingleton<DeleteProduct>(
      () => DeleteProduct(sl<ProductRepository>()),
    );
  }

  if (!sl.isRegistered<GetProductById>()) {
    sl.registerLazySingleton<GetProductById>(
      () => GetProductById(sl<ProductRepository>()),
    );
  }

  if (!sl.isRegistered<ProductCubit>()) {
    sl.registerFactory<ProductCubit>(
      () => ProductCubit(
        getProducts: sl<GetProducts>(),
        createProduct: sl<CreateProduct>(),
        updateProduct: sl<UpdateProduct>(),
        deleteProduct: sl<DeleteProduct>(),
        getCategories: sl<GetCategories>(),
      ),
    );
  }

  if (!sl.isRegistered<ProductDetailCubit>()) {
    sl.registerFactory<ProductDetailCubit>(
      () => ProductDetailCubit(
        getProductById: sl<GetProductById>(),
        getCategories: sl<GetCategories>(),
        deleteProduct: sl<DeleteProduct>(),
      ),
    );
  }

  if (!sl.isRegistered<ProductFormCubit>()) {
    sl.registerFactory<ProductFormCubit>(
      () => ProductFormCubit(
        getCategories: sl<GetCategories>(),
        getProductById: sl<GetProductById>(),
        createProduct: sl<CreateProduct>(),
        updateProduct: sl<UpdateProduct>(),
      ),
    );
  }

  if (!sl.isRegistered<AddCartItem>()) {
    sl.registerLazySingleton<AddCartItem>(() => const AddCartItem());
  }

  if (!sl.isRegistered<RemoveCartItem>()) {
    sl.registerLazySingleton<RemoveCartItem>(() => const RemoveCartItem());
  }

  if (!sl.isRegistered<UpdateCartItemQuantity>()) {
    sl.registerLazySingleton<UpdateCartItemQuantity>(
      () => const UpdateCartItemQuantity(),
    );
  }

  if (!sl.isRegistered<GetCartTotalAmount>()) {
    sl.registerLazySingleton<GetCartTotalAmount>(
      () => const GetCartTotalAmount(),
    );
  }

  if (!sl.isRegistered<GetCartTotalItems>()) {
    sl.registerLazySingleton<GetCartTotalItems>(
      () => const GetCartTotalItems(),
    );
  }

  if (!sl.isRegistered<CartCubit>()) {
    sl.registerFactory<CartCubit>(
      () => CartCubit(
        addCartItem: sl<AddCartItem>(),
        removeCartItem: sl<RemoveCartItem>(),
        updateCartItemQuantity: sl<UpdateCartItemQuantity>(),
        getCartTotalAmount: sl<GetCartTotalAmount>(),
        getCartTotalItems: sl<GetCartTotalItems>(),
      ),
    );
  }

  if (!sl.isRegistered<ProfileLocalDatasource>()) {
    sl.registerLazySingleton<ProfileLocalDatasource>(
      () => ProfileLocalDatasourceImpl(sl<AppDatabase>().profileDao),
    );
  }

  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileLocalDatasource>()),
    );
  }

  if (!sl.isRegistered<GetStoreProfile>()) {
    sl.registerLazySingleton<GetStoreProfile>(
      () => GetStoreProfile(sl<ProfileRepository>()),
    );
  }

  if (!sl.isRegistered<SaveStoreProfile>()) {
    sl.registerLazySingleton<SaveStoreProfile>(
      () => SaveStoreProfile(sl<ProfileRepository>()),
    );
  }

  if (!sl.isRegistered<GetAppSettings>()) {
    sl.registerLazySingleton<GetAppSettings>(
      () => GetAppSettings(sl<ProfileRepository>()),
    );
  }

  if (!sl.isRegistered<SaveAppSettings>()) {
    sl.registerLazySingleton<SaveAppSettings>(
      () => SaveAppSettings(sl<ProfileRepository>()),
    );
  }

  if (!sl.isRegistered<ProfileCubit>()) {
    sl.registerFactory<ProfileCubit>(
      () => ProfileCubit(
        getStoreProfile: sl<GetStoreProfile>(),
        saveStoreProfile: sl<SaveStoreProfile>(),
        getAppSettings: sl<GetAppSettings>(),
        saveAppSettings: sl<SaveAppSettings>(),
      ),
    );
  }

  if (!sl.isRegistered<AppSettingsCubit>()) {
    sl.registerFactory<AppSettingsCubit>(
      () => AppSettingsCubit(getAppSettings: sl<GetAppSettings>()),
    );
  }

  if (!sl.isRegistered<StockLocalDatasource>()) {
    sl.registerLazySingleton<StockLocalDatasource>(
      () => StockLocalDatasourceImpl(
        appDatabase: sl<AppDatabase>(),
        productsDao: sl<AppDatabase>().productsDao,
        stockMovementsDao: sl<AppDatabase>().stockMovementsDao,
      ),
    );
  }

  if (!sl.isRegistered<StockRepository>()) {
    sl.registerLazySingleton<StockRepository>(
      () => StockRepositoryImpl(sl<StockLocalDatasource>()),
    );
  }

  if (!sl.isRegistered<GetStockProducts>()) {
    sl.registerLazySingleton<GetStockProducts>(
      () => GetStockProducts(sl<StockRepository>()),
    );
  }

  if (!sl.isRegistered<GetLowStockProducts>()) {
    sl.registerLazySingleton<GetLowStockProducts>(
      () => GetLowStockProducts(sl<StockRepository>()),
    );
  }

  if (!sl.isRegistered<UpdateStock>()) {
    sl.registerLazySingleton<UpdateStock>(
      () => UpdateStock(sl<StockRepository>()),
    );
  }

  if (!sl.isRegistered<GetStockProductById>()) {
    sl.registerLazySingleton<GetStockProductById>(
      () => GetStockProductById(sl<StockRepository>()),
    );
  }

  if (!sl.isRegistered<GetStockMovementsByProductId>()) {
    sl.registerLazySingleton<GetStockMovementsByProductId>(
      () => GetStockMovementsByProductId(sl<StockRepository>()),
    );
  }

  if (!sl.isRegistered<StockCubit>()) {
    sl.registerFactory<StockCubit>(
      () => StockCubit(
        getStockProducts: sl<GetStockProducts>(),
        getLowStockProducts: sl<GetLowStockProducts>(),
        updateStock: sl<UpdateStock>(),
      ),
    );
  }

  if (!sl.isRegistered<StockDetailCubit>()) {
    sl.registerFactory<StockDetailCubit>(
      () => StockDetailCubit(
        getStockProductById: sl<GetStockProductById>(),
        getStockMovementsByProductId: sl<GetStockMovementsByProductId>(),
      ),
    );
  }

  if (!sl.isRegistered<StockUpdateCubit>()) {
    sl.registerFactory<StockUpdateCubit>(
      () => StockUpdateCubit(
        getStockProductById: sl<GetStockProductById>(),
        updateStock: sl<UpdateStock>(),
      ),
    );
  }

  if (!sl.isRegistered<TransactionLocalDatasource>()) {
    sl.registerLazySingleton<TransactionLocalDatasource>(
      () => TransactionLocalDatasourceImpl(
        appDatabase: sl<AppDatabase>(),
        transactionsDao: sl<AppDatabase>().transactionsDao,
        productsDao: sl<AppDatabase>().productsDao,
        categoriesDao: sl<AppDatabase>().categoriesDao,
        stockMovementsDao: sl<AppDatabase>().stockMovementsDao,
      ),
    );
  }

  if (!sl.isRegistered<TransactionRepository>()) {
    sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(sl<TransactionLocalDatasource>()),
    );
  }

  if (!sl.isRegistered<GetTransactionHistory>()) {
    sl.registerLazySingleton<GetTransactionHistory>(
      () => GetTransactionHistory(sl<TransactionRepository>()),
    );
  }

  if (!sl.isRegistered<GetTransactionDetail>()) {
    sl.registerLazySingleton<GetTransactionDetail>(
      () => GetTransactionDetail(sl<TransactionRepository>()),
    );
  }

  if (!sl.isRegistered<CheckoutTransaction>()) {
    sl.registerLazySingleton<CheckoutTransaction>(
      () => CheckoutTransaction(sl<TransactionRepository>()),
    );
  }

  if (!sl.isRegistered<HistoryCubit>()) {
    sl.registerFactory<HistoryCubit>(
      () => HistoryCubit(
        getTransactionHistory: sl<GetTransactionHistory>(),
        getTransactionDetail: sl<GetTransactionDetail>(),
      ),
    );
  }

  if (!sl.isRegistered<CheckoutCubit>()) {
    sl.registerFactory<CheckoutCubit>(
      () => CheckoutCubit(checkoutTransaction: sl<CheckoutTransaction>()),
    );
  }

  if (!sl.isRegistered<TrendLocalDatasource>()) {
    sl.registerLazySingleton<TrendLocalDatasource>(
      () => TrendLocalDatasourceImpl(sl<AppDatabase>().transactionsDao),
    );
  }

  if (!sl.isRegistered<TrendRepository>()) {
    sl.registerLazySingleton<TrendRepository>(
      () => TrendRepositoryImpl(sl<TrendLocalDatasource>()),
    );
  }

  if (!sl.isRegistered<GetTrendDashboard>()) {
    sl.registerLazySingleton<GetTrendDashboard>(
      () => GetTrendDashboard(sl<TrendRepository>()),
    );
  }

  if (!sl.isRegistered<TrendCubit>()) {
    sl.registerFactory<TrendCubit>(
      () => TrendCubit(getTrendDashboard: sl<GetTrendDashboard>()),
    );
  }
}
