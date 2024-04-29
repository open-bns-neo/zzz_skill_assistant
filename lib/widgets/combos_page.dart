import 'package:bns_skill_assistant/controller/skill_data_controller.dart';
import 'package:bns_skill_assistant/widgets/delete_widget.dart';
import 'package:bns_skill_assistant/widgets/util/notification.dart';
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
        ListView.builder(
          shrinkWrap: true,
          itemCount: tab.skills.length,
          itemBuilder: (context, index) {
            final skill = tab.skills[index];
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ComboWidget(skill),
                    ),
                    DeleteWidget(
                      onDelete: () {
                        tab.removeSkill(skill);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
              ],
            );
          },
        ),
        const SizedBox(height: 10,),
        ElevatedButton(
          onPressed: () {
            tab.addSkill(SkillComboController());
          },
          child: const Text('添加卡刀组'),
        ),
        const Spacer(
        ),
        Row(
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
          ],
        ),
      ],
    );
  }

  bool isActive() {
    return _activeManager.isActive;
  }
}