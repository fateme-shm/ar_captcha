import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '/../res/enums/data_size.dart';
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

  /// The language code (`en` or `fa`).
  final String lang;

  /// Set color of every colored element in widget.
  /// Like checkbox color
  /// See supported color in colorToString() function
  final Color color;

  /// The domain name of the app (default: `localhost`).
  /// If use in production mood you should pass domain Url
  final String domain;

  /// Controls the display mode of the captcha checkbox.
  ///
  /// - `DataSize.normal` (default) → Checkbox is visible and shown automatically before captcha execution.
  /// - `DataSize.invisible` → Checkbox is hidden; captcha executes without showing the checkbox.
  final DataSize dataSize;

  /// Controls whether error messages appear below the captcha checkbox.
  ///
  /// - `0` (default) → Error messages are shown.
  /// - `1` → Error messages are disabled.
  final int errorPrint;

  /// Default error message when captcha fails.
  final String onErrorMessage;

  /// Stores the generated HTML content for the captcha widget.
  late final String _htmlContent;

  /// The theme mode (light or dark).
  final ThemeMode theme;

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
    this.domain = 'localhost',
    this.onErrorMessage = 'Something went wrong, try again!',
    this.errorPrint = 0,
    this.captchaHeight = 550,
    this.color = Colors.black,
    this.theme = ThemeMode.light,
    this.dataSize = DataSize.normal,
  }) {
    _htmlContent = _buildHtmlSection();
  }

  /// Converts a [Color] object to a CSS-compatible hex color string in the format `#RRGGBB`.
  ///
  /// This function ignores the alpha channel (opacity), making it suitable for contexts
  /// that expect opaque colors (e.g., HTML/CSS attributes, web widgets).
  ///
  /// Example:
  ///   - `Colors.red` → `"#FF0000"`
  ///   - `Color(0xFFFF5722)` → `"#FF5722"`
  ///
  /// Note: If transparency is required, consider using an `rgba()` format instead.
  String colorToString(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
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
          <script src="https://widget.arcaptcha.ir/1/api.js?domain=$domain" async defer></script>
          <style>
          
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          
          :root {
            --loader-color: ${theme == ThemeMode.light ? '#ffffff' : '#000000'};
            --loader-shadow-1: rgba(0, 0, 0, 0.2);
            --loader-shadow-2: rgba(0, 0, 0, 0.5);
            --loader-shadow-3: rgba(0, 0, 0, 0.7);
          }
          
          body { 
            margin: 0; 
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; 
          }     
          
          #arcaptcha_full_body_container{
            background-color: "";
          }
          
          .arcaptcha {
            justify-content: center; 
            align-items: center; 
            min-height: 100vh; 
            display: flex; 
            padding: 24px;
            border-radius: 16px;
            width: 100%;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          }
      
          .loader {
            font-size: 10px;
            width: 1em;
            height: 1em;
            border-radius: 50%;
            position: relative;
            text-indent: -9999em;
            animation: mulShdSpin 1.1s infinite ease;
            transform: translateZ(0);
            background: background: ${dataSize == DataSize.invisible ? 'transparent' : theme == ThemeMode.light ? '#ffffff' : '#333333'}; !important;
          }

          @keyframes mulShdSpin {
            0%, 100% {
              box-shadow:
                0em -2.6em 0em 0em var(--loader-color),
                1.8em -1.8em 0 0em var(--loader-shadow-1),
                2.5em 0em 0 0em var(--loader-shadow-1),
                1.75em 1.75em 0 0em var(--loader-shadow-1),
                0em 2.5em 0 0em var(--loader-shadow-1),
                -1.8em 1.8em 0 0em var(--loader-shadow-1),
                -2.6em 0em 0 0em var(--loader-shadow-2),
                -1.8em -1.8em 0 0em var(--loader-shadow-3);
            }
            12.5% {
              box-shadow:
                0em -2.6em 0em 0em var(--loader-shadow-3),
                1.8em -1.8em 0 0em var(--loader-color),
                2.5em 0em 0 0em var(--loader-shadow-1),
                1.75em 1.75em 0 0em var(--loader-shadow-1),
                0em 2.5em 0 0em var(--loader-shadow-1),
                -1.8em 1.8em 0 0em var(--loader-shadow-1),
                -2.6em 0em 0 0em var(--loader-shadow-1),
                -1.8em -1.8em 0 0em var(--loader-shadow-2);
            }
            25% {
              box-shadow:
                0em -2.6em 0em 0em var(--loader-shadow-2),
                1.8em -1.8em 0 0em var(--loader-shadow-3),
                2.5em 0em 0 0em var(--loader-color),
                1.75em 1.75em 0 0em var(--loader-shadow-1),
                0em 2.5em 0 0em var(--loader-shadow-1),
                -1.8em 1.8em 0 0em var(--loader-shadow-1),
                -2.6em 0em 0 0em var(--loader-shadow-1),
                -1.8em -1.8em 0 0em var(--loader-shadow-1);
            }
            37.5% {
              box-shadow:
                0em -2.6em 0em 0em var(--loader-shadow-1),
                1.8em -1.8em 0 0em var(--loader-shadow-2),
                2.5em 0em 0 0em var(--loader-shadow-3),
                1.75em 1.75em 0 0em var(--loader-color),
                0em 2.5em 0 0em var(--loader-shadow-1),
                -1.8em 1.8em 0 0em var(--loader-shadow-1),
                -2.6em 0em 0 0em var(--loader-shadow-1),
                -1.8em -1.8em 0 0em var(--loader-shadow-1);
            }
            50% {
              box-shadow:
                0em -2.6em 0em 0em var(--loader-shadow-1),
                1.8em -1.8em 0 0em var(--loader-shadow-1),
                2.5em 0em 0 0em var(--loader-shadow-2),
                1.75em 1.75em 0 0em var(--loader-shadow-3),
                0em 2.5em 0 0em var(--loader-color),
                -1.8em 1.8em 0 0em var(--loader-shadow-1),
                -2.6em 0em 0 0em var(--loader-shadow-1),
                -1.8em -1.8em 0 0em var(--loader-shadow-1);
            }
            62.5% {
              box-shadow:
                0em -2.6em 0em 0em var(--loader-shadow-1),
                1.8em -1.8em 0 0em var(--loader-shadow-1),
                2.5em 0em 0 0em var(--loader-shadow-1),
                1.75em 1.75em 0 0em var(--loader-shadow-2),
                0em 2.5em 0 0em var(--loader-shadow-3),
                -1.8em 1.8em 0 0em var(--loader-color),
                -2.6em 0em 0 0em var(--loader-shadow-1),
                -1.8em -1.8em 0 0em var(--loader-shadow-1);
            }
            75% {
              box-shadow:
                0em -2.6em 0em 0em var(--loader-shadow-1),
                1.8em -1.8em 0 0em var(--loader-shadow-1),
                2.5em 0em 0 0em var(--loader-shadow-1),
                1.75em 1.75em 0 0em var(--loader-shadow-1),
                0em 2.5em 0 0em var(--loader-shadow-2),
                -1.8em 1.8em 0 0em var(--loader-shadow-3),
                -2.6em 0em 0 0em var(--loader-color),
                -1.8em -1.8em 0 0em var(--loader-shadow-1);
            }
            87.5% {
              box-shadow:
                0em -2.6em 0em 0em var(--loader-shadow-1),
                1.8em -1.8em 0 0em var(--loader-shadow-1),
                2.5em 0em 0 0em var(--loader-shadow-1),
                1.75em 1.75em 0 0em var(--loader-shadow-1),
                0em 2.5em 0 0em var(--loader-shadow-1),
                -1.8em 1.8em 0 0em var(--loader-shadow-2),
                -2.6em 0em 0 0em var(--loader-shadow-3),
                -1.8em -1.8em 0 0em var(--loader-color);
            }
          }      
        
        </style>
        </head>
        <body style="background: ${dataSize == DataSize.invisible ? 'transparent' : theme == ThemeMode.light ? '#ffffff' : '#333333'}; margin: 0; padding: 0;">
          <div id="loader" style="
          position: fixed;
          top: 0; left: 0;
          width: 100%; height: 100%;
          background: background: ${dataSize == DataSize.invisible ? 'transparent' : theme == ThemeMode.light ? '#ffffff' : '#333333'};;
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 9999;
        ">
          <span class="loader"></span>
        </div>
            
          <!-- ArCaptcha widget -->
          <div class="arcaptcha"
               data-site-key="$siteKey"
               data-lang="$lang"
               data-color="${colorToString(color)}"
               data-error-print="${errorPrint.toString()}"
               data-theme="${theme == ThemeMode.light ? 'light' : 'dark'}"
               data-size="${dataSize.name}"
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

              <!-- Automatically check the checkbox if enabled -->
              window.onload = function() {
                if(${dataSize == DataSize.invisible}) {
                  const checkInterval = setInterval(() => {
                    if (typeof arcaptcha !== 'undefined' && typeof arcaptcha.execute === 'function') {
                      arcaptcha.execute();
                      clearInterval(checkInterval);
                      post("execute-called");
                      
                      <!-- Remove loader display -->
                      const loader = document.getElementById('loader');
                      if (loader) {
                        loader.style.display = 'none';
                      }
                    }
                  }, 150);
                }
              };


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
        backgroundColor: Colors.transparent,
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
