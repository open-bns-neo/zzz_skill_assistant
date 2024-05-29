import 'package:bns_skill_assistant/controller/cache_manager.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {
  static const keyOnlyActiveOnSpecificPrograms = 'onlyActiveOnSpecificPrograms';
  static const keyActivePrograms = 'onlyActiveOnSpecificPrograms';
  static const keyClickDelay = 'clickDelay';

  final onlyActiveOnSpecificPrograms = false.obs;
  final activePrograms = <String>['bns'].obs;
  final clickDelay = 50.obs;

  @override
  void onInit() {
    super.onInit();
    _initAsync();
  }

  void _initAsync() async {
    final onlyActiveOnSpecificProgramsValue = await CacheManager.get<bool>(keyOnlyActiveOnSpecificPrograms) ?? false;
    final activeProgramsValue = await CacheManager.get<List<String>>(keyActivePrograms) ?? <String>[];

    onlyActiveOnSpecificPrograms.value = onlyActiveOnSpecificProgramsValue;
    activePrograms.value = activeProgramsValue;
    clickDelay.value = await CacheManager.get<int>(keyClickDelay) ?? 50;
  }

  void setOnlyActiveOnSpecificPrograms(bool value) {
    onlyActiveOnSpecificPrograms.value = value;
    CacheManager.set(keyOnlyActiveOnSpecificPrograms, value);
  }

  void setActivePrograms(List<String> value) {
    activePrograms.value = value;
    CacheManager.set(keyActivePrograms, value);
  }

  void setClickDelay(int value) {
    clickDelay.value = value;
    CacheManager.set(keyClickDelay, value);
  }
}