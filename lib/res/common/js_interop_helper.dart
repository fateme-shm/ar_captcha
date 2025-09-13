import 'dart:js_interop';

/// A JavaScript interop binding for the captcha message object.
///
/// This represents the structure of messages posted from the ArCaptcha
/// JavaScript widget into Flutter's Web environment.
///
/// Expected shape:
/// ```js
/// { type: "success" | "error", payload: "token-or-error" }
/// ```
@JS()
@staticInterop
class JsCaptchaMessage {}

/// Extension to access fields of [JsCaptchaMessage].
extension JsCaptchaMessageExt on JsCaptchaMessage {
  /// Message type coming from JS (e.g., `"success"` or `"error"`).
  external JSString? get type;

  /// Payload of the message (captcha token on success, error details otherwise).
  external JSString? get payload;
}

/// Converts a JavaScript message object ([JSAny]) into a Dart [Map].
///
/// Returns:
/// - `{"type": "...", "payload": "..."}` if the conversion succeeds
/// - `{"type": null, "payload": null}` if parsing fails or the object
///   does not match [JsCaptchaMessage].
///
/// Example:
/// ```dart
/// final data = convertCaptchaWebPostMessagesFromJs(jsMessage);
/// if (data['type'] == 'success') {
///   print('Captcha token: ${data['payload']}');
/// }
/// ```
Map<String, String?> convertCaptchaWebPostMessagesFromJs(JSAny jsAny) {
  try {
    final jsObject = jsAny as JsCaptchaMessage;

    // Safely convert JSString? to Dart String, defaulting to empty string
    final type = jsObject.type?.toDart ?? '';
    final payload = jsObject.payload?.toDart ?? '';

    return {'type': type, 'payload': payload};
  } catch (e) {
    // Fallback in case jsAny isn't a JsCaptchaMessage
    return {'type': null, 'payload': null};
  }
}
