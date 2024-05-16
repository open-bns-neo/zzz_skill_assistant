import 'dart:async';
import 'dart:developer';

import 'package:bns_skill_assistant/services/key_event.dart';
import 'package:bns_skill_assistant/services/key_hook_manager.dart';
import 'package:bns_skill_assistant/tools/screen_color_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:win32/win32.dart';

part 'skill_combo.g.dart';

class ActionContext {
}

enum ActionType {
  waitForKey,
  waitForClick,
  waitForDoubleClick,
  pressKey,
  wait,
  screenColorPicker,
  waitComposeKey,
  colorTest,
}

abstract interface class SkillAction {
  Future<bool> execute(ActionContext context);

  factory SkillAction.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == _$ActionTypeEnumMap[ActionType.waitForKey]) {
      return WaitForKeyAction.fromJson(json);
    }
    if (type == _$ActionTypeEnumMap[ActionType.waitForClick]) {
      return WaitForClickAction.fromJson(json);
    }
    if (type == _$ActionTypeEnumMap[ActionType.waitForDoubleClick]) {
      return WaitForDoubleClickAction.fromJson(json);
    }
    if (type == _$ActionTypeEnumMap[ActionType.pressKey]) {
      return PressKeyAction.fromJson(json);
    }
    if (type == _$ActionTypeEnumMap[ActionType.wait]) {
      return WaitAction.fromJson(json);
    }
    if (type == _$ActionTypeEnumMap[ActionType.screenColorPicker]) {
      return ScreenColorPickerAction.fromJson(json);
    }
    if (type == _$ActionTypeEnumMap[ActionType.waitComposeKey]) {
      return WaitComposeKeyAction.fromJson(json);
    }
    if (type == _$ActionTypeEnumMap[ActionType.colorTest]) {
      return ColorTestAction.fromJson(json);
    }
    throw 'Unknown type: $type';
  }

  Map<String, dynamic> toJson();

  SkillAction copy();
}

@JsonSerializable()
class WaitForKeyAction implements SkillAction {
  @JsonKey(includeToJson: true, includeFromJson: true)
  final type = ActionType.waitForKey;
  KeyEvent event;
  final int? timeout;
  WaitForKeyAction(this.event, {this.timeout});

  @override
  Future<bool> execute(ActionContext context) async {
    log('WaitForKeyAction execute: ${toJson()}');
    return await KeyHookManager.waitKey(event, timeout: timeout);
  }

  factory WaitForKeyAction.fromJson(Map<String, dynamic> json) => _$WaitForKeyActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WaitForKeyActionToJson(this);

  @override
  SkillAction copy() {
    return WaitForKeyAction(KeyEvent(keyCode: event.keyCode, type: event.type), timeout: timeout);
  }
}

@JsonSerializable()
class WaitForClickAction implements SkillAction {
  @JsonKey(includeToJson: true, includeFromJson: true)
  final type = ActionType.waitForClick;
  final KeyEvent event;
  final int? timeout;
  WaitForClickAction(this.event, {this.timeout});

  @override
  Future<bool> execute(ActionContext context) async {
    log('WaitForClickAction execute: ${toJson()}');
    final ret = await KeyHookManager.waitKey(KeyEvent(keyCode: event.keyCode, type: EventType.keyDown), timeout: timeout);
    if (!ret) {
      return false;
    }

    return await KeyHookManager.waitKey(KeyEvent(keyCode: event.keyCode, type: EventType.keyUp), timeout: 300);
  }

  factory WaitForClickAction.fromJson(Map<String, dynamic> json) => _$WaitForClickActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WaitForClickActionToJson(this);

  @override
  SkillAction copy() {
    return WaitForClickAction(KeyEvent(keyCode: event.keyCode, type: event.type), timeout: timeout);
  }
}

@JsonSerializable()
class WaitForDoubleClickAction implements SkillAction {
  @JsonKey(includeToJson: true, includeFromJson: true)
  final type = ActionType.waitForDoubleClick;
  final KeyEvent event;
  final int? timeout;
  WaitForDoubleClickAction(this.event, {this.timeout});

