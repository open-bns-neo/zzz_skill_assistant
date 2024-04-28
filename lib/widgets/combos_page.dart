import 'package:bns_skill_assistant/controller/skill_data_controller.dart';
import 'package:flutter/material.dart';

import 'combo_widget.dart';

class CombosPage extends StatefulWidget {
  final TabPageController _controller;

  const CombosPage(this._controller, {super.key});

  @override
  State createState() => _CombosPageState();
}

class _CombosPageState extends State<CombosPage> {
  @override
  Widget build(BuildContext context) {
    final tab = widget._controller;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tab.skills.length,
            itemBuilder: (context, index) {
              final skill = tab.skills[index];
              return Row(
                children: [
                  Expanded(child: ComboWidget(skill)),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () {
                      tab.removeSkill(skill);
                    },
                  ),
                ],
              );
            },
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                tab.addSkill(SkillComboController());
              },
              child: const Text('添加技能'),
            ),

            const SizedBox(width: 40,),

            ElevatedButton(
              onPressed: () {
                tab.activeSkillCombo();
              },
              child: const Text('激活'),
            ),
          ],
        ),
      ],
    );
  }
}