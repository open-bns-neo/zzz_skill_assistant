import 'dart:convert';

import 'package:bns_skill_assistant/controller/cache_manager.dart';
import 'package:bns_skill_assistant/tools/screen_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorData {
  var pixel = Pixel(0, 0, 0).obs;
  var name = ''.obs;

  var isEditing = false.obs;

  ColorData(Pixel pixel, String name) {
    this.pixel.value = pixel;
    this.name.value = name;
  }

  factory ColorData.fromJson(Map<String, dynamic> json) {
    return ColorData(Pixel.fromJson(json['pixel']), json['name']);
  }

  Map<String, dynamic> toJson() {
    return {
      'pixel': pixel.value.toJson(),
      'name': name.value,
    };
  }
}

class ColorLibraryController extends GetxController {
  static const String _key = 'color_library';

  final colors = <ColorData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initFromCache();
  }

  void _initFromCache() async {
    final json = await CacheManager.getList(_key);
    if (json != null) {
      colors.value = List<ColorData>.from(json.map((x) => ColorData.fromJson(x)));
    }
  }

  removeData(ColorData data) {
    colors.remove(data);
  }

  save() {
    final data = colors.map((e) => e.toJson()).toList();
    CacheManager.set(_key, jsonEncode(data));
  }
}