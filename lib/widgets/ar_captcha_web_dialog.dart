import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '/../controller/ar_captcha_controller.dart';
import '/../res/common/js_interop_helper.dart';

/// Web implementation of the captcha dialog.
///
/// Uses [InAppWebView] to render the captcha and listens to
/// browser `postMessage` events for success/error callbacks.
class ArCaptchaWebDialog extends StatefulWidget {
  final String htmlWidget;

  const ArCaptchaWebDialog({super.key, required this.htmlWidget});

  @override
  State<ArCaptchaWebDialog> createState() => _ArCaptchaWebDialogState();
}

class _ArCaptchaWebDialogState extends State<ArCaptchaWebDialog> {
  /// Subscription for listening to JS `window.postMessage` events.
  StreamSubscription<web.MessageEvent>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCallBack();
    });
  }

  /// Handles messages posted from the captcha widget (success/error).
  void _handleCallBack() {
    if (!mounted) return;

    _messageSubscription = web.window.onMessage.listen((
      web.MessageEvent message,
    ) async {
      final event = message.data;

      if (event != null) {
        Map<String, String?> data = convertCaptchaWebPostMessagesFromJs(event);

        final type = data['type'];
        final payload = data['payload'];

        if (type == 'success') {
          Navigator.of(context).pop(payload);
        } else if (type == 'error') {
          debugPrint('ArCaptcha error: $payload');
        }
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(data: widget.htmlWidget),
      initialSettings: InAppWebViewSettings(
        useShouldOverrideUrlLoading: false,
        mediaPlaybackRequiresUserGesture: false,
      ),

      onWebViewCreated: (InAppWebViewController controller) async {
        ArCaptchaController.inAppController = controller;

        setState(() {});
      },
      onConsoleMessage:
          (InAppWebViewController controller, ConsoleMessage consoleMessage) {
            debugPrint(consoleMessage.message);
          },
    );
  }
}
