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
  final String? siteKey;
  final String? domain;
  final bool enableDebugLogging;

  const ArCaptchaSectionHolder({
    super.key,
    required this.htmlWidget,
    this.siteKey,
    this.domain,
    required this.enableDebugLogging,
  });

  @override
  State<ArCaptchaSectionHolder> createState() => _ArCaptchaSectionHolderState();
}

class _ArCaptchaSectionHolderState extends State<ArCaptchaSectionHolder> {
  /// Subscription for listening to JS `window.postMessage` events.
  StreamSubscription<web.MessageEvent>? _messageSubscription;

  void _log(String message) {
    if (widget.enableDebugLogging) {
      // ignore: avoid_print
      print('[ArCaptcha][Messages] $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _log(
      'init domain=${widget.domain ?? "(null)"} '
      'siteKeyConfigured=${widget.siteKey?.isNotEmpty == true}',
    );
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
    ) async {
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
          if (mounted) {
            _log('success: closing captcha route');
            Navigator.of(context).pop(payload);
          } else {
            _log('success ignored because context is unmounted');
          }
        } else if (type == 'error') {
          _log('error callback received');

          if (mounted) {
            Navigator.of(context).pop(payload);
          } else {
            _log('error ignored because context is unmounted');
          }
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
    return CaptchaWebViewWeb(
      html: widget.htmlWidget,
      enableDebugLogging: widget.enableDebugLogging,
    );
  }
}
