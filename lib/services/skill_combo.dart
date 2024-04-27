import 'dart:developer';

import 'package:bns_skill_assistant/services/key_event.dart';
import 'package:bns_skill_assistant/services/key_hook_manager.dart';
import 'package:bns_skill_assistant/tools/screen_color_picker.dart';
import 'package:win32/win32.dart';

class ActionContext {
}

abstract interface class Action {
  Future<bool> execute(ActionContext context);
}

class WaitForKeyAction implements Action {
  final KeyEvent event;
  final int? timeout;
  WaitForKeyAction(this.event, {this.timeout});

  @override
  Future<bool> execute(ActionContext context) async {
    return await KeyHookManager.waitKey(event, timeout: timeout);
  }
}

class WaitForClickAction implements Action {
  final KeyEvent event;
  final int? timeout;
  WaitForClickAction(this.event, {this.timeout});

  @override
  Future<bool> execute(ActionContext context) async {
    final ret = await KeyHookManager.waitKey(KeyEvent(keyCode: event.keyCode, type: EventType.keyDown), timeout: timeout);
    if (!ret) {
      return false;
    }

    return await KeyHookManager.waitKey(KeyEvent(keyCode: event.keyCode, type: EventType.keyUp), timeout: 300);
  }
}

class WaitForDoubleClickAction implements Action {
  final KeyEvent event;
  final int? timeout;
  WaitForDoubleClickAction(this.event, {this.timeout});

  @override
  Future<bool> execute(ActionContext context) async {
    var ret = await WaitForClickAction(event, timeout: timeout).execute(context);
    if (!ret) {
      return false;
    }

    ret = await WaitForClickAction(event, timeout: 300).execute(context);
    return ret;
  }
}

class PressKeyAction implements Action {
  final KeyEvent event;
  PressKeyAction(this.event);

  @override
  Future<bool> execute(ActionContext context) async {
    final downEvent = KeyEvent(keyCode: event.keyCode, type: EventType.keyDown);
    final upEvent = KeyEvent(keyCode: event.keyCode, type: EventType.keyUp);
    KeyHookManager.sendInput(downEvent);
    await Future.delayed(const Duration(milliseconds: 16));
    KeyHookManager.sendInput(upEvent);
    return true;
  }
}

class WaitAction implements Action {
  final int duration;
  WaitAction(this.duration);

  @override
  Future<bool> execute(ActionContext context) async {
    await Future.delayed(Duration(milliseconds: duration));
    return true;
  }
}

class ScreenColorPickerAction implements Action {
  ScreenColorPickerAction();

  @override
  Future<bool> execute(ActionContext context) async {
    final color = await ScreenColorPicker.pickColorAsync();
    log('鼠标位置: (${color?.x}, ${color?.y})');
    log('颜色: ${color?.color} #${color?.color.toRadixString(16).padLeft(6, '0').toUpperCase()}');
    return color != null;
  }
}

class WaitComposeKeyAction implements Action {
  final List<int> events;
  WaitComposeKeyAction(this.events);

  @override
  Future<bool> execute(ActionContext context) async {
    for (final event in events) {
      final ret = await KeyHookManager.nextKey(timeout: 1000);
      if (ret?.keyCode != event) {
        return false;
      }
    }
    return true;
  }
}

class ColorTestAction implements Action {
  final Pixel pixel;
  ColorTestAction(this.pixel);

  @override
  Future<bool> execute(ActionContext context) async {
    final hdcScreen = GetDC(NULL);
    final pix = GetPixel(hdcScreen, pixel.x, pixel.y);
    // log('ColorTestAction 颜色: $pix ${pixel.color}');
    return pix == pixel.color;
  }
}

abstract class SkillCombo {
  List<Action> getActions();

  Future<void> start() async {
    active = true;
    while (active) {
      await Future.delayed(const Duration(milliseconds: 1));

      final runningProgram = KeyHookManager.getForegroundWindowInfo();
      if (!runningProgram.contains('bns')) {
        continue;
      }

      final actions = getActions();
      if (actions.isEmpty) {
        return;
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
  List<Action> getActions() {
    return [
      WaitAction(100),
    ];
  }
}

class PickColor extends SkillCombo {
  @override
  List<Action> getActions() {
    return [
      WaitComposeKeyAction([VIRTUAL_KEY.VK_LCONTROL, VIRTUAL_KEY.VK_P]),
      WaitAction(100),
      ScreenColorPickerAction(),
    ];
  }
}

class JianShiCombo extends SkillCombo {
  @override
  List<Action> getActions() {
    return [
      WaitForKeyAction(KeyEvent(keyCode: mouseLButton)),
      ColorTestAction(Pixel(1871, 1979, 15558)),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_4)),
    ];
  }
}

class QiGongComboSkillL extends SkillCombo {
  @override
  List<Action> getActions() {
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
  List<Action> getActions() {
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
  List<Action> getActions() {
    return [
      WaitAction(50),
      ColorTestAction(Pixel(2376, 1294, 7551515)),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_F)),
    ];
  }
}

class QiGongComboSkillFFire extends SkillCombo {
  @override
  List<Action> getActions() {
    return [
      WaitAction(50),
      ColorTestAction(Pixel(2372, 1297, 8321279)),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_F)),
    ];
  }
}

class SSCombo extends SkillCombo {
  @override
  List<Action> getActions() {
    return [
      WaitForClickAction(KeyEvent(keyCode: mouseXButton),),
      WaitAction(100),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_S)),
      WaitAction(100),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_S)),
    ];
  }
}
