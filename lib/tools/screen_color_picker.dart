import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:isolate';

import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

class Pixel {
  final int x;
  final int y;
  final int color;

  Pixel(this.x, this.y, this.color);
}

class ScreenColorPicker {
  static int _globalScreenSnapshot = 0;
  static bool _isColorPicking = false;
  static Completer<Pixel?>? _completer;

  static Future<Pixel?> pickColorAsync() async {
    if (_isColorPicking) {
      return null;
    }

    _isColorPicking = true;
    _completer = Completer();
    pickColor();
    final color = await _completer!.future;
    _isColorPicking = false;
    return color;
  }

  static void _captureScreenSnapshot() {
    final hdcScreen = GetDC(NULL);
    final screenWidth = GetSystemMetrics(SM_CXSCREEN);
    final screenHeight = GetSystemMetrics(SM_CYSCREEN);

    final hdcMem = CreateCompatibleDC(hdcScreen);
    _globalScreenSnapshot = CreateCompatibleBitmap(hdcScreen, screenWidth, screenHeight);
    SelectObject(hdcMem, _globalScreenSnapshot);

    BitBlt(hdcMem, 0, 0, screenWidth, screenHeight, hdcScreen, 0, 0, SRCCOPY);

    DeleteDC(hdcMem);
    ReleaseDC(NULL, hdcScreen);
  }

  static int _windowProc(int hWnd, int uMsg, int wParam, int lParam) {
    switch (uMsg) {
      case WM_DESTROY:
        PostQuitMessage(0);
        return 0;

      case WM_LBUTTONDOWN:
        final hdcScreen = GetDC(NULL);
        final x = LOWORD(lParam);
        final y = HIWORD(lParam);
        final color = GetPixel(hdcScreen, x, y);
        ReleaseDC(NULL, hdcScreen);
        _completer?.complete(Pixel(x, y, color));
        DeleteObject(_globalScreenSnapshot);
        DestroyWindow(hWnd);
        return 0;

      case WM_MOUSEMOVE:
        InvalidateRect(hWnd, nullptr, TRUE); // Force window to repaint
        return 0;

      case WM_PAINT:
        final ps = calloc<PAINTSTRUCT>();
        final hdc = BeginPaint(hWnd, ps);

        final hdcMem = CreateCompatibleDC(hdc);
        SelectObject(hdcMem, _globalScreenSnapshot);

        final screenWidth = GetSystemMetrics(SM_CXSCREEN);
        final screenHeight = GetSystemMetrics(SM_CYSCREEN);
        BitBlt(hdc, 0, 0, screenWidth, screenHeight, hdcMem, 0, 0, SRCCOPY);

        // 获取鼠标位置
        final point = calloc<POINT>();
        GetCursorPos(point);
        ScreenToClient(hWnd, point);

        // 获取鼠标位置的颜色
        final color = GetPixel(hdcMem, point.ref.x, point.ref.y);

        // 绘制鼠标位置和颜色信息
        final brush = CreateSolidBrush(RGB(255, 255, 255)); // 白色背景
        final rect = calloc<RECT>()
          ..ref.left = point.ref.x + 20
          ..ref.top = point.ref.y
          ..ref.right = point.ref.x + 150
          ..ref.bottom = point.ref.y + 20;
        FillRect(hdc, rect, brush);
        SetBkMode(hdc, TRANSPARENT);
        SetTextColor(hdc, RGB(0, 0, 0)); // 黑色文字

        final colorText = TEXT('颜色: #${color.toRadixString(16).padLeft(6, '0').toUpperCase()}');
        DrawText(hdc, colorText, -1, rect, DT_LEFT);

        // 清理资源
        DeleteObject(brush);
        DeleteDC(hdcMem);
        calloc.free(rect);

        EndPaint(hWnd, ps);
        calloc.free(ps);
        return 0;

      default:
        return DefWindowProc(hWnd, uMsg, wParam, lParam);
    }
  }

  static void pickColor() {
    final hInstance = GetModuleHandle(nullptr);
    final wndClass = calloc<WNDCLASS>();
    wndClass.ref.lpfnWndProc = Pointer.fromFunction<WNDPROC>(_windowProc, 0);
    wndClass.ref.hInstance = hInstance;
    wndClass.ref.hCursor = LoadCursor(NULL, IDC_ARROW);
    wndClass.ref.lpszClassName = TEXT('screen_color_picker_class');
    RegisterClass(wndClass);

    final hWnd = CreateWindowEx(
        0,
        wndClass.ref.lpszClassName,
        TEXT('Screen Color Picker'),
        WINDOW_STYLE.WS_POPUP | WINDOW_STYLE.WS_VISIBLE,
        0,
        0,
        GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CXSCREEN),
        GetSystemMetrics(SYSTEM_METRICS_INDEX.SM_CYSCREEN),
        NULL,
        NULL,
        hInstance,
        nullptr);

    _captureScreenSnapshot();

    SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SET_WINDOW_POS_FLAGS.SWP_NOMOVE | SET_WINDOW_POS_FLAGS.SWP_NOSIZE);
    ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_SHOW);
    UpdateWindow(hWnd);

    UnregisterClass(wndClass.ref.lpszClassName, hInstance);
    calloc.free(wndClass);
  }
}