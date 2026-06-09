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
  final bool enableDebugLogging;

  const ArCaptchaSectionHolder({
    super.key,
    required this.htmlWidget,
    this.showLoadingOverlay = false,
    this.loadingText,
    required this.enableDebugLogging,
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
    if (!mounted) {
      _log('listener not attached because widget is unmounted');
      return;
    }

    _log('attaching window message listener');

    _messageSubscription = web.window.onMessage.listen((
      web.MessageEvent message,
    ) {
      final event = message.data;

      if (event != null) {
        Map<String, String?> data = convertCaptchaWebPostMessagesFromJs(event);

        final type = data['type'];
        final payload = data['payload'];

        _log(
          'received type=${type?.isEmpty == true ? "(empty)" : type} '
          'payloadLength=${payload?.length ?? 0}',
        );

        if (type == 'success') {
          if (!mounted) return;
          _log('success: closing captcha route');
          Navigator.of(context).pop(payload);
        } else if (type == 'error') {
          if (!mounted) return;
          _log('error callback received $payload');
          Navigator.of(context).pop(payload);
        } else if (type == 'state') {
          _log('state update: $payload');
        } else if (type == 'execute-called') {
          _log('captcha execute invoked from web page');
        }
      }
    });
  }

  @override
  void dispose() {
    _log('dispose and cancel message listener');
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final captchaView = CaptchaWebViewWeb(
      html: widget.htmlWidget,
      enableDebugLogging: widget.enableDebugLogging,
      onLoaded: () {
        if (!mounted) return;
        _log('iframe reported loaded; hiding Flutter overlay');
        setState(() => _isLoaded = true);
      },
      onSuccess: (payload) =>
          _log('captcha success callback received: $payload'),
      onError: (error) => _log('captcha error: $error'),
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
  // ------------------------- Logger functions -------------------------

  void _log(String message) {
    if (widget.enableDebugLogging) {
      // ignore: avoid_print
      print('[ArCaptcha][Messages] $message');
    }
  }
}
