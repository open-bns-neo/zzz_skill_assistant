import 'package:bns_skill_assistant/controller/cache_manager.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {
  static const keyOnlyActiveOnSpecificPrograms = 'onlyActiveOnSpecificPrograms';
  static const keyActivePrograms = 'onlyActiveOnSpecificPrograms';

  final onlyActiveOnSpecificPrograms = false.obs;
  final activePrograms = <String>['bns'].obs;

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
  }

  void setOnlyActiveOnSpecificPrograms(bool value) {
    onlyActiveOnSpecificPrograms.value = value;
    CacheManager.set(keyOnlyActiveOnSpecificPrograms, value);
  }

  void setActivePrograms(List<String> value) {
    activePrograms.value = value;
    CacheManager.set(keyActivePrograms, value);
  }
}