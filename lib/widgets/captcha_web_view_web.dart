// Dart imports:
import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:web/web.dart' as web;

// Project imports:
import '../res/common/js_interop_helper.dart';

class CaptchaWebViewWeb extends StatefulWidget {
  final String html;
  final void Function(String token) onSuccess;
  final void Function(String error) onError;
  final VoidCallback? onLoaded;

  const CaptchaWebViewWeb({
    super.key,
    required this.html,
    required this.onSuccess,
    required this.onError,
    this.onLoaded,
  });

  @override
  State<CaptchaWebViewWeb> createState() => _CaptchaWebViewWebState();
}

class _CaptchaWebViewWebState extends State<CaptchaWebViewWeb> {
  StreamSubscription? sub;
  bool _didNotifyLoaded = false;
  late final String _viewId;
  late final web.HTMLIFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _viewId = 'captcha-${DateTime.now().millisecondsSinceEpoch}';
    _iframe = web.HTMLIFrameElement()
      ..srcdoc = widget.html.toJS
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.display = 'block';

    _iframe.onLoad.listen((_) {
      if (_didNotifyLoaded || !mounted) return;

      _didNotifyLoaded = true;
      widget.onLoaded?.call();
    });

    ui.platformViewRegistry.registerViewFactory(_viewId, (int id) => _iframe);

    sub = web.window.onMessage.listen((event) {
      final data = event.data;

      if (data == null) return;

      try {
        final message = convertCaptchaWebPostMessagesFromJs(data);
        final type = message['type'];
        final payload = message['payload'];

        if (type == 'success') {
          if (payload != null) {
            widget.onSuccess(payload);
          } else {
            widget.onError('captcha token is empty');
          }
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
    return SizedBox.expand(
      child: HtmlElementView(viewType: _viewId),
    );
  }
}

