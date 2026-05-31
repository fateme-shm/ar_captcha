# ar_captcha

A Flutter package to easily integrate ARCaptcha into your apps. It supports multiple display
modes—dialog, screen, and modal bottom sheet—with a modern UI, smooth loader animations, and full
customization options.

ARCaptcha is a privacy-friendly CAPTCHA solution designed to verify real users without intrusive
challenges, providing a secure and user-friendly way to prevent bots and automated abuse.
Ar Captcha pub.dev Package: https://pub.dev/packages/ar_captcha/
Official ARCaptcha service: https://arcaptcha.co/en/
---

## Platform support:

- iOS
- Web
- Android

![ArCaptcha Demo]
</br>
</br>
<img src="https://raw.githubusercontent.com/fateme-shm/ar_captcha/main/screen_shot_light.png" width="300" alt="ArCaptcha Light" />
<img src="https://raw.githubusercontent.com/fateme-shm/ar_captcha/main/screen_shot_dark.png" width="300" alt="ArCaptcha Dark" />

## Features

- ✅ Show captcha in *Dialog*, *Screen*, *Modal Bottom Sheet*, or *Responsive Dialog*
- Built-in *loading* animation
- Fully *theme-aware* (light/dark)
- Customizable *size*, *color*, and *behavior*
- Supports *invisible* and *normal* modes
- Clean *success/error* callback system
- Secure *HTML + JS bridge* with Flutter *WebView*
- Responsive UI for *desktop/tablet/mobile*

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ar_captcha: ^1.0.9
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:ar_captcha/ar_captcha.dart';

class MyCaptchaScreen extends StatelessWidget {
  final ArCaptchaController _controller = ArCaptchaController(
    lang: 'en',
    theme: ThemeMode.light,
    siteKey: 'YOUR_SITE_KEY',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Captcha Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _controller.showCaptcha(
              context: context,
              mode: CaptchaType.dialog,
              onSuccess: (token) {
                debugPrint("Captcha success: $token");
              },
              onError: (error) {
                debugPrint("Captcha failed: $error");
              },
            );
          },
          child: const Text("Show Captcha"),
        ),
      ),
    );
  }
}

```

## Captcha Display Modes
- CaptchaType.dialog
- CaptchaType.screen
- CaptchaType.modalBottomSheet
- CaptchaType.responsiveDialog

## Behavior Notes
- Dialog Mode
  - Fixed width & height
  - Good for desktop/tablet UX

- Screen Mode 
  - Full page captcha experience
  
- Modal Bottom Sheet
  - Mobile-friendly UX
  - Uses custom bottom sheet wrapper

- Responsive Dialog (NEW)
  - Automatically adapts to screen size
  - Uses maxResponsiveDialogWidth
  - Best default for mixed platforms

## API Reference

| Parameter                  | Type        | Description                             | Default         |
| -------------------------- | ----------- | --------------------------------------- | --------------- |
| `siteKey`                  | `String`    | Your ARCaptcha public site key          | Required        |
| `lang`                     | `String`    | Language code (`en`, `fa`)              | `en`            |
| `domain`                   | `String`    | App domain used by captcha service      | `localhost`     |
| `theme`                    | `ThemeMode` | Light or dark theme                     | `light`         |
| `color`                    | `Color`     | Primary UI color                        | `Colors.black`  |
| `dataSize`                 | `DataSize`  | `normal` or `invisible` mode            | `normal`        |
| `errorPrint`               | `int`       | Show error messages (0/1)               | `0`             |
| `captchaHeight`            | `double`    | Height of captcha container             | `550`           |
| `captchaWidth`             | `double`    | Width (dialog mode only)                | `550`           |
| `onErrorMessage`           | `String`    | Default error message                   | fallback string |
| `dialogBarrierDismissible` | `bool`      | Allow closing dialog by tapping outside | `true`          |
| `maxResponsiveDialogWidth` | `double`    | Max width for responsive dialog         | `600`           |
