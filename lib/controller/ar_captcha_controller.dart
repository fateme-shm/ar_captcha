import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '/../res/enums/data_size.dart';
import '/../res/enums/captcha_type.dart';
import '../res/model/captcha_params.dart';
import '../widgets/responsive_dialog.dart';
import '../res/model/show_dialog_parameters.dart';
import '/../widgets/custom_modal_bottom_sheet.dart';
import '/../widgets/loader/ar_captcha_platform.dart';
import '../res/utils/web_browser_info.dart';

/// Controller for displaying and managing ArCaptcha widgets
/// across different UI modes (dialog, screen, or modal bottom sheet).
class ArCaptchaController {
  /// The height of the captcha widget container.
  final double captchaHeight;

  /// The width of the captcha when modes is [CaptchaType.dialog]
  final double captchaWidth;

  /// Your ArCaptcha **site key** (required).
  final String siteKey;

  /// The language code (`en` or `fa`).
  final String lang;

  /// Set color of every colored element in widget.
  final Color color;

  /// The domain name of the app (default: `localhost`).
  final String domain;

  /// Controls the display mode of the captcha checkbox.
  final DataSize dataSize;

  /// Controls whether error messages appear below the captcha checkbox.
  final int errorPrint;

  /// Default error message when captcha fails.
  final String onErrorMessage;

  late final String _htmlContent;

  final ThemeMode theme;

  static bool? enableModalDrag;
  static bool? isModalDismissible;
  static WebViewController? webViewController;

  final double maxResponsiveDialogWidth;
  final bool dialogBarrierDismissible;
  final bool enableDebugLogging;

  ArCaptchaController({
    required this.siteKey,
    this.lang = 'en',
    this.domain = 'localhost',
    this.onErrorMessage = 'Something went wrong, try again!',
    this.errorPrint = 0,
    this.captchaWidth = 550,
    this.captchaHeight = 450,
    this.color = Colors.black,
    this.theme = ThemeMode.light,
    this.dataSize = DataSize.normal,
    this.dialogBarrierDismissible = true,
    this.maxResponsiveDialogWidth = 600,
    this.enableDebugLogging = true,
  }) {
    _log(
      'created domain=$domain siteKeyConfigured=${siteKey.isNotEmpty} '
      'lang=$lang dataSize=${dataSize.name} theme=${theme.name} '
      'captcha=${captchaWidth}x$captchaHeight isIOSSafariWeb=$isIOSSafariWeb',
    );
    _htmlContent = _buildHtmlSection();
  }

  void _log(String message) {
    if (enableDebugLogging) {
      // ignore: avoid_print
      print('[ArCaptcha][Controller] $message');
    }
  }

  static double get getMaxResponsiveDialogWidth {
    return ArCaptchaController(siteKey: '').maxResponsiveDialogWidth;
  }

