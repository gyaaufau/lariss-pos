import 'dart:io';

import 'package:open_file_manager/open_file_manager.dart' as file_manager;
import 'package:open_filex/open_filex.dart';

import 'trend_export_storage.dart';

abstract class TrendExportFileHandler {
  const TrendExportFileHandler();

  Future<String?> openFileManager(File file);

  Future<String?> openFile(File file);
}

class PlatformTrendExportFileHandler implements TrendExportFileHandler {
  const PlatformTrendExportFileHandler({
    this.storage = const TrendExportStorage(),
  });

  final TrendExportStorage storage;

  @override
  Future<String?> openFileManager(File file) async {
    try {
      if (Platform.isIOS) {
        final String? folderPath = await storage.getFileManagerFolderPath();
        await file_manager.openFileManager(
          iosConfig: file_manager.IosConfig(folderPath: folderPath),
        );
        return null;
      }

      if (Platform.isAndroid) {
        await file_manager.openFileManager();
        return null;
      }

      final OpenResult result = await OpenFilex.open(file.parent.path);
      if (result.type == ResultType.done) {
        return null;
      }
      return 'Folder export ada di ${file.parent.path}.';
    } catch (_) {
      return 'Folder export ada di ${file.parent.path}.';
    }
  }

  @override
  Future<String?> openFile(File file) async {
    try {
      final OpenResult result = await OpenFilex.open(file.path);
      if (result.type == ResultType.done) {
        return null;
      }
      return 'Buka manual dari ${file.path}.';
    } catch (_) {
      return 'Buka manual dari ${file.path}.';
    }
  }
}
