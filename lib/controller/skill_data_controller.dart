import 'package:bns_skill_assistant/services/skill_combo.dart';
import 'package:bns_skill_assistant/services/skill_combo_service.dart';
import 'package:flutter/cupertino.dart';

class TabPageController extends ChangeNotifier {
  final String title;
  final List<SkillComboController> skills;

  void activeSkillCombo() {
    final combos = skills.map((e) => _MySkillCombo(e.actions));
    SkillComboService().startCombo(combos.toList());
  }

  TabPageController(this.title, {required this.skills}) {
    for (final element in skills) {
      element.addListener(() {
        notifyListeners();
      });
    }
  }

  void addSkill(SkillComboController skill, {int index = -1}) {
    if (index >= 0 && index < skills.length) {
      skills.insert(index, skill);
      return;
    }
    skills.add(skill);
    skill.addListener(() {
      notifyListeners(); }
    );
    notifyListeners();
  }

  void removeSkill(SkillComboController skill) {
    skills.remove(skill);
    notifyListeners();
  }
}

class _MySkillCombo extends SkillCombo {
  final List<SkillAction> actions;

  _MySkillCombo(this.actions);

  @override
  List<SkillAction> getActions() {
    return actions;
  }

}

class SkillComboController extends ChangeNotifier {
  String name;
  final List<SkillAction> actions = [];

  SkillComboController({this.name = '未命名', List<SkillAction>? actions}) {
    actions?.forEach((element) {
      addAction(element);
    });
  }

  void addAction(SkillAction action, {int index = -1}) {
    if (index >= 0 && index < actions.length) {
      actions.insert(index, action);
    } else {
      actions.add(action);
    }

    notifyListeners();
  }

  void removeAction(SkillAction action) {
    actions.remove(action);
    notifyListeners();
  }
}

class SkillDataController extends ChangeNotifier {
  static Map<Type, String> get skillTypes => {
    WaitAction: '延迟',
    WaitForKeyAction: '等待按键',
    PressKeyAction: '输入按键',
    ColorTestAction: '进行取色测试',
    // WaitComposeKeyAction: '等待组合键',
  };

  final List<TabPageController> tabs = [
    TabPageController('剑士', skills: []),
  ];

  Future<void> init() async {
    for (final element in tabs) {
      element.addListener(() {
        notifyListeners();
      });
    }
    notifyListeners();
  }
}