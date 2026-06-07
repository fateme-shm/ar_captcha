import '../enums/captcha_type.dart';

class CaptchaParams {
  final CaptchaType mode;
  final Function(String error) onError;
  final Function(String token) onSuccess;

  CaptchaParams({
    required this.mode,
    required this.onError,
    required this.onSuccess,
  });
}
