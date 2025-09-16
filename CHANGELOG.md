## 1.0.0

- Initial release of **ar_captcha** 🎉
- Added support for rendering ArCaptcha in multiple modes:
    - **Full screen page** (`CaptchaType.screen`)
    - **Dialog** (`CaptchaType.dialog`)
    - **Modal bottom sheet** (`CaptchaType.modalBottomSheet`)
- Provided `ArCaptchaController` for configuration and lifecycle handling.
- Added success and error callbacks to handle captcha responses.
- Web and mobile platform support with unified API.

# 1.0.1
- Fix reported bug

# 1.0.2
- Add supported platform
- Added support for dark theme

# 1.0.3
- Fixed Navigator pop issues in web dialogs to prevent _debugLocked errors.
- Added conditional execution of the captcha script based on DataSize (normal vs invisible).
- Improved color handling with extended list of supported Material colors in colorToString().
- Updated documentation for ArCaptchaController properties and HTML data-* attributes.
- Minor bug fixes and performance improvements for WebView and InAppWebView integration.
- Fix reported bug

# 1.0.4
- Change color convertor to get all color data

