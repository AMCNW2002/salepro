import 'package:flutter/material.dart';

// A simple widget to handle smooth transitions between pages
class PageTransitionSwitcher extends StatelessWidget {
  final int index;
  final Widget child;

  const PageTransitionSwitcher({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(key: ValueKey<int>(index), child: child),
    );
  }
}
