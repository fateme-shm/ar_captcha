import 'dart:async';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../res/common/js_interop_helper.dart';

/// Renders ARCaptcha HTML inside an iframe on Flutter web.
///
/// Uses [srcdoc] (not a sandboxed `data:` URL) so third-party scripts from
/// `widget.arcaptcha.ir` load correctly on Safari/iOS.
class CaptchaWebViewWeb extends StatefulWidget {
  final String html;
  final void Function(String token) onSuccess;
  final void Function(String error) onError;

  const CaptchaWebViewWeb({
    super.key,
    required this.html,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<CaptchaWebViewWeb> createState() => _CaptchaWebViewWebState();
}

class _CaptchaWebViewWebState extends State<CaptchaWebViewWeb> {
  late final String viewId;
  StreamSubscription<web.MessageEvent>? _messageSubscription;

  @override
  void initState() {
    super.initState();

    viewId = 'captcha-${DateTime.now().millisecondsSinceEpoch}';
    CaptchaViewRegistry.register(viewId, widget.html);

    _messageSubscription = web.window.onMessage.listen((event) {
      final data = event.data;
      if (data == null) return;

      final parsed = convertCaptchaWebPostMessagesFromJs(data);
      final type = parsed['type'];
      final payload = parsed['payload'];

      if (type == 'success' && payload != null) {
        widget.onSuccess(payload);
      } else if (type == 'error') {
        widget.onError(payload ?? 'captcha error');
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
    return HtmlElementView(viewType: viewId);
  }
}

class CaptchaViewRegistry {
  static final Set<String> _registered = {};

  static void register(String viewId, String html) {
    if (_registered.contains(viewId)) return;
    _registered.add(viewId);

    ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final iframe = web.HTMLIFrameElement()
        ..setAttribute('srcdoc', html)
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      return iframe;
    });
  }
}