  @override
  Future<bool> execute(ActionContext context) async {
    log('WaitForDoubleClickAction execute: ${toJson()}');
    var ret = await WaitForClickAction(event, timeout: timeout).execute(context);
    if (!ret) {
      return false;
    }

    ret = await WaitForClickAction(event, timeout: 300).execute(context);
    return ret;
  }

  factory WaitForDoubleClickAction.fromJson(Map<String, dynamic> json) => _$WaitForDoubleClickActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WaitForDoubleClickActionToJson(this);

  @override
  SkillAction copy() {
    return WaitForDoubleClickAction(KeyEvent(keyCode: event.keyCode, type: event.type), timeout: timeout);
  }
}

@JsonSerializable()
class PressKeyAction implements SkillAction {
  @JsonKey(includeToJson: true, includeFromJson: true)
  final type = ActionType.pressKey;
  final KeyEvent event;
  PressKeyAction(this.event);

  @override
  Future<bool> execute(ActionContext context) async {
    log('PressKeyAction execute: ${toJson()}');
    final downEvent = KeyEvent(keyCode: event.keyCode, type: EventType.keyDown);
    final upEvent = KeyEvent(keyCode: event.keyCode, type: EventType.keyUp);
    KeyHookManager.sendInput(downEvent);
    await Future.delayed(const Duration(milliseconds: 16));
    KeyHookManager.sendInput(upEvent);
    return true;
  }

  factory PressKeyAction.fromJson(Map<String, dynamic> json) => _$PressKeyActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PressKeyActionToJson(this);

  @override
  SkillAction copy() {
    return PressKeyAction(KeyEvent(keyCode: event.keyCode, type: event.type));
  }
}

@JsonSerializable()
class WaitAction implements SkillAction {
  @JsonKey(includeToJson: true, includeFromJson: true)
  final type = ActionType.wait;
  int duration;
  WaitAction(this.duration);

  @override
  Future<bool> execute(ActionContext context) async {
    log('WaitAction execute: ${toJson()}');
    await Future.delayed(Duration(milliseconds: duration));
    return true;
  }

  factory WaitAction.fromJson(Map<String, dynamic> json) => _$WaitActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WaitActionToJson(this);

  @override
  SkillAction copy() {
    return WaitAction(duration);
  }
}

@JsonSerializable()
class ScreenColorPickerAction implements SkillAction {
  @JsonKey(includeToJson: true, includeFromJson: true)
  final type = ActionType.screenColorPicker;
  Pixel? color;
  ScreenColorPickerAction();

  @override
  Future<bool> execute(ActionContext context) async {
    log('ScreenColorPickerAction execute: ${toJson()}');
    color = await ScreenColorPicker.pickColorAsync();
    log('鼠标位置: (${color?.x}, ${color?.y})');
    log('颜色: ${color?.color} #${color?.color.toRadixString(16).padLeft(6, '0').toUpperCase()}');
    return color != null;
  }

  factory ScreenColorPickerAction.fromJson(Map<String, dynamic> json) => _$ScreenColorPickerActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ScreenColorPickerActionToJson(this);

  @override
  SkillAction copy() {
    return ScreenColorPickerAction();
  }
}

@JsonSerializable()
class WaitComposeKeyAction implements SkillAction {
  @JsonKey(includeToJson: true, includeFromJson: true)
  final type = ActionType.waitComposeKey;
  final List<int> events;
  WaitComposeKeyAction(this.events);

  @override
  Future<bool> execute(ActionContext context) async {
    // log('WaitComposeKeyAction execute: ${toJson()}');
    for (final event in events) {
      final ret = await KeyHookManager.nextKey(timeout: 1000);
      if (ret?.keyCode != event || ret?.type != EventType.keyDown) {
        return false;
      }
    }
    return true;
  }

  factory WaitComposeKeyAction.fromJson(Map<String, dynamic> json) => _$WaitComposeKeyActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WaitComposeKeyActionToJson(this);

  @override
  SkillAction copy() {
    return WaitComposeKeyAction(events);
  }
}

@JsonSerializable()
class ColorTestAction implements SkillAction {
  @JsonKey(includeToJson: true, includeFromJson: true)
  final type = ActionType.colorTest;
  Pixel pixel;
  ColorTestAction(this.pixel);

