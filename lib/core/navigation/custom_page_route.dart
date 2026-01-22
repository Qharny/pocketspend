import 'package:flutter/material.dart';

/// Enum for different types of page transitions
enum PageTransitionType {
  /// Standard slide from right (iOS-style)
  slideRight,

  /// Fade in/out
  fade,

  /// Scale up from center
  scale,

  /// No transition (instant)
  none,

  /// Slide from bottom (modal-style)
  slideBottom,
}

/// CustomPageRoute provides smooth, configurable page transitions.
/// This replaces the default MaterialPageRoute with custom animations
/// suitable for a minimal, distraction-free app experience.
class CustomPageRoute<T> extends PageRoute<T> {
  /// The widget to display
  final Widget page;

  /// Type of transition to use
  final PageTransitionType transitionType;

  /// Duration of the transition
  @override
  final Duration transitionDuration;

  /// Duration of the reverse transition
  @override
  final Duration reverseTransitionDuration;

  /// Whether to maintain the previous page state
  @override
  final bool maintainState;

  /// Whether this route is a fullscreen dialog
  @override
  final bool fullscreenDialog;

  CustomPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.slideRight,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transitionType) {
      case PageTransitionType.slideRight:
        return _buildSlideRightTransition(animation, secondaryAnimation, child);

      case PageTransitionType.slideBottom:
        return _buildSlideBottomTransition(
          animation,
          secondaryAnimation,
          child,
        );

      case PageTransitionType.fade:
        return _buildFadeTransition(animation, child);

      case PageTransitionType.scale:
        return _buildScaleTransition(animation, child);

      case PageTransitionType.none:
        return child;
    }
  }

  /// Slide from right transition (iOS-style)
  Widget _buildSlideRightTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    final offsetAnimation = animation.drive(tween);

    // Secondary animation for the previous page (slide out to left)
    final secondaryOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).chain(CurveTween(curve: curve)).animate(secondaryAnimation);

    return SlideTransition(
      position: offsetAnimation,
      child: SlideTransition(position: secondaryOffsetAnimation, child: child),
    );
  }

  /// Slide from bottom transition (modal-style)
  Widget _buildSlideBottomTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    final offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }

  /// Fade transition
  Widget _buildFadeTransition(Animation<double> animation, Widget child) {
    const curve = Curves.easeInOut;
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return FadeTransition(opacity: curvedAnimation, child: child);
  }

  /// Scale transition
  Widget _buildScaleTransition(Animation<double> animation, Widget child) {
    const curve = Curves.easeInOutCubic;
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
      child: FadeTransition(opacity: curvedAnimation, child: child),
    );
  }

  @override
  bool get opaque => true;
}
