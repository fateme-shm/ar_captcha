import 'package:flutter/material.dart';

import 'captcha_web_view_web.dart';

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
    return CaptchaWebViewWeb(
      html: htmlWidget,
      onSuccess: (token) {
        Navigator.of(context).pop(token);
      },
      onError: (error) {
        debugPrint('ArCaptcha error: $error');
      },
    );
  }
}
