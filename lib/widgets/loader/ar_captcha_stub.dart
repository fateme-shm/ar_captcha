// Flutter imports:
import 'package:flutter/widgets.dart';

/// Fallback stub for unsupported platforms.
///
/// This is a placeholder and should never actually be used in production.
class ArCaptchaSectionHolder extends StatelessWidget {
  final String htmlWidget;
  final String? loadingText;

  final bool showLoadingOverlay;

  final bool enableDebugLogging;
  final double captchaHeight;
  final double captchaWidth;

  const ArCaptchaSectionHolder({
    super.key,
    required this.htmlWidget,
    this.showLoadingOverlay = true,
    this.loadingText = 'Loading captcha ...',
    required this.enableDebugLogging,
    this.captchaHeight = 550,
    this.captchaWidth = 550,
  });

  @override
  Widget build(BuildContext context) {
    // Just a fallback stub, should never be used
    return Container();
  }
}
