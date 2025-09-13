import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '/../res/enums/captcha_type.dart';
import '/../widgets/custom_modal_bottom_sheet.dart';
import '/../widgets/loader/ar_captcha_platform.dart';

/// Controller for displaying and managing ArCaptcha widgets
/// across different UI modes (dialog, screen, or modal bottom sheet).
class ArCaptchaController {
  /// The height of the captcha widget container.
  final double captchaHeight;

  /// Your ArCaptcha **site key** (required).
  final String siteKey;

  /// The language code (default: `en`).
  final String lang;

  /// The domain name of the app (default: `localhost`).
  /// If use in production mood you should pass domain Url
  final String domainUrl;

  /// Default error message when captcha fails.
  final String onErrorMessage;

  /// Stores the generated HTML content for the captcha widget.
  late final String _htmlContent;

  /// The theme mode (light or dark).
  final ThemeMode themeMode;

  /// Controls whether the modal bottom sheet can be dragged
  /// Defaults to `true` if not set.
  static bool? enableModalDrag;

  /// Controls whether the modal bottom sheet can be dismissed
  static bool? isModalDismissible;

  /// Controller used for `webview_flutter` (mobile).
  static WebViewController? webViewController;

  /// Controller used for `flutter_inappwebview` (web).
  static InAppWebViewController? inAppController;

  /// Constructor initializes required fields
  /// and builds the HTML section.
  ArCaptchaController({
    required this.siteKey,
    this.lang = 'en',
    this.domainUrl = 'localhost',
    this.onErrorMessage = 'Something went wrong, try again!',
    this.themeMode = ThemeMode.light,
    this.captchaHeight = 550,
  }) {
    _htmlContent = _buildHtmlSection();
  }

  /// Builds the ArCaptcha HTML content.
  ///
  /// This includes:
  /// - Styling (theme-aware)
  /// - Loader animation
  /// - Captcha widget
  /// - JavaScript handlers for success/error callbacks
  String _buildHtmlSection() {
    return '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <script src="https://widget.arcaptcha.ir/1/api.js?domain=$domainUrl" async defer></script>
          <style>
          
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
      
          body { 
            margin: 0; 
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; 
            transition: background 0.3s ease;
            overflow: hidden;
            background: ${themeMode == ThemeMode.light ? '#ffffff' : '#333333'};
          }     
          
          .arcaptcha {
            justify-content: center; 
            align-items: center; 
            min-height: 100vh; 
            display: flex; 
            padding: 24px;
            border-radius: 16px;
            max-width: 420px;
            width: 100%;
            background: ${themeMode == ThemeMode.light ? '#ffffff' : '#333333'};
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          }
      
         .loader {
            width: 48px;
            height: 48px;
            border: 4px solid transparent;
            border-top: 4px solid #0E53D9;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            position: relative;
          }
      
          .loader::after {
            content: '';
            position: absolute;
            top: 4px;
            left: 4px;
            right: 4px;
            bottom: 4px;
            border-radius: 50%;
            border: 4px solid transparent;
            border-top: 4px solid ${themeMode == ThemeMode.light ? '#ffffff' : '#333333'};
            animation: spin 1.2s linear infinite reverse;
          }

          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
      
          /* Fullscreen loader container */
          #loader {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            backdrop-filter: blur(2px);
            transition: opacity 0.3s ease;
          }
      
          /* Fade out loader */
          #loader.fade-out {
            opacity: 0;
            pointer-events: none;
          }
        </style>
        </head>
        <body>
          <!-- Loader -->
          <div id="loader">
              <span class="loader"></span>
          </div>
            
          <!-- ArCaptcha widget -->
          <div class="arcaptcha"
               data-site-key="$siteKey"
               data-lang="$lang"
               data-theme="${themeMode == ThemeMode.light ? 'light' : 'dark'}"
               data-callback="onVerified"
               data-error-callback="onError">
          </div>
          
          <script>
              <!-- Posts data back to Flutter (Android/iOS) or WebView (Web). -->  
              function post(type, payload = null) {     
                console.log("Posting to Flutter:", { type, payload }); 

                <!-- Callback for Web platforms -->  
                if (window.self !== window.top) {
                    window.parent.postMessage({ type: type, payload: payload }, '*');
                    console.log("Sent to parent.");
                } else {
                    window.postMessage({ type: type, payload: payload }, '*');
                    console.log("Sent to self (you probably don't want this).");
                } 
                                
                <!-- Callback for Android/IOS platforms -->   
                if(window.Captcha) {   
                  window.Captcha.postMessage(JSON.stringify({ type, payload }));
                }
              }
            
              <!-- Success callback -->
              function onVerified(token){ post("success", token); }
                            
              <!-- Error callback -->
              function onError(error){ post("error", error); }
            
              <!-- Show loader for captcha -->
              const checkInterval = setInterval(() => {
                  if (typeof arcaptcha !== 'undefined' && typeof arcaptcha.execute === 'function') {
                    clearInterval(checkInterval);
                    const loader = document.getElementById('loader');
                    if (loader) {
                      loader.style.display = 'none';
                    }
                  }
                }, 150);

          </script>
        </body>
        </html>
    ''';
  }

  /// Shows the captcha widget in the chosen [mode].
  ///
  /// [onSuccess] is called when the captcha is solved with a valid token.
  /// [onError] is called when captcha fails or closes without solving.
  ///
  Future<String?> showCaptcha({
    required BuildContext context,
    CaptchaType mode = CaptchaType.dialog,
    required Function(String error) onError,
    required Function(String token) onSuccess,
  }) async {
    String? token;

    switch (mode) {
      case CaptchaType.screen:
        token = await _showAsScreen(context);
      case CaptchaType.dialog:
        token = await _showAsDialog(context);
      case CaptchaType.modalBottomSheet:
        token = await _showAsBottomSheet(context);
    }

    if (token != null) {
      onSuccess(token);
    } else {
      onError(onErrorMessage);
    }

    return token;
  }

  /// Displays captcha inside a **Dialog** widget.
  Future<String?> _showAsDialog(BuildContext context) async {
    return await showDialog<String?>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: captchaHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ArCaptchaSectionHolder(htmlWidget: _htmlContent),
          ),
        ),
      ),
    );
  }

  /// Displays captcha as a full **Screen** using Navigator.push.
  Future<String?> _showAsScreen(BuildContext context) async {
    return await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Ar captcha screen'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: SafeArea(
            child: SizedBox.expand(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ArCaptchaSectionHolder(htmlWidget: _htmlContent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Displays captcha inside a **Modal Bottom Sheet**.
  Future<String?> _showAsBottomSheet(BuildContext context) async {
    Completer<String?> completer = Completer();

    CustomModalBottomSheet(
      bottomSheetModal: SizedBox(
        height: captchaHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ArCaptchaSectionHolder(htmlWidget: _htmlContent),
        ),
      ),
      actionOnCloseModal: (value) {
        completer.complete(value);
      },
    ).openBottomSheet(context: context);

    return await completer.future;
  }
}
