import 'package:flutter/material.dart';
import 'captcha_web_view_web.dart';

/// A platform-agnostic holder for rendering the captcha widget.
///
/// Depending on the platform (web or mobile), the exported implementation
/// will switch between:
/// - [ArCaptchaMobileDialog] (mobile)
/// - [ArCaptchaWebDialog] (web)
/// - a fallback [Container] (stub, should never be used).

class ArCaptchaSectionHolder extends StatefulWidget {
  final String htmlWidget;
  final bool showLoadingOverlay;
  final String? loadingText;
  final bool useInAppWebViewOnWeb;
  final bool enableDebugLogging;
  final double captchaHeight;
  final double captchaWidth;

  const ArCaptchaSectionHolder({
    super.key,
    required this.htmlWidget,
    this.showLoadingOverlay = false,
    this.loadingText,
    this.useInAppWebViewOnWeb = false,
    required this.enableDebugLogging,
    this.captchaHeight = 550,
    this.captchaWidth = 550,
  });

  @override
  State<ArCaptchaSectionHolder> createState() => _ArCaptchaSectionHolderState();
}

class _ArCaptchaSectionHolderState extends State<ArCaptchaSectionHolder> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    final captchaView = CaptchaWebViewWeb(
      html: widget.htmlWidget,
      captchaHeight: widget.captchaHeight,
      captchaWidth: widget.captchaWidth,
      useInAppWebViewOnWeb: widget.useInAppWebViewOnWeb,
      enableDebugLogging: widget.enableDebugLogging,
      onLoaded: () {
        if (!mounted) return;
        _log('captcha content reported ready; hiding Flutter overlay');
        setState(() => _isLoaded = true);
      },
      onSuccess: (payload) {
        if (!mounted) return;
        _log('captcha success callback received: $payload');
        Navigator.of(context).pop(payload);
      },
      onError: (error) {
        if (!mounted) return;
        _log('captcha error: $error');
        Navigator.of(context).pop();
      },
    );

    if (!widget.showLoadingOverlay) return captchaView;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: captchaView),
        if (!_isLoaded)
          Positioned.fill(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      widget.loadingText ?? 'Loading captcha ...',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  // ------------------------- Logger functions -------------------------

  void _log(String message) {
    if (widget.enableDebugLogging) {
      // ignore: avoid_print
      print('[ArCaptcha][Messages] $message');
    }
  }
}
