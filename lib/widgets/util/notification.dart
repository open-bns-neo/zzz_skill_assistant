import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:toastification/toastification.dart';

final notify = _Notification();

class _Notification {
  void info(String message, BuildContext context) {
    show(message, context, type: ToastificationType.info);
  }

  void error(String message, BuildContext context) {
    show(message, context, type: ToastificationType.error);
  }

  void success(String message, BuildContext context) {
    show(message, context, type: ToastificationType.success);
  }

  void warning(String message, BuildContext context) {
    show(message, context, type: ToastificationType.warning);
  }

  void show(String message, BuildContext context, {ToastificationType type = ToastificationType.info}) {
    toast.toastification.show(
      context: context,
      type: type,
      autoCloseDuration: const Duration(seconds: 2),
      title: Text(message),
      style: ToastificationStyle.flat,
    );
  }
}