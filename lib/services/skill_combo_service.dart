import 'package:bns_skill_assistant/services/skill_combo.dart';

class SkillComboService {
  SkillComboService._privateConstructor();

  static final SkillComboService _instance = SkillComboService._privateConstructor();

  factory SkillComboService() {
    return _instance;
  }

  final skillCombos = <SkillCombo>[
    TestSkillCombo(),
    SSCombo(),
  ];

  void start() {
    for (var combo in skillCombos) {
      combo.start();
    }
  }
}