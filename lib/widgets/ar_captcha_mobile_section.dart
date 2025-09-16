import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '/../controller/ar_captcha_controller.dart';

/// A platform-agnostic holder for rendering the captcha widget.
///
/// Depending on the platform (web or mobile), the exported implementation
/// will switch between:
/// - [ArCaptchaMobileDialog] (mobile)
/// - [ArCaptchaWebDialog] (web)
/// - a fallback [Container] (stub, should never be used).

class ArCaptchaSectionHolder extends StatefulWidget {
  final String htmlWidget;

  const ArCaptchaSectionHolder({super.key, required this.htmlWidget});

  @override
  State<ArCaptchaSectionHolder> createState() => _ArCaptchaSectionHolderState();
}

class _ArCaptchaSectionHolderState extends State<ArCaptchaSectionHolder> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initJsFunction();
    });
  }

  /// Initializes the JS channel inside the WebView for
  /// captcha success/error callbacks.
  void _initJsFunction() {
    ArCaptchaController.webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Captcha',
        onMessageReceived: (message) {
          final data = jsonDecode(message.message);
          final type = data['type'];
          final payload = data['payload'];

          if (type == 'success') {
            Navigator.of(context).pop(payload);
          } else if (type == 'error') {
            debugPrint('ArCaptcha error: $payload');
          }
        },
      )
      ..loadHtmlString(widget.htmlWidget);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ArCaptchaController.webViewController == null
        ? const SizedBox.shrink()
        : WebViewWidget(
            layoutDirection: TextDirection.rtl,
            controller: ArCaptchaController.webViewController!,
          );
  }
}
