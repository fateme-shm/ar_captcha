import 'dart:async';

import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';

import '../res/common/js_interop_helper.dart';
import 'captcha_web_view_web.dart';

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
          if (mounted) {
            Navigator.of(context).pop(payload);
          } else {
            debugPrint(
                'ArCaptcha success but context is not mounted: $payload');
          }
        } else if (type == 'error') {
          debugPrint('ArCaptcha error: $payload');

          if (mounted) {
            Navigator.of(context).pop(payload);
          } else {
            debugPrint('ArCaptcha error but context is not mounted');
          }
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
    return CaptchaWebViewWeb(
      html: widget.htmlWidget,
      onSuccess: (token) {
        Navigator.of(context).pop(token);
      },
      onError: (error) {
        debugPrint('ArCaptcha error: $error');
        Navigator.of(context).pop(error);
      },
    );
  }
}
