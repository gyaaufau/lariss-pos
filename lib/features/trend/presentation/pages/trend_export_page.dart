import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../domain/trend_domain/domain/entities/trend_dashboard_entity.dart';
import '../../../../domain/trend_domain/domain/usecases/get_trend_dashboard.dart';
import '../services/trend_csv_exporter.dart';
import '../services/trend_export_file_handler.dart';
import '../services/trend_pdf_exporter.dart';

class TrendExportPage extends StatelessWidget {
  const TrendExportPage({
    required this.dashboard,
    this.csvExporter = const TrendCsvExporter(),
    this.pdfExporter = const TrendPdfExporter(),
    this.fileHandler = const PlatformTrendExportFileHandler(),
    this.getTrendDashboard,
    super.key,
  });

  final TrendDashboardEntity? dashboard;
  final TrendCsvExporter csvExporter;
  final TrendPdfExporter pdfExporter;
  final TrendExportFileHandler fileHandler;
  final GetTrendDashboard? getTrendDashboard;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Export trend')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.construction_rounded,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Coming soon',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Fitur export trend sedang disiapkan. Balik lagi nanti.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
