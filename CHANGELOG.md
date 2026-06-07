
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

# 1.0.5

- Remove background color in invisible mode
- Fix some reported bug

# 1.0.6

- Change loader color in dark mode
- Fix some reported bug

# 1.0.7

- Fix loader color in dark mode

# 1.0.8

- Add platform support for macOS, windows, linux
- Add new screenshot of UI package

# 1.0.9

- Remove InAppWebView library because of internet problem in some country
- Use HtmlElementView instead of InAppWebView
- Add `captchaWidth` in dialog mode of captcha
- Fix reported issue

# 1.1.0

- Added `Responsive Dialog` mode
    - Automatically switches between modal bottom sheet (mobile) and dialog (desktop/tablet)
- Improved adaptive UI behavior across platforms

# 1.1.1

- Added `WASM` for web
- Fix reported bug

# 1.1.2

- Fix Safari/iOS white screen on web by rendering captcha in an iframe via `srcdoc` instead of a sandboxed `data:` URL
- Add `CaptchaWebViewWeb` widget (Safari-compatible web embedding used by authorization-module)
- Load ARCaptcha script with `async defer` for more reliable initialization

# 1.1.4

- Port full authorization-module captcha web stack (`CaptchaWebViewWeb` + `ArCaptchaSectionHolder`)
- Match auth-module controller defaults (`captchaHeight: 450`, dialog without fixed width, `CaptchaParams` API)
- Register iframe view factory once in `initState` (fixes Flutter web platform-view re-registration)
- Single `postMessage` listener via `js_interop_helper` (avoids double `Navigator.pop` on Safari)
- Pass `siteKey` / `domain` through `ArCaptchaSectionHolder` for host-app integrations

# 1.1.5
- Fix iOS Safari web rendering by loading captcha HTML through a `Blob` URL instead of `iframe.srcdoc`
- Add iframe `sandbox` / `allow` attributes for more reliable ARCaptcha script execution on web
- Force `CaptchaType.screen` on iOS Safari web when dialog-style modes are requested
