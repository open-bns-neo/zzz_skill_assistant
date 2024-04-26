import 'dart:developer';

import 'package:bns_skill_assistant/services/key_event.dart';
import 'package:bns_skill_assistant/services/key_hook_manager.dart';
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

    return await KeyHookManager.waitKey(KeyEvent(keyCode: event.keyCode, type: EventType.keyUp), timeout: 500);
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

    ret = await WaitForClickAction(event, timeout: 500).execute(context);
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

abstract class SkillCombo {
  List<Action> getActions();

  Future<void> start() async {
    active = true;
    while (active) {
      for (final action in getActions()) {
        if (!active) {
          break;
        }
        final context = ActionContext();
        final result = await action.execute(context);
        if (!result) {
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
      WaitForDoubleClickAction(KeyEvent(keyCode: mouseXButton),),
      WaitAction(100),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_W)),
      WaitAction(100),
      PressKeyAction(KeyEvent(keyCode: VIRTUAL_KEY.VK_W)),
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
