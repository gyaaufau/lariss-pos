import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TrendExportStorage {
  const TrendExportStorage();

  Future<Directory> getExportDirectory() async {
    if (Platform.isAndroid) {
      final Directory? downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory != null) {
        if (!await downloadsDirectory.exists()) {
          await downloadsDirectory.create(recursive: true);
        }
        return downloadsDirectory;
      }
    }

    final Directory root = await getApplicationDocumentsDirectory();
    final Directory exportDir = Directory('${root.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  Future<String?> getFileManagerFolderPath() async {
    if (Platform.isIOS) {
      return 'exports';
    }

    if (Platform.isAndroid) {
      return null;
    }

    final Directory exportDir = await getExportDirectory();
    return exportDir.path;
  }
}
