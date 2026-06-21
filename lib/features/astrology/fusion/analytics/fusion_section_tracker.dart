import 'package:flutter/material.dart';

import 'fusion_validation_session.dart';

/// Fires [FusionValidationSession.markSectionViewed] once when the section
/// enters the viewport.
class FusionSectionTracker extends StatefulWidget {
  const FusionSectionTracker({
    super.key,
    required this.sectionId,
    required this.session,
    required this.child,
  });

  final String sectionId;
  final FusionValidationSession session;
  final Widget child;

  @override
  State<FusionSectionTracker> createState() => _FusionSectionTrackerState();
}

class _FusionSectionTrackerState extends State<FusionSectionTracker> {
  final GlobalKey _key = GlobalKey();
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (_reported || !mounted) return;

    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;

    final scrollRender = scrollable.context.findRenderObject();
    if (scrollRender is! RenderBox) return;

    final sectionTop = renderObject.localToGlobal(Offset.zero).dy;
    final sectionBottom = sectionTop + renderObject.size.height;
    final viewportTop = scrollRender.localToGlobal(Offset.zero).dy;
    final viewportBottom = viewportTop + scrollRender.size.height;

    if (sectionBottom > viewportTop && sectionTop < viewportBottom) {
      _reported = true;
      widget.session.markSectionViewed(widget.sectionId);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _checkVisibility();
        return false;
      },
      child: KeyedSubtree(key: _key, child: widget.child),
    );
  }
}
