import 'dart:js_interop';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../res/utils/web_browser_info.dart';

class CaptchaWebViewWeb extends StatefulWidget {
  final String html;
  final bool enableDebugLogging;

  const CaptchaWebViewWeb({
    super.key,
    required this.html,
    required this.enableDebugLogging,
  });

  @override
  State<CaptchaWebViewWeb> createState() => _CaptchaWebViewWebState();
}

class _CaptchaWebViewWebState extends State<CaptchaWebViewWeb> {
  late final String _viewId;
  late final web.HTMLIFrameElement _iframe;
  JSFunction? _loadListener;
  JSFunction? _errorListener;
  String? _blobUrl;

  void _log(String message) {
    if (widget.enableDebugLogging) {
      // ignore: avoid_print
      print('[ArCaptcha][Iframe] $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _viewId = 'captcha-${DateTime.now().microsecondsSinceEpoch}';
    _log(
      'init viewId=$_viewId isSafariWeb=$isSafariWeb '
      'isIOSSafariWeb=$isIOSSafariWeb '
      'htmlLength=${widget.html.length}',
    );
    _iframe = _buildIframe();

    ui.platformViewRegistry.registerViewFactory(_viewId, (int _) => _iframe);
    _log('registered platform view factory');
    _setIframeContent(widget.html);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rect = _iframe.getBoundingClientRect();
      _log(
        'post-frame connected=${_iframe.isConnected} '
        'rect=${rect.width}x${rect.height} '
        'src=${_iframe.src.isEmpty ? "(empty)" : _iframe.src} '
        'hasSrcdoc=${_iframe.getAttribute("srcdoc")?.isNotEmpty == true}',
      );
    });
  }

  @override
  void didUpdateWidget(covariant CaptchaWebViewWeb oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.html != widget.html) {
      _log(
        'HTML updated oldLength=${oldWidget.html.length} '
        'newLength=${widget.html.length}',
      );
      _setIframeContent(widget.html);
    }
  }

  web.HTMLIFrameElement _buildIframe() {
    final iframe = web.HTMLIFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    void handleLoad(web.Event _) {
      final rect = iframe.getBoundingClientRect();
      _log(
        'load event connected=${iframe.isConnected} '
        'rect=${rect.width}x${rect.height} src=${iframe.src}',
      );

      if (_blobUrl != null) {
        _log('Blob URL retained until iframe disposal');
      }
    }

    void handleError(web.Event _) {
      final rect = iframe.getBoundingClientRect();
      _log(
        'ERROR event connected=${iframe.isConnected} '
        'rect=${rect.width}x${rect.height} src=${iframe.src}',
      );
    }

    _loadListener = handleLoad.toJS;
    _errorListener = handleError.toJS;
    iframe.addEventListener('load', _loadListener!);
    iframe.addEventListener('error', _errorListener!);

    _log(
      'iframe created sandbox=${iframe.getAttribute("sandbox")} '
      'allow=${iframe.getAttribute("allow")}',
    );

    return iframe;
  }

  void _setIframeContent(String html) {
    _revokeBlobUrl();

    if (isSafariWeb) {
      final blob = web.Blob(
        <JSString>[html.toJS].toJS,
        web.BlobPropertyBag(type: 'text/html'),
      );
      final blobUrl = web.URL.createObjectURL(blob);
      _blobUrl = blobUrl;
      _iframe.src = blobUrl;
      _log('content assigned with Blob URL for Safari');
      return;
    }

    _iframe.srcdoc = html.toJS;
    _log('content assigned with srcdoc');
  }

  void _revokeBlobUrl() {
    final blobUrl = _blobUrl;
    if (blobUrl == null) {
      return;
    }

    _log('revoking previous Blob URL');
    web.URL.revokeObjectURL(blobUrl);
    _blobUrl = null;
  }

  @override
  void dispose() {
    _log('dispose connected=${_iframe.isConnected} src=${_iframe.src}');
    _iframe.src = 'about:blank';

    if (_loadListener != null) {
      _iframe.removeEventListener('load', _loadListener!);
    }
    if (_errorListener != null) {
      _iframe.removeEventListener('error', _errorListener!);
    }

    _revokeBlobUrl();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _log('build HtmlElementView viewId=$_viewId');
    return HtmlElementView(viewType: _viewId);
  }
}
