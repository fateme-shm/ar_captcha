import 'package:web/web.dart' as web;

bool get isIOSSafariWeb {
  final userAgent = web.window.navigator.userAgent;
  final isIOS = RegExp(r'iPad|iPhone|iPod').hasMatch(userAgent);
  final isSafari = userAgent.contains('Safari') &&
      !userAgent.contains('Chrome') &&
      !userAgent.contains('Chromium');

  return isIOS && isSafari;
}