  String colorToString(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

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
            --loader-shadow-1: rgba(${theme == ThemeMode.light ? '0' : '255'}, ${theme == ThemeMode.light ? '0' : '255'}, ${theme == ThemeMode.light ? '0' : '255'}, 0.2);
            --loader-shadow-2: rgba(${theme == ThemeMode.light ? '0' : '255'}, ${theme == ThemeMode.light ? '0' : '255'}, ${theme == ThemeMode.light ? '0' : '255'}, 0.5);
            --loader-shadow-3: rgba(${theme == ThemeMode.light ? '0' : '255'}, ${theme == ThemeMode.light ? '0' : '255'}, ${theme == ThemeMode.light ? '0' : '255'}, 0.7);
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
              const arCaptchaDebugEnabled = $enableDebugLogging;
              function arCaptchaLog(message, details = null) {
                if (!arCaptchaDebugEnabled) return;
                if (details == null) {
                  console.log('[ArCaptcha][JS]', message);
                } else {
                  console.log('[ArCaptcha][JS]', message, details);
                }
              }

              window.addEventListener('error', function(event) {
                arCaptchaLog('window error', {
                  message: event.message,
                  filename: event.filename,
                  line: event.lineno,
                  column: event.colno
                });
              });

              window.addEventListener('unhandledrejection', function(event) {
                arCaptchaLog('unhandled rejection', String(event.reason));
              });

              function post(type, payload = null) {     
                arCaptchaLog('postMessage', {
                  type: type,
                  payloadLength: typeof payload === 'string' ? payload.length : 0,
                  isTopWindow: window.self === window.top
                });
                if (window.self !== window.top) {
                    window.parent.postMessage({ type: type, payload: payload }, '*');
                } else {
                    window.postMessage({ type: type, payload: payload }, '*');
                } 
                                
                if(window.Captcha) {   
                  window.Captcha.postMessage(JSON.stringify({ type, payload }));
                }
              }
            
              function onVerified(token){
                arCaptchaLog('verified', { tokenLength: token ? token.length : 0 });
                post("success", token);
              }
              function onError(error){
                arCaptchaLog('provider error callback', String(error));
                post("error", error);
              }
            
              let readinessAttempts = 0;
              const checkInterval = setInterval(() => {
                readinessAttempts++;
                if (typeof arcaptcha !== 'undefined' && typeof arcaptcha.execute === 'function') {
                  clearInterval(checkInterval);
                  arCaptchaLog('API ready', { attempts: readinessAttempts });
                  const loader = document.getElementById('loader');
                  if (loader) {
                    loader.style.display = 'none';
                  }
                } else if (readinessAttempts === 20 || readinessAttempts === 50) {
                  arCaptchaLog('API still unavailable', {
                    attempts: readinessAttempts,
                    arcaptchaType: typeof arcaptcha
                  });
                }
              }, 150);

              window.onload = function() {
                arCaptchaLog('window loaded', {
                  href: window.location.href,
                  readyState: document.readyState,
                  invisible: ${dataSize == DataSize.invisible},
                  widgetCount: document.querySelectorAll('.arcaptcha').length
                });
                if(${dataSize == DataSize.invisible}) {
                  let executeAttempts = 0;
                  const checkInterval = setInterval(() => {
                    executeAttempts++;
                    if (typeof arcaptcha !== 'undefined' && typeof arcaptcha.execute === 'function') {
                      arCaptchaLog('executing invisible captcha', {
                        attempts: executeAttempts
                      });
                      arcaptcha.execute();
                      clearInterval(checkInterval);
                      post("execute-called");
                      
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

  Widget _buildSectionHolder() {
    _log('building section holder');
    return ArCaptchaSectionHolder(
      htmlWidget: _htmlContent,
      siteKey: siteKey,
      domain: domain,
      enableDebugLogging: enableDebugLogging,
    );
  }

  Future<String?> showCaptcha({
    required BuildContext context,
    CaptchaParams? params,
    CaptchaType mode = CaptchaType.dialog,
    required Function(String error) onError,
    required Function(String token) onSuccess,
  }) async {
    final resolved = params ??
        CaptchaParams(
          mode: mode,
          onError: onError,
          onSuccess: onSuccess,
        );
    final effectiveMode = _resolveModeForPlatform(resolved.mode);
    _log(
      'showCaptcha requestedMode=${resolved.mode.name} '
      'effectiveMode=${effectiveMode.name} mounted=${context.mounted}',
    );

    String? token;

    switch (effectiveMode) {
      case CaptchaType.screen:
        token = await _showAsScreen(context);
      case CaptchaType.dialog:
        token = await _showAsDialog(context);
      case CaptchaType.modalBottomSheet:
        token = await _showAsBottomSheet(context);
      case CaptchaType.responsiveDialog:
        token = await _showAsResponsiveDialog(context);
    }

    if (token != null) {
      _log('captcha completed tokenLength=${token.length}');
      resolved.onSuccess(token);
    } else {
      _log('captcha closed or failed without a token');
      resolved.onError(onErrorMessage);
    }

    return token;
  }

  CaptchaType _resolveModeForPlatform(CaptchaType mode) {
    if (!isIOSSafariWeb) {
      _log('keeping requested mode=${mode.name}');
      return mode;
    }

    _log('iOS Safari detected; resolving mode=${mode.name}');
    switch (mode) {
      case CaptchaType.screen:
        return CaptchaType.screen;
      case CaptchaType.dialog:
      case CaptchaType.modalBottomSheet:
      case CaptchaType.responsiveDialog:
        return CaptchaType.screen;
    }
  }

  Future<String?> _showAsDialog(BuildContext context) async {
    return await showDialog<String?>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          height: captchaHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildSectionHolder(),
          ),
        ),
      ),
    );
  }

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
                child: _buildSectionHolder(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showAsBottomSheet(BuildContext context) async {
    Completer<String?> completer = Completer();

    CustomModalBottomSheet(
      bottomSheetModal: SizedBox(
        height: captchaHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildSectionHolder(),
        ),
      ),
      actionOnCloseModal: (value) {
        completer.complete(value?.toString());
      },
    ).openBottomSheet(context: context);

    return await completer.future;
  }

  Future<String?> _showAsResponsiveDialog(BuildContext context) async {
    Completer<String?> completer = Completer();

    await ResponsiveDialog.show(
      showDialogParam: ShowDialogParameters(
        context: context,
        dialogChildWidget: SizedBox(
          height: captchaHeight,
          width: captchaWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildSectionHolder(),
          ),
        ),
        barrierDismissible: dialogBarrierDismissible,
        actionOnCloseModal: (value) => completer.complete(value?.toString()),
      ),
    );

    return await completer.future;
  }
}
