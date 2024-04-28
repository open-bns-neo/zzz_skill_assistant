import 'package:bns_skill_assistant/services/skill_combo.dart';

class SkillComboService {
  SkillComboService._privateConstructor();

  static final SkillComboService _instance = SkillComboService._privateConstructor();

  List<SkillCombo> _runningCombos = [];

  factory SkillComboService() {
    return _instance;
  }

  final _backgroundCombos = <SkillCombo>[
    PickColor(),
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