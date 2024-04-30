import 'package:bns_skill_assistant/controller/skill_data_controller.dart';
import 'package:bns_skill_assistant/services/skill_combo.dart';
import 'package:bns_skill_assistant/widgets/delete_widget.dart';
import 'package:bns_skill_assistant/widgets/util/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:flutter/material.dart';

import 'combo_widget.dart';

class CombosPage extends StatefulWidget {
  final TabPageController _controller;

  const CombosPage(this._controller, {super.key});

  @override
  State createState() => _CombosPageState();
}

class _CombosPageState extends State<CombosPage> {
  final _activeManager = ComboActiveManager();

  @override
  void initState() {
    super.initState();
    _activeManager.addListener(_onStateChanged);
    widget._controller.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _activeManager.removeListener(_onStateChanged);
    widget._controller.removeListener(_onStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget._controller;
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final skill in tab.skills)
                _buildSkill(skill),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                tab.addSkill(SkillComboController());
              },
              child: const Text('添加卡刀组'),
            ),
            const SizedBox(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: isActive() ? ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).disabledColor),
                  ) : null,
                  onPressed: () {
                    if (isActive()) {
                      _activeManager.disable();
                      notify.info('已关闭', context);
                    } else {
                      _activeManager.active(tab);
                      notify.success('已激活当前页面', context);
                    }
                  },
                  child: isActive() ? Text('取消激活', style: TextStyle(color: Theme.of(context).colorScheme.error),) : const Text('激活'),
                ),
                const SizedBox(width: 5,),
                const Text(
                  '快捷键: Ctrl + K',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkill(SkillComboController skill) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ComboWidget(skill),
              ),
              Column(
                children: [
                  _buildLockIcon(skill),
                  _buildCopyIcon(skill),
                  if (!skill.lock)
                    DeleteWidget(
                      size: 18,
                      onDelete: () {
                        widget._controller.removeSkill(skill);
                      },
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }

  Widget _buildLockIcon(SkillComboController skill) {
    return IconButton(
      onPressed: () {
        skill.lock = !skill.lock;
        setState(() {});
      },
      icon: skill.lock ? const Icon(Icons.lock, color: Colors.red, size: 18) : const Icon(Icons.lock_open, size: 18,)
    );
  }

  Widget _buildCopyIcon(SkillComboController skill) {
    return IconButton(
      onPressed: () {
        final newSkill = SkillComboController(
          name: skill.name,
          actions: skill.actions.map((e) => e.copy()).toList(),
          active: skill.active,
          lock: skill.lock,
        );
        widget._controller.addSkill(newSkill);
      },
      icon: const Icon(Icons.copy, size: 18,)
    );
  }

  bool isActive() {
    return _activeManager.isActive;
  }
}