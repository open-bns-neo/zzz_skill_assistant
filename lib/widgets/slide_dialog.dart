import 'package:flutter/material.dart';

class SlideDialog extends StatelessWidget {
  final Widget child;

  const SlideDialog({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width * 0.8;

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: GestureDetector(
          onTap: () {
          },
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: width,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

}