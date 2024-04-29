import 'dart:ui';

import 'package:bns_skill_assistant/services/key_hook_manager.dart';
import 'package:bns_skill_assistant/services/skill_combo.dart';
import 'package:bns_skill_assistant/widgets/delete_widget.dart';
import 'package:bns_skill_assistant/widgets/util/key_image_loader.dart';
import 'package:bns_skill_assistant/widgets/util/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../controller/skill_data_controller.dart';
import '../services/key_event.dart' as $key;
import '../tools/screen_color_picker.dart';

class ActionWidget extends StatefulWidget {
  final SkillAction action;
  final SkillComboController controller;
  final Function()? onDeleted;
  final Function()? onChanged;

  const ActionWidget(this.action, this.controller, {super.key, this.onDeleted, this.onChanged});

  @override
  State createState() {
    if (action is WaitAction) {
      return _WaitActionState();
    }

    if (action is WaitForKeyAction) {
      return _WaitForKeyDownActionState();
    }

    if (action is PressKeyAction) {
      return _PressKeyActionState();
    }

    if (action is ColorTestAction) {
      return _ColorTestActionState();
    }

    return _ActionWidgetState();
  }
}

class _ActionWidgetState<T extends SkillAction> extends State<ActionWidget> {
  bool _isEditing = false;

  Widget buildNormal(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.error),
        Text("未知行为"),
      ],
    );
  }

  Widget buildEditing(BuildContext context) {
    return buildNormal(context);
  }

  T get action => widget.action as T;

  void save() {
    setState(() {
      _isEditing = false;
    });
    widget.onChanged?.call();
  }

  void onEdit() {
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          if (_isEditing)
            buildEditing(context)
          else
            buildNormal(context),

          const SizedBox(width: 10,),

          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: save,
              tooltip: "保存",
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                  width: 30,
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 15,
                    ),
                    tooltip: "编辑",
                    onPressed: widget.controller.lock ? null : () {
                      setState(() {
                        onEdit();
                        _isEditing = true;;
                      });
                    },
                  ),
                ),
                DeleteWidget(
                  size: 15,
                  enable: !widget.controller.lock,
                  onDelete: () {
                    setState(() {
                      widget.onDeleted?.call();
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WaitActionState extends _ActionWidgetState<WaitAction> {
  @override
  Widget buildNormal(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.timer),
        Text("${action.duration} ms"),
      ],
    );
  }

  @override
  Widget buildEditing(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.timer),
        SizedBox(
          width: 50,
          child: TextField(
            controller: TextEditingController(text: action.duration.toString()),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              action.duration = int.tryParse(value) ?? 0;
            },
          ),
        ),
      ],
    );
  }
}

class _WaitForKeyDownActionState extends _ActionWidgetState<WaitForKeyAction> {
  @override
  void initState() {
    super.initState();
  }

  bool _listenForKey($key.KeyEvent? event) {
    if (event == null) {
      return true;
    }
    action.event.keyCode = event.keyCode;
    save();
    return true;
  }

  @override
  void onEdit() {
    super.onEdit();
    KeyHookManager.addListener(_listenForKey);
  }

  @override
  Widget buildNormal(BuildContext context) {
    return Row(
      children: [
        const Text("当"),
        Image(
          width: 20,
          height: 20,
          image: KeyImageLoader.load(action.event.keyCode),
        ),
      ],
    );
  }

  @override
  Widget buildEditing(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.keyboard),
        Text(
          "等待按键...",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _PressKeyActionState extends _ActionWidgetState<PressKeyAction> {
  bool _listenForKey($key.KeyEvent? event) {
    if (event == null) {
      return true;
    }
    action.event.keyCode = event.keyCode;
    save();
    return true;
  }

  @override
  void onEdit() {
    super.onEdit();
    KeyHookManager.addListener(_listenForKey);
  }

  @override
  Widget buildNormal(BuildContext context) {
    return Row(
      children: [
        const Text("按下"),
        Image(
          width: 20,
          height: 20,
          image: KeyImageLoader.load(action.event.keyCode),
        ),
      ],
    );
  }

  @override
  Widget buildEditing(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.keyboard),
        Text(
          "等待按键...",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _ColorTestActionState extends _ActionWidgetState<ColorTestAction> {
  @override
  void initState() {
    super.initState();
    ScreenColorPicker.pickColorNotifier.addListener(onColorPicked);
  }

  @override
  void save() {
    super.save();
    ScreenColorPicker.pickColorNotifier.removeListener(onColorPicked);
  }

  @override
  void onEdit() {
    super.onEdit();
    ScreenColorPicker.pickColorNotifier.addListener(onColorPicked);
    notify.info('按下 CTRL + P 进行取色', context);
  }

  void onColorPicked() {
    final color = ScreenColorPicker.pickColorNotifier.value;
    if (color != null) {
      action.pixel = color;
      save();
    }
  }

  @override
  void dispose() {
    super.dispose();
    ScreenColorPicker.pickColorNotifier.removeListener(onColorPicked);
  }

  @override
  Widget buildNormal(BuildContext context) {
    final r = action.pixel.color & 0xFF;
    final g = (action.pixel.color >> 8) & 0xFF;
    final b = (action.pixel.color >> 16) & 0xFF;
    return Row(
      children: [
        Text("取色 x: ${action.pixel.x} y: ${action.pixel.y}"),
        const SizedBox(width: 5,),
        Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(r, g, b, 1),
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          width: 18,
          height: 18,
        ),
      ],
    );
  }

  @override
  Widget buildEditing(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.color_lens),
        Text("取色中..."),
      ],
    );
  }
}

