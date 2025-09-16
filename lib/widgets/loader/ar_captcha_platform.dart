/// Conditional export ensures the correct platform widget is used.
///
/// - On **Flutter Web** → `ar_captcha_web_section.dart`
/// - On **Flutter Mobile** → `ar_captcha_mobile_section.dart`
///
library;

export 'ar_captcha_stub.dart'
    if (dart.library.html) '../ar_captcha_web_section.dart'
    if (dart.library.io) '../ar_captcha_mobile_section.dart';
