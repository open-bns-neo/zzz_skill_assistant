import 'package:bns_skill_assistant/controller/skill_data_controller.dart';
import 'package:bns_skill_assistant/services/skill_combo.dart';
import 'package:win32/win32.dart';

class SkillComboService {
  SkillComboService._privateConstructor();

  static final SkillComboService _instance = SkillComboService._privateConstructor();

  List<SkillCombo> _runningCombos = [];

  factory SkillComboService() {
    return _instance;
  }

  final _backgroundCombos = <SkillCombo>[
    PickColor(),
    // 激活开关
    CustomCombo([
      WaitComposeKeyAction([VIRTUAL_KEY.VK_LCONTROL, VIRTUAL_KEY.VK_K]),
      WaitAction(100),
      CustomAction(() {
        final manager = ComboActiveManager();
        if (manager.isActive) {
          manager.disable();
        } else {
          manager.activeDefault();
        }
        return true;
      }),
    ]),
  ];

  void init() {
    for (var combo in _backgroundCombos) {
      combo.start();
    }
  }

  void startCombo(List<SkillCombo> combos) {
    if (combos.isEmpty) {
      return;
    }

    if (_runningCombos.isNotEmpty) {
      stopCombo();
    }

    _runningCombos = combos;

    for (var combo in _runningCombos) {
      combo.start();
    }
  }

  void stopCombo() {
    for (var combo in _runningCombos) {
      combo.stop();
    }
    _runningCombos.clear();
  }
}