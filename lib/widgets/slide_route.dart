import 'package:flutter/material.dart';

const Duration _bottomSheetEnterDuration = Duration(milliseconds: 250);
const Duration _bottomSheetExitDuration = Duration(milliseconds: 200);

/// 从屏幕弹出的方向
enum SlideTransitionFrom { top, right, left, bottom }

///
/// 从屏幕的某个方向滑动弹出的Dialog框的路由，比如从顶部、底部、左、右滑出页面
///
class SlidePopupRoute<T> extends PopupRoute<T> {
  SlidePopupRoute(
      {required this.builder,
      this.barrierLabel,
      this.modalBarrierColor,
      this.isDismissible = true,
      this.transitionAnimationController,
      this.slideTransitionFrom = SlideTransitionFrom.bottom});

  final WidgetBuilder builder;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final AnimationController? transitionAnimationController;

  // 设置从屏幕的哪个方向滑出
  final SlideTransitionFrom slideTransitionFrom;

  @override
  Duration get transitionDuration => _bottomSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _bottomSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  // 实现转场动画
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return slideRouteTransitionBuilder(
        context, slideTransitionFrom, animation, secondaryAnimation, child);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Material(
      child: builder(context),
    );
  }
}

Future<T?> showSlideRouteDialog<T extends Object>({
  required BuildContext context,
  required Widget Function(BuildContext, EdgeInsets) builder,
  bool barrierDismissible = false,
  SlideTransitionFrom slideTransitionFrom = SlideTransitionFrom.bottom,
  String? barrierLabel,
  Color barrierColor = const Color(0x80000000),
  bool useRootNavigator = true,
  bool useSafeArea = true,
}) {
  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    pageBuilder: (context, animation, secondaryAnimation) {
      final data = MediaQuery.of(context);
      final Widget pageChild = Builder(builder: (context) {
        return builder.call(context, data.padding);
      });
      var dialog = themes.wrap(pageChild);
      if (useSafeArea) {
        dialog = SafeArea(child: dialog);
      }
      return dialog;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return slideRouteTransitionBuilder(
          context, slideTransitionFrom, animation, secondaryAnimation, child);
    },
  );
}

Widget slideRouteTransitionBuilder(
    BuildContext context,
    SlideTransitionFrom slideTransitionFrom,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  var animValue = decelerateEasing.transform(animation.value);

  return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return CustomSingleChildLayout(
          delegate: SlideTransitionLayout(animValue, slideTransitionFrom),
          child: child,
        );
      });
}

/// 从各个方向弹出的Transition
/// progress为0到1区间的变化值
///
class SlideTransitionLayout extends SingleChildLayoutDelegate {
  final double progress;
  final SlideTransitionFrom slideTransitionFrom;

  SlideTransitionLayout(this.progress, this.slideTransitionFrom);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
        // minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        maxHeight: constraints.maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var posY = 0.0;
    var posX = 0.0;
    // 弹出的方向
    switch (slideTransitionFrom) {
      case SlideTransitionFrom.top:
        posY = -(childSize.height - childSize.height * progress);
        break;
      case SlideTransitionFrom.left:
        posX = -(childSize.width - childSize.width * progress);
        break;
      case SlideTransitionFrom.right:
        posX = size.width - childSize.width * progress;
        break;
      case SlideTransitionFrom.bottom:
        posY = size.height - childSize.height * progress;
        break;
    }
    return Offset(posX, posY);
  }

  @override
  bool shouldRelayout(SlideTransitionLayout oldDelegate) {
    return progress != oldDelegate.progress ||
        slideTransitionFrom != oldDelegate.slideTransitionFrom;
  }
}
