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
  final bool showLoadingOverlay;
  final String? loadingText;
  final bool enableDebugLogging;
  final double captchaHeight;
  final double captchaWidth;

  const ArCaptchaSectionHolder({
    super.key,
    required this.htmlWidget,
    this.showLoadingOverlay = false,
    this.loadingText,
    required this.enableDebugLogging,
    this.captchaHeight = 550,
    this.captchaWidth = 550,
  });

  @override
  State<ArCaptchaSectionHolder> createState() => _ArCaptchaSectionHolderState();
}

class _ArCaptchaSectionHolderState extends State<ArCaptchaSectionHolder> {
  bool _isLoaded = false;

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
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!mounted) return;
            _log('webview page finished loading; hiding overlay');
            setState(() => _isLoaded = true);
          },
        ),
      )
      ..addJavaScriptChannel(
        'Captcha',
        onMessageReceived: (message) {
          final data = jsonDecode(message.message);
          final type = data['type'];
          final payload = data['payload'];

          if (type == 'success') {
            Navigator.of(context).pop(payload);
          } else if (type == 'error') {
            _log('error callback received $payload');
          }
        },
      )
      ..loadHtmlString(widget.htmlWidget);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (ArCaptchaController.webViewController == null) {
      return const SizedBox.shrink();
    }

    final captchaView = WebViewWidget(
      layoutDirection: TextDirection.rtl,
      controller: ArCaptchaController.webViewController!,
    );

    if (!widget.showLoadingOverlay) return captchaView;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: captchaView),
        if (!_isLoaded)
          Positioned.fill(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      widget.loadingText ?? 'Loading captcha ...',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _log(String message) {
    if (widget.enableDebugLogging) {
      // ignore: avoid_print
      print('[ArCaptcha][Mobile] $message');
    }
  }
}
