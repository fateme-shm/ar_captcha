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
import '../res/utils/web_browser_info.dart';
import 'safari_captcha_dom_mount.dart';

class CaptchaWebViewWeb extends StatefulWidget {
  final String html;
  final void Function(String token) onSuccess;
  final void Function(String error) onError;
  final VoidCallback? onLoaded;
  final bool enableDebugLogging;

  const CaptchaWebViewWeb({
    super.key,
    required this.html,
    required this.onSuccess,
    required this.onError,
    this.onLoaded,
    required this.enableDebugLogging,
  });

  @override
  State<CaptchaWebViewWeb> createState() => _CaptchaWebViewWebState();
}

class _CaptchaWebViewWebState extends State<CaptchaWebViewWeb> {
  StreamSubscription? _messageSubscription;
  bool _didNotifyLoaded = false;
  bool _contentMounted = false;
  late final String _viewId;
  late final bool _useSafariDirectDom;
  web.HTMLDivElement? _safariContainer;
  web.HTMLIFrameElement? _iframe;
  JSFunction? _loadListener;
  JSFunction? _errorListener;
  String? _blobUrl;

  void _log(String message) {
    if (widget.enableDebugLogging) {
      // ignore: avoid_print
      print('[ArCaptcha][WebView] $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _viewId = 'captcha-${DateTime.now().microsecondsSinceEpoch}';
    _useSafariDirectDom = isSafariWeb;
    _log(
      'init viewId=$_viewId useSafariDirectDom=$_useSafariDirectDom '
      'isIOSSafariWeb=$isIOSSafariWeb htmlLength=${widget.html.length}',
    );

    if (_useSafariDirectDom) {
      _safariContainer = _buildSafariContainer();
    } else {
      _iframe = _buildIframe();
    }

    ui.platformViewRegistry.registerViewFactory(_viewId, (int id) {
      _log(
        'view factory invoked id=$id mode=${_useSafariDirectDom ? "direct-dom" : "iframe"} '
        'connected=$_isConnected',
      );
      _mountContent();
      return _useSafariDirectDom ? _safariContainer! : _iframe!;
    });

    _messageSubscription = web.window.onMessage.listen((event) {
      final data = event.data;
      if (data == null) return;

      try {
        final message = convertCaptchaWebPostMessagesFromJs(data);
        final type = message['type'];
        final payload = message['payload'];

        if (type == 'state') {
          if (payload == 'arcaptcha-ready' ||
              payload == 'loader-hidden' ||
              payload == 'window-loaded') {
            _notifyLoadedOnce();
          }
        }

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mountContent();
      if (_useSafariDirectDom) {
        _scheduleSafariVisibilityFixes();
      }
      _logElementState('post-frame');
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
      _contentMounted = false;
      _didNotifyLoaded = false;
      _mountContent(force: true);
    }
  }

  web.HTMLDivElement _buildSafariContainer() {
    final container = web.HTMLDivElement();
    _applySafariElementStyles(container);
    return container;
  }

  web.HTMLIFrameElement _buildIframe() {
    final iframe = web.HTMLIFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.display = 'block';

    void handleLoad(web.Event _) {
      final src = iframe.src;
      if (src.isEmpty || src == 'about:blank') {
        _logElementState('ignored empty iframe load');
        return;
      }

      _logElementState('iframe load');
      _notifyLoadedOnce();
    }

    void handleError(web.Event _) {
      _logElementState('iframe ERROR');
    }

    _loadListener = handleLoad.toJS;
    _errorListener = handleError.toJS;
    iframe.addEventListener('load', _loadListener!);
    iframe.addEventListener('error', _errorListener!);

    return iframe;
  }

  void _mountContent({bool force = false}) {
    if (_contentMounted && !force) return;

    if (_useSafariDirectDom) {
      final container = _safariContainer;
      if (container == null || !container.isConnected) {
        _log('deferring Safari DOM mount until container is connected');
        return;
      }

      SafariCaptchaDomMount.mount(
        container: container,
        html: widget.html,
        viewId: _viewId,
      );
      _contentMounted = true;
      _fixSafariPlatformViewVisibility();
      _log('Safari direct DOM mount complete');
      return;
    }

    _contentMounted = true;
    _setIframeContent(widget.html);
  }

  void _notifyLoadedOnce() {
    if (_didNotifyLoaded || !mounted) return;
    _didNotifyLoaded = true;
    widget.onLoaded?.call();
  }

  bool get _isConnected {
    if (_useSafariDirectDom) {
      return _safariContainer?.isConnected ?? false;
    }
    return _iframe?.isConnected ?? false;
  }

  void _applySafariElementStyles(web.HTMLDivElement element) {
    element.style.position = 'absolute';
    element.style.top = '0';
    element.style.left = '0';
    element.style.width = '100%';
    element.style.height = '100%';
    element.style.opacity = '1';
    element.style.visibility = 'visible';
    element.style.setProperty('transform', 'translateZ(0)');
    element.style.setProperty('-webkit-transform', 'translateZ(0)');
    element.style.setProperty('will-change', 'transform');
    element.style.setProperty('pointer-events', 'auto');
    element.style.setProperty('z-index', '1');
  }

  void _fixSafariPlatformViewVisibility() {
    final container = _safariContainer;
    if (!_useSafariDirectDom || container == null || !container.isConnected) {
      return;
    }

    var parent = container.parentElement;
    while (parent != null) {
      final tag = parent.tagName.toUpperCase();
      if (tag == 'FLT-PLATFORM-VIEW' ||
          tag == 'FLUTTER-VIEW' ||
          tag == 'FLT-GLASS-PANE' ||
          tag == 'FLT-SCENE-HOST' ||
          tag == 'FLT-SCENE') {
        parent.removeAttribute('aria-hidden');
        parent.setAttribute(
          'style',
          'opacity:1;visibility:visible;display:block;overflow:visible;'
          'position:relative;z-index:1;transform:translateZ(0);'
          '-webkit-transform:translateZ(0);',
        );
      }
      parent = parent.parentElement;
    }

    _applySafariElementStyles(container);
    _log('Safari platform view visibility fix applied');
  }

  void _forceSafariRepaint() {
    final container = _safariContainer;
    if (!_useSafariDirectDom || container == null || !container.isConnected) {
      return;
    }

    container.style.setProperty('transform', 'translateZ(0) scale(1.001)');
    container.getBoundingClientRect();
    container.style.setProperty('transform', 'translateZ(0)');
  }

  void _scheduleSafariVisibilityFixes() {
    if (!_useSafariDirectDom) return;

    _fixSafariPlatformViewVisibility();
    _forceSafariRepaint();

    for (final delayMs in const [50, 150, 300, 600]) {
      Future<void>.delayed(Duration(milliseconds: delayMs), () {
        if (!mounted) return;
        _mountContent();
        _fixSafariPlatformViewVisibility();
        _forceSafariRepaint();
        _logElementState('visibility-retry-${delayMs}ms');
      });
    }
  }

  void _logElementState(String label) {
    if (_useSafariDirectDom) {
      final container = _safariContainer;
      if (container == null) return;
      final rect = container.getBoundingClientRect();
      _log(
        '$label connected=${container.isConnected} '
        'rect=${rect.width}x${rect.height} mode=direct-dom '
        'children=${container.childElementCount}',
      );
      return;
    }

    final iframe = _iframe;
    if (iframe == null) return;
    final rect = iframe.getBoundingClientRect();
    _log(
      '$label connected=${iframe.isConnected} '
      'rect=${rect.width}x${rect.height} mode=iframe '
      'src=${iframe.src.isEmpty ? "(empty)" : iframe.src}',
    );
  }

  void _setIframeContent(String html) {
    final iframe = _iframe;
    if (iframe == null) return;
    _revokeBlobUrl();
    iframe.removeAttribute('srcdoc');
    iframe.src = '';
    iframe.srcdoc = html.toJS;
    _log('iframe content assigned with srcdoc');
  }

  void _revokeBlobUrl() {
    final blobUrl = _blobUrl;
    if (blobUrl == null) return;

    _log('revoking previous Blob URL');
    web.URL.revokeObjectURL(blobUrl);
    _blobUrl = null;
  }

  @override
  void dispose() {
    _log('dispose connected=$_isConnected');

    final iframe = _iframe;
    if (iframe != null) {
      iframe.src = 'about:blank';
      if (_loadListener != null) {
        iframe.removeEventListener('load', _loadListener!);
      }
      if (_errorListener != null) {
        iframe.removeEventListener('error', _errorListener!);
      }
    }

    final container = _safariContainer;
    if (container != null) {
      while (container.firstChild != null) {
        container.removeChild(container.firstChild!);
      }
    }

    _messageSubscription?.cancel();
    _revokeBlobUrl();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
