import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'key_event.dart';

typedef KeyListener = bool Function(KeyEvent event);

int lowlevelKeyboardHookProc(int code, int wParam, int lParam) {
  if (code == HC_ACTION) {
    // Windows controls this memory; don't deallocate it.
    final kbs = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam);
    final event = KeyEvent();
    event.keyCode = kbs.ref.vkCode;
    if (wParam == WM_KEYDOWN) {
      event.type = EventType.keyDown;
    } else if (wParam == WM_KEYUP) {
      event.type = EventType.keyUp;
    }

    _sendPort?.send(event);
  }
  return CallNextHookEx(KeyHookManager.keyHook, code, wParam, lParam);
}

int lowlevelMouseHookProc(int code, int wParam, int lParam) {
  // log('lowlevelMouseHookProc wParam: $wParam');
  if (code == HC_ACTION) {
    // Windows controls this memory; don't deallocate it.
    final kbs = Pointer<MSLLHOOKSTRUCT>.fromAddress(lParam);
    final event = KeyEvent();
    if (wParam == WM_LBUTTONDOWN) {
      event.keyCode = mouseLeftButton;
      event.type = EventType.keyDown;
    } else if (wParam == WM_LBUTTONUP) {
      event.keyCode = mouseLeftButton;
      event.type = EventType.keyUp;
    } else if (wParam == WM_XBUTTONDOWN) {
      event.keyCode = mouseXButton;
      event.type = EventType.keyDown;
    } else if (wParam == WM_XBUTTONUP) {
      event.keyCode = mouseXButton;
      event.type = EventType.keyUp;
    } else if (wParam == WM_RBUTTONDOWN) {
      event.keyCode = mouseRightButton;
      event.type = EventType.keyDown;
    } else if (wParam == WM_RBUTTONUP) {
      event.keyCode = mouseRightButton;
      event.type = EventType.keyUp;
    } else {
      return CallNextHookEx(KeyHookManager.mouseHook, code, wParam, lParam);
    }

    _sendPort?.send(event);
  }
  return CallNextHookEx(KeyHookManager.mouseHook, code, wParam, lParam);
}

final lpfn = NativeCallable<HOOKPROC>.isolateLocal(
  lowlevelKeyboardHookProc,
  exceptionalReturn: 0,
);

final lpmousefn = NativeCallable<HOOKPROC>.isolateLocal(
  lowlevelMouseHookProc,
  exceptionalReturn: 0,
);

void startIsolate() async {
  // 创建 ReceivePort 以接收来自新 Isolate 的消息
  ReceivePort receivePort = ReceivePort();

  // 创建并启动新的 Isolate
  Isolate.spawn(isolateEntry, receivePort.sendPort);

  // 监听从 Isolate 发送过来的消息
  receivePort.listen((data) {
    KeyHookManager.onKeyEvent(data as KeyEvent);
  });
}

SendPort? _sendPort;

// 运行在新 Isolate 中的函数
void isolateEntry(SendPort sendPort) {
  _sendPort = sendPort;
  KeyHookManager.keyHook = SetWindowsHookEx(
      WINDOWS_HOOK_ID.WH_KEYBOARD_LL, lpfn.nativeFunction, NULL, 0);

  KeyHookManager.mouseHook = SetWindowsHookEx(
      WINDOWS_HOOK_ID.WH_MOUSE_LL, lpmousefn.nativeFunction, NULL, 0);

  final msg = calloc<MSG>();
  while (GetMessage(msg, NULL, 0, 0) != 0) {
    TranslateMessage(msg);
    DispatchMessage(msg);
  }
}

class KeyHookManager {
  static void init() {
    startIsolate();
  }

  static void onKeyEvent(KeyEvent event) {
    log('onKeyEvent: $event');
    final needRemoveListeners = <KeyListener>[];
    for (final listener in _listeners) {
      if (listener(event)) {
        needRemoveListeners.add(listener);
      }
    }

    for (final listener in needRemoveListeners) {
      removeListener(listener);
    }
  }

  static String getForegroundWindowInfo() {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - _lastUpdateWindowsInfoTime < 5000) {
      return _windowsInfo;
    }

    _lastUpdateWindowsInfoTime = now;

    // 获取前台窗口句柄
    final hwnd = GetForegroundWindow();

