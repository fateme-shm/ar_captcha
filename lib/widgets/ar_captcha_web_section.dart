import 'dart:async';
import 'dart:developer';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import '/../res/common/js_interop_helper.dart';

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
  String? viewId;

  /// Subscription for listening to JS `window.postMessage` events.
  StreamSubscription<web.MessageEvent>? _messageSubscription;

  @override
  void initState() {
    super.initState();

    viewId = 'captcha-${DateTime.now().millisecondsSinceEpoch}';
    CaptchaViewRegistry.register(viewId ?? '', widget.htmlWidget);

    log('View id: $viewId');

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
    return HtmlElementView(viewType: viewId ?? '');
  }
}

class CaptchaViewRegistry {
  static final Set<String> _registered = {};

  static void register(String viewId, String html) {
    if (_registered.contains(viewId)) return;
    _registered.add(viewId);

    ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final iframe = web.HTMLIFrameElement()
        ..src = Uri.dataFromString(
          html,
          mimeType: 'text/html',
        ).toString()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..setAttribute(
          'sandbox',
          'allow-scripts allow-same-origin allow-forms allow-popups',
        );

      return iframe;
    });
  }
}
