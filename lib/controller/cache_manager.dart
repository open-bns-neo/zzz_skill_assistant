import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const String skillCacheKey = 'skill';
  static const String settingCacheKey = 'setting';

  static SharedPreferences? prefs;

  static Future<bool> set<T>(String key, T value) async {
    prefs ??= await SharedPreferences.getInstance();
    if (T == String) {
      return await prefs!.setString(key, value as String);
    } else if (T == int) {
      return prefs!.setInt(key, value as int);
    } else if (T == double) {
      return prefs!.setDouble(key, value as double);
    } else if (T == bool) {
      return prefs!.setBool(key, value as bool);
    }
    return prefs!.setString(key, jsonEncode(value));
  }

  static Future<T?> get<T>(String key) async {
    prefs ??= await SharedPreferences.getInstance();
    if (T == String) {
      return prefs!.getString(key) as T?;
    } else if (T == int) {
      return prefs!.getInt(key) as T?;
    } else if (T == double) {
      return prefs!.getDouble(key) as T?;
    } else if (T == bool) {
      return prefs!.getBool(key) as T?;
    }
    return null;
  }

  static Future<List<T>?> getList<T>(String key) async {
    final data = await get<String>(key);
    if (data == null) {
      return null;
    }
    return jsonDecode(data).cast<T>();
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    final data = await get<String>(key);
    if (data == null) {
      return null;
    }
    return jsonDecode(data);
  }

  static Future<Map<String, dynamic>?> loadSkillCache() async {
    var data = await getMap(skillCacheKey);
    if (data == null || data.isEmpty) {
      // 兼容旧版本
      data = await load();
      if (data != null) {
        set(skillCacheKey, data);
        clear();
      }
    }

    return data;
  }

  static Future<Map<String, dynamic>?> load() async {
    try {
      final dir = await _getFilePath();
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
    await set(skillCacheKey, data);
  }

  static Future<void> clear() async {
    final dir = await _getFilePath();
    if (dir == null) {
      return;
    }
    final file = File(dir);

    await file.delete();
  }

  static Future<String?> _getFilePath() async {
    Directory? dir;
    try {
      dir = await getApplicationSupportDirectory();
    } catch (e) {
      return null;
    }
    return '${dir.path}/bns_assistant_cache.json';
  }
}