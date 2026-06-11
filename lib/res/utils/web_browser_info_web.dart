import 'package:web/web.dart' as web;

bool get isSafariWeb {
  final userAgent = web.window.navigator.userAgent;
  return userAgent.contains('Safari') &&
      !userAgent.contains('Chrome') &&
      !userAgent.contains('Chromium') &&
      !userAgent.contains('CriOS') &&
      !userAgent.contains('FxiOS') &&
      !userAgent.contains('EdgiOS') &&
      !userAgent.contains('OPiOS');
}

bool get isIOSSafariWeb {
  final userAgent = web.window.navigator.userAgent;
  final isIOS = RegExp(r'iPad|iPhone|iPod').hasMatch(userAgent);

  return isIOS && isSafariWeb;
}
