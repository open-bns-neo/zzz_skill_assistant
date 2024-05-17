import 'package:flutter/material.dart';

class HoverAnimatedContainer extends StatefulWidget {
  final Widget child;

  const HoverAnimatedContainer({super.key, required this.child});

  @override
  State createState()  {
    return _HoverAnimatedContainerState();
  }
}

class _HoverAnimatedContainerState extends State<HoverAnimatedContainer> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _onHover(true),
      onExit: (event) => _onHover(false),
      cursor: _isHovering ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        // transform: _isHovering ? hoverTransform : nonHoverTransform,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: _isHovering
              ? [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }
}