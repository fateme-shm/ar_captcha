// Dart imports:
import 'dart:async';
import 'dart:ui_web' as ui;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:web/web.dart' as web;

// Project imports:
import '../res/common/js_interop_helper.dart';
import 'safari_captcha_dom_mount.dart';

/// Renders ArCaptcha on Flutter web via direct DOM injection into
/// [HtmlElementView]. Nested iframes (`srcdoc` / blob) load correctly but
/// often fail to paint inside `flt-platform-view` across browsers.
class CaptchaWebViewWeb extends StatefulWidget {
  final String html;
  final void Function(String token) onSuccess;
  final void Function(String error) onError;
  final VoidCallback? onLoaded;
  final bool enableDebugLogging;
  final double captchaHeight;
  final double captchaWidth;

  const CaptchaWebViewWeb({
    super.key,
    required this.html,
    required this.onSuccess,
    required this.onError,
    this.onLoaded,
    required this.enableDebugLogging,
    this.captchaHeight = 550,
    this.captchaWidth = 550,
  });

  @override
  State<CaptchaWebViewWeb> createState() => _CaptchaWebViewWebState();
}

class _CaptchaWebViewWebState extends State<CaptchaWebViewWeb> {
  StreamSubscription? _messageSubscription;
  bool _didNotifyLoaded = false;
  late final String _viewId;
  late final web.HTMLDivElement _container;
  double? _layoutWidth;
  double? _layoutHeight;

  void _log(String message) {
    if (widget.enableDebugLogging) {
      // ignore: avoid_print
      print('[ArCaptcha][WebView] $message');
    }
  }

  bool get _hasMountedContent => _container.childElementCount > 0;

