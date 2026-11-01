import 'package:flutter/material.dart';

/// Presentation only: keep user text scaling, with a larger desktop reading
/// size. Apply to the isolated trial readers, never the PDF/capture surfaces.
class TrialReaderTypography extends StatelessWidget {
  const TrialReaderTypography({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final desktop = media.size.width >= 900;
    return MediaQuery(
      data: media.copyWith(
        textScaler: _ReaderTextScaler(media.textScaler, desktop ? 1.16 : 1),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(height: 1.65),
        child: child,
      ),
    );
  }
}

class _ReaderTextScaler extends TextScaler {
  const _ReaderTextScaler(this.userScaler, this.factor);
  final TextScaler userScaler;
  final double factor;

  @override
  double scale(double fontSize) => userScaler.scale(fontSize) * factor;

  @override
  double get textScaleFactor => userScaler.textScaleFactor * factor;
}
