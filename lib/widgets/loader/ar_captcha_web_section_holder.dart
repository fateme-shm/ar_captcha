import 'package:flutter/material.dart';

import '../ar_captcha_web_dialog.dart';

/// A platform-agnostic holder for rendering the captcha widget.
///
/// Depending on the platform (web or mobile), the exported implementation
/// will switch between:
/// - [ArCaptchaMobileDialog] (mobile)
/// - [ArCaptchaWebDialog] (web)
/// - a fallback [Container] (stub, should never be used).
class ArCaptchaSectionHolder extends StatelessWidget {
  final String htmlWidget;

  const ArCaptchaSectionHolder({super.key, required this.htmlWidget});

  @override
  Widget build(BuildContext context) {
    return ArCaptchaWebDialog(htmlWidget: htmlWidget);
  }
}
