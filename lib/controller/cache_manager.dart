import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CacheManager {
  static Future<Map<String, dynamic>?> load() async {
    try {
      final dir = await getFilePath();
      if (dir == null) {
        return null;
      }
      final file = File(dir);

      final data = await file.readAsString();
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  static Future<void> save(Map<String, dynamic> data) async {
    final dir = await getFilePath();
    if (dir == null) {
      return;
    }
    final file = File(dir);

    await file.writeAsString(jsonEncode(data));
  }

  static Future<void> clear() async {
    final dir = await getFilePath();
    if (dir == null) {
      return;
    }
    final file = File(dir);

    await file.delete();
  }

  static Future<String?> getFilePath() async {
    Directory? dir;
    try {
      dir = await getApplicationSupportDirectory();
    } catch (e) {
      return null;
    }
    return '${dir.path}/bns_assistant_cache.json';
  }
}