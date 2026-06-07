import 'package:flutter/widgets.dart';

/// Fallback stub for unsupported platforms.
class ArCaptchaSectionHolder extends StatelessWidget {
  final String htmlWidget;
  final String? siteKey;
  final String? domain;

  const ArCaptchaSectionHolder({
    super.key,
    required this.htmlWidget,
    this.siteKey,
    this.domain,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