  @override
  void initState() {
    super.initState();
    _viewId = 'captcha-${DateTime.now().microsecondsSinceEpoch}';
    _container = _buildContainer();

    _log('init viewId=$_viewId htmlLength=${widget.html.length}');

    ui.platformViewRegistry.registerViewFactory(_viewId, (int id) {
      _log('view factory invoked id=$id connected=${_container.isConnected}');
      _ensureContentMounted();
      return _container;
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
      _ensureContentMounted();
      _scheduleMountAndVisibilityFixes();
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
      _didNotifyLoaded = false;
      _mountContent(force: true);
    }
  }

  web.HTMLDivElement _buildContainer() {
    final container = web.HTMLDivElement();
    _applyContainerStyles(container);
    return container;
  }

  /// Scripts only execute once the platform-view element is connected to the
  /// document, so keep retrying until children are present.
  void _ensureContentMounted() {
    if (_hasMountedContent) return;
    _mountContent();
  }

  void _mountContent({bool force = false}) {
    if (_hasMountedContent && !force) return;

    if (!_container.isConnected) {
      _log(
        'deferring DOM mount until connected '
        '(children=${_container.childElementCount})',
      );
      return;
    }

    SafariCaptchaDomMount.mount(
      container: _container,
      html: widget.html,
      viewId: _viewId,
    );
    _applyExplicitSizeIfKnown();
    _fixPlatformViewVisibility();
    _log(
      'direct DOM mount complete children=${_container.childElementCount} '
      'connected=${_container.isConnected}',
    );
  }

  void _notifyLoadedOnce() {
    if (_didNotifyLoaded || !mounted) return;
    _didNotifyLoaded = true;
    widget.onLoaded?.call();
  }

  void _applyContainerStyles(web.HTMLDivElement element) {
    element.style.position = 'absolute';
    element.style.top = '0';
    element.style.left = '0';
    element.style.opacity = '1';
    element.style.visibility = 'visible';
    element.style.setProperty('transform', 'translateZ(0)');
    element.style.setProperty('-webkit-transform', 'translateZ(0)');
    element.style.setProperty('will-change', 'transform');
    element.style.setProperty('pointer-events', 'auto');
    element.style.setProperty('z-index', '1');
    element.style.setProperty('overflow', 'auto');
  }

  void _applyExplicitSize(double width, double height) {
    _layoutWidth = width;
    _layoutHeight = height;

    final widthPx = '${width.round()}px';
    final heightPx = '${height.round()}px';

    _container.style.width = widthPx;
    _container.style.height = heightPx;
    _container.style.minHeight = heightPx;

    if (_container.isConnected) {
      var parent = _container.parentElement;
      while (parent != null) {
        if (parent.tagName.toUpperCase() == 'FLT-PLATFORM-VIEW') {
          parent.removeAttribute('aria-hidden');
          parent.setAttribute(
            'style',
            'width:$widthPx;height:$heightPx;min-height:$heightPx;'
            'opacity:1;visibility:visible;display:block;overflow:visible;'
            'position:relative;z-index:2147483647;transform:translateZ(0);'
            '-webkit-transform:translateZ(0);pointer-events:auto;',
          );
          break;
        }
        parent = parent.parentElement;
      }
    }

    _log('explicit size applied ${width.round()}x${height.round()}');
  }

  void _applyExplicitSizeIfKnown() {
    final width = _layoutWidth;
    final height = _layoutHeight;
    if (width == null || height == null) return;
    if (width <= 0 || height <= 0) return;
    _applyExplicitSize(width, height);
  }

  void _fixPlatformViewVisibility() {
    if (!_container.isConnected) return;

    var parent = _container.parentElement;
    while (parent != null) {
      final tag = parent.tagName.toUpperCase();
      if (tag == 'FLT-PLATFORM-VIEW' ||
          tag == 'FLUTTER-VIEW' ||
          tag == 'FLT-GLASS-PANE' ||
          tag == 'FLT-SCENE-HOST' ||
          tag == 'FLT-SCENE' ||
          tag == 'FLT-SEMANTICS-PLACEHOLDER') {
        parent.removeAttribute('aria-hidden');
        parent.setAttribute(
          'style',
          '${parent.getAttribute('style') ?? ''}'
          'opacity:1;visibility:visible;display:block;overflow:visible;'
          'position:relative;z-index:2147483647;transform:translateZ(0);'
          '-webkit-transform:translateZ(0);pointer-events:auto;',
        );
      }
      parent = parent.parentElement;
    }

    _applyExplicitSizeIfKnown();
    _applyContainerStyles(_container);
    _log('platform view visibility fix applied');
  }

  void _forceRepaint() {
    if (!_container.isConnected) return;

    _container.style.setProperty('transform', 'translateZ(0) scale(1.001)');
    _container.getBoundingClientRect();
    _container.style.setProperty('transform', 'translateZ(0)');
  }

  void _scheduleMountAndVisibilityFixes() {
    for (final delayMs in const [0, 16, 50, 100, 150, 300, 600, 1000]) {
      Future<void>.delayed(Duration(milliseconds: delayMs), () {
        if (!mounted) return;
        _ensureContentMounted();
        _applyExplicitSizeIfKnown();
        _fixPlatformViewVisibility();
        _forceRepaint();
        _logElementState('retry-${delayMs}ms');
      });
    }
  }

  void _logElementState(String label) {
    final rect = _container.getBoundingClientRect();
    _log(
      '$label connected=${_container.isConnected} '
      'rect=${rect.width}x${rect.height} children=${_container.childElementCount}',
    );
  }

  @override
  void dispose() {
    _log('dispose connected=${_container.isConnected}');

    while (_container.firstChild != null) {
      _container.removeChild(_container.firstChild!);
    }

    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _resolveDimension(
          preferred: widget.captchaWidth,
          constraint: constraints.maxWidth,
        );
        final height = _resolveDimension(
          preferred: widget.captchaHeight,
          constraint: constraints.maxHeight,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _applyExplicitSize(width, height);
          _ensureContentMounted();
          _fixPlatformViewVisibility();
        });

        return SizedBox(
          width: width,
          height: height,
          child: HtmlElementView(viewType: _viewId),
        );
      },
    );
  }

  double _resolveDimension({
    required double preferred,
    required double constraint,
  }) {
    if (constraint.isFinite && constraint > 0) {
      return constraint;
    }
    return preferred;
  }
}
