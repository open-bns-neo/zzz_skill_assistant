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
}

class ColorLibraryController extends GetxController {
  final colors = <ColorData>[].obs;

  final testColor = Colors.yellow.obs;

  @override
  void onInit() {
    super.onInit();
    colors.add(ColorData(Pixel(0, 0, 0), '测试'));
  }

  removeData(ColorData data) {
    colors.remove(data);
  }
}