  @override
  Future<bool> execute(ActionContext context) async {
    log('ColorTestAction execute: ${toJson()}');
    final hdcScreen = GetDC(NULL);
    final pix = GetPixel(hdcScreen, pixel.x, pixel.y);
    // log('ColorTestAction 颜色: $pix ${pixel.color}');
    return pix == pixel.color;
  }

  factory ColorTestAction.fromJson(Map<String, dynamic> json) => _$ColorTestActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ColorTestActionToJson(this);

  @override
  SkillAction copy() {
    return ColorTestAction(pixel);
  }
}

class CustomAction implements SkillAction {
  final FutureOr<bool> Function() action;
  CustomAction(this.action);

  @override
  Future<bool> execute(ActionContext context) async {
    final ret = await action();
    return ret;
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  SkillAction copy() {
    return CustomAction(action);
  }
}

abstract class SkillCombo {
  List<SkillAction> getActions();

  Future<void> start({
    bool onlyActiveOnSpecificPrograms = false,
    List<String> specificPrograms = const [],
  }) async {
    active = true;
    while (active) {
      final actions = getActions();
      if (actions.isEmpty) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 1));

      if (onlyActiveOnSpecificPrograms) {
        final runningProgram = KeyHookManager.getForegroundWindowInfo();
        if (!specificPrograms.any((element) => runningProgram.contains(element))) {
          continue;
        }
      }

      for (final action in getActions()) {
        if (!active) {
          break;
        }
        final context = ActionContext();
        try {
          final result = await action.execute(context);
          if (!result) {
            break;
          }
        } catch (e) {
          log('Action error: $e');
          break;
        }
      }
    }
  }

  void stop() {
    active = false;
  }

  bool active = false;
}

class TestSkillCombo extends SkillCombo {
  @override
  List<SkillAction> getActions() {
    return [
      WaitAction(100),
    ];
  }
}

class PickColor extends SkillCombo {
  @override
  List<SkillAction> getActions() {
    return [
      WaitComposeKeyAction([VIRTUAL_KEY.VK_LCONTROL, VIRTUAL_KEY.VK_P]),
      WaitAction(100),
      ScreenColorPickerAction(),
    ];
  }
}

class CustomCombo extends SkillCombo {
  final List<SkillAction> actions;

  CustomCombo(this.actions);

  @override
  List<SkillAction> getActions() {
    return actions;
  }
}

class JianShiCombo extends SkillCombo {
  @override
  List<SkillAction> getActions() {
    return [
      WaitForKeyAction(KeyEvent(keyCode: mouseLButton)),
      ColorTestAction(Pixel(1871, 1979, 15558)),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_4)),
    ];
  }
}

class QiGongComboSkillL extends SkillCombo {
  @override
  List<SkillAction> getActions() {
    return [
      WaitForKeyAction(KeyEvent(keyCode: mouseRButton)),
      WaitAction(500),
      // 自动左键
      PressKeyAction(KeyEvent(keyCode: mouseLButton)),
    ];
  }
}

class QiGongComboSkill2 extends SkillCombo {
  @override
  List<SkillAction> getActions() {
    return [
      WaitForKeyAction(KeyEvent(keyCode: mouseRButton)),
      WaitAction(500),
      ColorTestAction(Pixel(1720, 1952, 1661608)),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_2)),
    ];
  }
}

class QiGongComboSkillFIce extends SkillCombo {
  @override
  List<SkillAction> getActions() {
    return [
      WaitAction(50),
      ColorTestAction(Pixel(2376, 1294, 7551515)),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_F)),
    ];
  }
}

class QiGongComboSkillFFire extends SkillCombo {
  @override
  List<SkillAction> getActions() {
    return [
      WaitAction(50),
      ColorTestAction(Pixel(2372, 1297, 8321279)),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_F)),
    ];
  }
}

class SSCombo extends SkillCombo {
  @override
  List<SkillAction> getActions() {
    return [
      WaitForClickAction(KeyEvent(keyCode: mouseXButton),),
      WaitAction(100),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_S)),
      WaitAction(100),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_S)),
    ];
  }
}
