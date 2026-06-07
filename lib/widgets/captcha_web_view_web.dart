import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../res/utils/web_browser_info.dart';

class CaptchaWebViewWeb extends StatefulWidget {
  final String html;

  const CaptchaWebViewWeb({
    super.key,
    required this.html,
  });

  @override
  State<CaptchaWebViewWeb> createState() => _CaptchaWebViewWebState();
}

class _CaptchaWebViewWebState extends State<CaptchaWebViewWeb> {
  late final String _viewId;
  late final web.HTMLIFrameElement _iframe;
  JSFunction? _loadListener;
  String? _blobUrl;

  @override
  void initState() {
    super.initState();
    _viewId = 'captcha-${DateTime.now().microsecondsSinceEpoch}';
    _iframe = _buildIframe();

    ui.platformViewRegistry.registerViewFactory(_viewId, (int _) => _iframe);
    _setIframeContent(widget.html);
  }

  @override
  void didUpdateWidget(covariant CaptchaWebViewWeb oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.html != widget.html) {
      _setIframeContent(widget.html);
    }
  }

  web.HTMLIFrameElement _buildIframe() {
    final iframe = web.HTMLIFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..setAttribute('sandbox',
          'allow-scripts allow-same-origin allow-forms allow-popups')
      ..setAttribute('allow', 'cross-origin-isolated');

    void handleLoad(web.Event _) {
      final loadedBlobUrl = _blobUrl;
      if (loadedBlobUrl == null) {
        return;
      }

      Timer(const Duration(milliseconds: 100), () {
        if (_blobUrl == loadedBlobUrl) {
          web.URL.revokeObjectURL(loadedBlobUrl);
          _blobUrl = null;
        }
      });
    }

    _loadListener = handleLoad.toJS;
    iframe.addEventListener('load', _loadListener!);

    return iframe;
  }

  void _setIframeContent(String html) {
    _revokeBlobUrl();

    if (isIOSSafariWeb) {
      final blob = web.Blob(
        <JSString>[html.toJS].toJS,
        web.BlobPropertyBag(type: 'text/html'),
      );
      final blobUrl = web.URL.createObjectURL(blob);
      _blobUrl = blobUrl;
      _iframe.src = blobUrl;
      return;
    }

    _iframe.srcdoc = html.toJS;
  }

  void _revokeBlobUrl() {
    final blobUrl = _blobUrl;
    if (blobUrl == null) {
      return;
    }

    web.URL.revokeObjectURL(blobUrl);
    _blobUrl = null;
  }

  @override
  void dispose() {
    _iframe.src = 'about:blank';

    if (_loadListener != null) {
      _iframe.removeEventListener('load', _loadListener!);
    }

    _revokeBlobUrl();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
