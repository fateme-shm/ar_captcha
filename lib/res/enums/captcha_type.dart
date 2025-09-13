/// Defines how the captcha widget should be displayed in the app.
enum CaptchaType {
  /// Displays captcha in a **full screen page** with an AppBar.
  screen,

  /// Displays captcha inside a **dialog box** (popup overlay).
  dialog,

  /// Displays captcha inside a **modal bottom sheet**.
  modalBottomSheet,
}