    // 获取窗口标题
    final length = GetWindowTextLength(hwnd);
    final buffer = wsalloc(length + 1);
    GetWindowText(hwnd, buffer, length + 1);
    final windowTitle = buffer.toDartString();
    free(buffer);

    // 获取窗口所属进程ID
    final lpdwProcessId = calloc<Uint32>();
    GetWindowThreadProcessId(hwnd, lpdwProcessId);

    // 打开进程以查询信息
    final hProcess = OpenProcess(PROCESS_ACCESS_RIGHTS.PROCESS_QUERY_INFORMATION | PROCESS_ACCESS_RIGHTS.PROCESS_VM_READ, FALSE, lpdwProcessId.value);
    final processPathBuffer = wsalloc(MAX_PATH);
    if (GetModuleFileNameEx(hProcess, NULL, processPathBuffer, MAX_PATH) > 0) {
      _windowsInfo = processPathBuffer.toDartString();
    }
    free(processPathBuffer);
    CloseHandle(hProcess);
    calloc.free(lpdwProcessId);

    return _windowsInfo;
  }

  static void sendInput(KeyEvent event) {
    if (event.keyCode == mouseLeftButton) {
      final mouseInput = calloc<MOUSEINPUT>();
      mouseInput.ref.dwFlags = event.type == EventType.keyDown ? MOUSE_EVENT_FLAGS.MOUSEEVENTF_LEFTDOWN : MOUSE_EVENT_FLAGS.MOUSEEVENTF_LEFTUP;

      final input = calloc<INPUT>();

      input.ref.type = INPUT_TYPE.INPUT_MOUSE;
      input.ref.mi = mouseInput.ref;

      SendInput(1, Pointer.fromAddress(input.address), sizeOf<MOUSEINPUT>());
      calloc.free(mouseInput);
      calloc.free(input);
    } else if (event.keyCode == mouseRightButton) {
      final mouseInput = calloc<MOUSEINPUT>();
      mouseInput.ref.dwFlags = event.type == EventType.keyDown ? MOUSE_EVENT_FLAGS.MOUSEEVENTF_RIGHTDOWN : MOUSE_EVENT_FLAGS.MOUSEEVENTF_RIGHTUP;

      final input = calloc<INPUT>();

      input.ref.type = INPUT_TYPE.INPUT_MOUSE;
      input.ref.mi = mouseInput.ref;

      SendInput(1, Pointer.fromAddress(input.address), sizeOf<MOUSEINPUT>());
      calloc.free(mouseInput);
      calloc.free(input);
    } else {
      final input = calloc<INPUT>();
      input.ref.type = INPUT_TYPE.INPUT_KEYBOARD;
      input.ref.ki.wVk = event.keyCode;
      input.ref.ki.dwFlags = event.type == EventType.keyDown ? 0 : KEYBD_EVENT_FLAGS.KEYEVENTF_KEYUP;
      SendInput(1, Pointer.fromAddress(input.address), sizeOf<INPUT>());
      calloc.free(input);
    }
  }

  static Future<KeyEvent?> nextKey({int? timeout}) {
    final controller = Completer<KeyEvent?>();
    listener(KeyEvent event) {
      controller.complete(event);
      return true;
    }
    addListener(listener);
    if (timeout != null && timeout > 0) {
      controller.future.timeout(Duration(milliseconds: timeout), onTimeout: () {
        controller.complete(null);
        removeListener(listener);
        return null;
      });
    }

    return controller.future;
  }

  static Future<bool> waitKey(KeyEvent event, {int? timeout}) async {
    final controller = Completer<bool>();
    listener(KeyEvent e) {
      if (e == event) {
        controller.complete(true);
        return true;
      }
      return false;
    }
    addListener(listener);
    if (timeout != null && timeout > 0) {
      controller.future.timeout(Duration(milliseconds: timeout), onTimeout: () {
        controller.complete(false);
        removeListener(listener);
        return false;
      });
    }

    return controller.future;
  }

  static void addListener(KeyListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(KeyListener listener) {
    _listeners.remove(listener);
  }

  static int _lastUpdateWindowsInfoTime = 0;
  static String _windowsInfo = '';
  static int keyHook = 0;
  static int mouseHook = 0;
  static final _listeners = <KeyListener>[];

}