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
  ar_captcha: ^1.0.2
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

| Parameter            | Type          | Description                                   | Default                            |
|----------------------|---------------|-----------------------------------------------|------------------------------------|
| `mode`               | `CaptchaType` | Show captcha in **dialog, screen, or modal**. | `CaptchaType.dialog`               |
| `siteKey`            | `String`      | Your ArCaptcha **site key** (required).       | –                                  |
| `lang`               | `String`      | Language code for captcha.                    | `en`                               |
| `domainUrl`          | `String`      | Domain name of the app.                       | `localhost`                        |
| `themeMode`          | `ThemeMode`   | Theme mode (light/dark).                      | `light`                            |
| `captchaHeight`      | `double`      | Height of the captcha widget container.       | `550`                              |
| `onErrorMessage`     | `String`      | Default error message if captcha fails.       | `Something went wrong, try again!` |
| `enableModalDrag`    | `bool`        | Controls whether the modal can be dragged.    | `true`                             |
| `isModalDismissible` | `bool`        | Controls whether the modal can be dismissed.  | `true`                             |
