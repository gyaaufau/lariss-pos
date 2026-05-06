import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/app_settings_entity.dart';

class AppSettingsModel extends AppSettingsEntity {
  const AppSettingsModel({
    required super.lowStockAlertEnabled,
    required super.onboardingCompleted,
  });

  static const String lowStockAlertKey = 'low_stock_alert_enabled';
  static const String onboardingCompletedKey = 'onboarding_completed';

  factory AppSettingsModel.fromTableDataList(List<AppSettingsTableData> rows) {
    String? findValue(String key) {
      for (final AppSettingsTableData row in rows) {
        if (row.key == key) {
          return row.value;
        }
      }

      return null;
    }

    return AppSettingsModel(
      lowStockAlertEnabled: findValue(lowStockAlertKey) != 'false',
      onboardingCompleted: findValue(onboardingCompletedKey) == 'true',
    );
  }

  List<AppSettingsTableCompanion> toCompanions({
    required int createdAt,
    required int updatedAt,
  }) {
    return <AppSettingsTableCompanion>[
      AppSettingsTableCompanion(
        id: const Value(lowStockAlertKey),
        key: const Value(lowStockAlertKey),
        value: Value(lowStockAlertEnabled.toString()),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      ),
      AppSettingsTableCompanion(
        id: const Value(onboardingCompletedKey),
        key: const Value(onboardingCompletedKey),
        value: Value(onboardingCompleted.toString()),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      ),
    ];
  }
}
