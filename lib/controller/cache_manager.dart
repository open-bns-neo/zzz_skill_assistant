import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CacheManager {
  static Future<Map<String, dynamic>?> load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/cache.json');

      final data = await file.readAsString();
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  static Future<void> save(Map<String, dynamic> data) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/cache.json');

    await file.writeAsString(jsonEncode(data));
  }
}