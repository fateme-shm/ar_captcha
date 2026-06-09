import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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
  final bool showLoadingOverlay;
  final String? loadingText;

  const ArCaptchaSectionHolder({
    super.key,
    required this.htmlWidget,
    this.showLoadingOverlay = false,
    this.loadingText,
  });

  @override
  State<ArCaptchaSectionHolder> createState() => _ArCaptchaSectionHolderState();
}

class _ArCaptchaSectionHolderState extends State<ArCaptchaSectionHolder> {
  /// Subscription for listening to JS `window.postMessage` events.
  StreamSubscription<web.MessageEvent>? _messageSubscription;
  bool _isLoaded = false;

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
    ) {
      final event = message.data;

      if (event != null) {
        Map<String, String?> data = convertCaptchaWebPostMessagesFromJs(event);

        final type = data['type'];
        final payload = data['payload'];

        if (type == 'success') {
          Navigator.of(context).pop(payload);
        } else if (type == 'error') {
          debugPrint('ArCaptcha error: $payload');
          Navigator.of(context).pop(payload);
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
    final captchaView = CaptchaWebViewWeb(
      html: widget.htmlWidget,
      onLoaded: () {
        if (!mounted) return;
        setState(() => _isLoaded = true);
      },
      onSuccess: (token) {
        Navigator.of(context).pop(token);
      },
      onError: (error) {
        debugPrint('ArCaptcha error: $error');
        Navigator.of(context).pop(error);
      },
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
}
