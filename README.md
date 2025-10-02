# ar_captcha

A Flutter package to easily integrate ARCaptcha into your apps. It supports multiple display
modes—dialog, screen, and modal bottom sheet—with a modern UI, smooth loader animations, and full
customization options.

ARCaptcha is a privacy-friendly CAPTCHA solution designed to verify real users without intrusive
challenges, providing a secure and user-friendly way to prevent bots and automated abuse.

Official ARCaptcha service: https://arcaptcha.co/en/
---

## Platform support:

- iOS
- Web
- Android

![ArCaptcha Demo]
</br>
</br>
<img src="https://raw.githubusercontent.com/fateme-shm/ar_captcha/main/demo.png" width="300" alt="ArCaptcha Demo" />
<img src="https://raw.githubusercontent.com/fateme-shm/ar_captcha/main/demo_1.png" width="300" alt="ArCaptcha Demo" />

## Features

- ✅ Show captcha in **dialog, screen, or modal bottom sheet**
- ✅ Built-in **loader animation** while captcha loads
- ✅ Works on **Android, iOS, and Web**
- ✅ **Customizable height** for captcha container
- ✅ Supports **dark and light theme** modes
- ✅ Easy **success/error callbacks**
- ✅ Secure HTML + JS integration with Flutter bridges

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ar_captcha: ^1.0.5
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

## API Reference

| Parameter / Attribute             | Type               | Description                                                                                           | Default / Required                 |
|-----------------------------------|--------------------|-------------------------------------------------------------------------------------------------------|------------------------------------|
| `siteKey` / `data-site-key`       | `String`           | Your ArCaptcha **public API site key**. Required to load the captcha.                                 | Required                           |
| `dataSize` / `data-size`          | `DataSize`         | Controls checkbox display mode: `normal` (visible) or `invisible` (hidden, executes automatically).   | `DataSize.normal`                  |
| `theme` / `data-theme`            | `ThemeMode`        | Theme of the widget: `light` or `dark`.                                                               | `ThemeMode.light`                  |
| `color` / `data-color`            | `Color`            | Sets color of all colored elements in the widget (checkbox, loader). Can be a color name or hex code. | `Colors.black`                     |
| `errorPrint` / `data-error-print` | `int`              | Controls error messages below checkbox: `0` → enabled, `1` → disabled.                                | `0`                                |
| `lang` / `data-lang`              | `String`           | Language of the widget: e.g., `en` or `fa`.                                                           | `'en'`                             |
| `onSuccess` / `data-callback`     | `Function(String)` | Called when captcha is solved successfully. The **token** is passed to this callback.                 | Optional                           |
| `onError` / `data-error-callback` | `Function(String)` | Called when captcha fails or encounters an error.                                                     | Optional                           |
| `captchaHeight`                   | `double`           | Height of the captcha container in Flutter.                                                           | `550`                              |
| `domain` / `data-domain`          | `String`           | Domain name of the app. Used to load the captcha script correctly.                                    | `'localhost'`                      |
| `enableModalDrag`                 | `bool`             | Controls whether modal bottom sheet can be dragged.                                                   | `true`                             |
| `isModalDismissible`              | `bool`             | Controls whether modal bottom sheet can be dismissed by tapping outside.                              | `true`                             |
| `onErrorMessage`                  | `String`           | Default error message if captcha fails.                                                               | `Something went wrong, try again!` |
