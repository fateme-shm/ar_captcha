import 'dart:async';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:flutter/material.dart';

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
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();

    sub = web.window.onMessage.listen((event) {
      final data = event.data;

      if (data == null) return;

      try {
        final map = data as Map;

        final type = map['type'];
        final payload = map['payload'];

        if (type == 'success') {
          widget.onSuccess(payload);
        }

        if (type == 'error') {
          widget.onError(payload ?? 'captcha error');
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewId = 'captcha-${DateTime.now().millisecondsSinceEpoch}';

    ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
      final iframe = web.HTMLIFrameElement()
        ..srcdoc = widget.html.toJS
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      return iframe;
    });

    return HtmlElementView(viewType: viewId);
  }
}
