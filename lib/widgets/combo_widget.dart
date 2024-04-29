import 'package:bns_skill_assistant/tools/screen_color_picker.dart';
import 'package:flutter/material.dart';

import '../controller/skill_data_controller.dart';
import '../services/skill_combo.dart';
import '../services/key_event.dart' as $key;
import 'action_widget.dart';
import 'editable_text.dart';

class ComboWidget extends StatefulWidget {
  final SkillComboController skill;

  const ComboWidget(this.skill, {super.key});

  @override
  State createState() => _ComboWidgetState();
}

class _ComboWidgetState extends State<ComboWidget> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: skill.active ? Theme.of(context).primaryColorLight : Theme.of(context).disabledColor,
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: EditableTextWidget(
              skill.name,
              onChanged: (value) {
                skill.name = value;
              },
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: _buildSkillRow(skill.actions),
          ),
          const SizedBox(
            width: 20,
          ),
          Checkbox(
            value: skill.active,
            onChanged: (enable) {
              if (enable == true) {
                skill.active = true;
              } else {
                skill.active = false;
              }
              skill.onChange();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRow(List<SkillAction> actions) {
    if (actions.isEmpty) {
      return _buildAddActionMenu((actions) => {
        _addSkillAction(actions, -1),
      });
    }

    return Scrollbar(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: ListView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final action in actions)
                  ...[
                    ActionWidget(
                      key: ValueKey(action),
                      action,
                      onDeleted: () {
                        widget.skill.removeAction(action);
                      },
                      onChanged: () {
                        widget.skill.onChange();
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      width: 4,
                      height: 40,
                      color: Colors.redAccent,
                    ),
                    _buildAddActionMenu((newAction) {
                      _addSkillAction(newAction, actions.indexOf(action) + 1);
                    }),
                  ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddActionMenu(Function(SkillAction) onAddAction) {
    return MenuAnchor(
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.add),
            tooltip: '增加动作',
          );
        },
        menuChildren: [
          for (final type in SkillDataController.skillTypes.entries)
            MenuItemButton(
              onPressed: () {
                final actionType = type.key;
                final action = _buildAction(actionType);
                if (action != null) {
                  onAddAction(action);
                }
              },
              child: Text(type.value),
            ),
        ]
    );
  }

  SkillAction? _buildAction(Type actionType) {
    SkillAction? action;
    switch (actionType) {
      case const (WaitAction):
        action = WaitAction(0);
        break;
      case const (WaitForKeyAction):
        action = WaitForKeyAction($key.KeyEvent());
        break;
      case const (WaitForClickAction):
        action = WaitForClickAction($key.KeyEvent());
        break;
      case const (WaitForDoubleClickAction):
        action = WaitForDoubleClickAction($key.KeyEvent());
        break;
      case const (PressKeyAction):
        action = PressKeyAction($key.KeyEvent());
        break;
      case const (ColorTestAction):
        action = ColorTestAction(Pixel(0, 0, 0));
        break;
      case const (WaitComposeKeyAction):
        action = WaitComposeKeyAction([]);
        break;
    }
    return action;
  }

  void _addSkillAction(SkillAction action, int index) {
    widget.skill.addAction(action, index: index);
  }
}