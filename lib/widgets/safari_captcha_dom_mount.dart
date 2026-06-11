import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Mounts captcha markup directly into a [HTMLDivElement] for Safari.
///
/// Safari fails to paint nested iframes inside Flutter [HtmlElementView] even
/// when the iframe content loads successfully. Injecting the widget into the
/// platform-view div avoids that compositor bug.
class SafariCaptchaDomMount {
  static void mount({
    required web.HTMLDivElement container,
    required String html,
    required String viewId,
  }) {
    while (container.firstChild != null) {
      container.removeChild(container.firstChild!);
    }

    final loaderId = 'ar-captcha-loader-$viewId';
    final verifyCallback = 'arCaptchaVerify_$viewId';
    final errorCallback = 'arCaptchaError_$viewId';

    container.id = 'ar-captcha-root-$viewId';
    container.style.width = '100%';
    container.style.height = '100%';
    container.style.position = 'relative';
    container.style.overflow = 'auto';
    container.style.display = 'block';
    container.style.background = _extractBodyBackground(html);

    final styleContent = _firstMatch(
      html,
      RegExp(r'<style>([\s\S]*?)</style>', caseSensitive: false),
    );
    if (styleContent != null && styleContent.isNotEmpty) {
      container.append(web.HTMLStyleElement()..textContent = styleContent);
    }

    final bodyHtml = _firstMatch(
          html,
          RegExp(r'<body[^>]*>([\s\S]*?)</body>', caseSensitive: false),
        ) ??
        '';

    final scriptBlocks = <String>[];
    var bodyWithoutScripts = bodyHtml;
    final scriptPattern = RegExp(
      r'<script>([\s\S]*?)</script>',
      caseSensitive: false,
    );
    for (final match in scriptPattern.allMatches(bodyHtml)) {
      scriptBlocks.add(match.group(1)!);
      bodyWithoutScripts = bodyWithoutScripts.replaceFirst(match.group(0)!, '');
    }

    bodyWithoutScripts = bodyWithoutScripts
        .replaceAll('id="loader"', 'id="$loaderId"')
        .replaceAll('data-callback="onVerified"', 'data-callback="$verifyCallback"')
        .replaceAll(
          'data-error-callback="onError"',
          'data-error-callback="$errorCallback"',
        )
        .replaceAll('position: fixed', 'position: absolute')
        .replaceAll('min-height: 100vh', 'min-height: 100%');

    final content = web.HTMLDivElement()
      ..innerHTML = bodyWithoutScripts.toJS
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.position = 'relative';
    container.append(content);

    final apiSrc = RegExp(
      r'<script\s+src="(https://widget\.arcaptcha\.ir/[^"]+)"',
      caseSensitive: false,
    ).firstMatch(html)?.group(1);

    if (apiSrc != null) {
      container.append(
        web.HTMLScriptElement()
          ..src = apiSrc
          ..async = true
          ..defer = true,
      );
    }

    for (final scriptText in scriptBlocks) {
      final adjusted = scriptText
          .replaceAll(
            "getElementById('loader')",
            "getElementById('$loaderId')",
          )
          .replaceAll(
            'function onVerified(token)',
            'window.$verifyCallback = function(token)',
          )
          .replaceAll(
            'function onError(error)',
            'window.$errorCallback = function(error)',
          );

      container.append(web.HTMLScriptElement()..text = adjusted);
    }
  }

  static String? _firstMatch(String html, RegExp reg) {
    return reg.firstMatch(html)?.group(1);
  }

  static String _extractBodyBackground(String html) {
    final match = RegExp(
      r'<body[^>]*style="[^"]*background:\s*([^;"]+)',
      caseSensitive: false,
    ).firstMatch(html);

    return match?.group(1)?.trim() ?? '#ffffff';
  }
}
