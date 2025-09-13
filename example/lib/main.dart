import 'package:flutter/material.dart';
import 'package:ar_captcha/ar_captcha.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ar Captcha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Ar captcha'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ArCaptchaController arCaptchaController = ArCaptchaController(
    lang: 'en',
    siteKey: 'YOUR_SITE_KEY',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            arCaptchaController.showCaptcha(
              context: context,
              mode: CaptchaType.dialog,
              onSuccess: (token) {
                // The success function return captcha token key
                debugPrint("Captcha success: $token");
              },
              onError: (error) {
                // Return onErrorMessage that you gave in controller
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
