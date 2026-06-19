import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controller/ar_captcha_controller.dart';
import '../res/model/show_dialog_parameters.dart';
import '../res/utils/screen_size_util.dart';
import '../res/utils/web_browser_info.dart';

/// A fully adaptive dialog system that dynamically switches between
/// a centered dialog (desktop/tablet) and a modal bottom sheet (mobile).
///
/// This implementation is built on top of [showGeneralDialog] to allow
/// maximum flexibility over layout, animation, and interaction behavior.
///
/// ---------------------------------------------------------------------------
/// 🚀 Usage:
/// ---------------------------------------------------------------------------
/// ResponsiveDialog.show(
///   showDialogParam: ShowDialogParameters(
///     context: context,
///     dialogChildWidget: Widget(...),
///     barrierDismissible: true,
///     backgroundColor: Colors.white,
///     actionOnCloseModal: (value) {
///       print('value $value');
///     },
///   ),
/// );
///

Duration animationDuration = const Duration(milliseconds: 250);

class ResponsiveDialog {
  static Future<void> show({required ShowDialogParameters showDialogParam}) {
    return showGeneralDialog(
      barrierLabel: '',
      barrierColor: Colors.black45,
      context: showDialogParam.context,
      transitionDuration: animationDuration,
      barrierDismissible: showDialogParam.barrierDismissible,
      // routeSettings: const RouteSettings(
      //   name: RoutesName.customModalBottomSheet,
      // ),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return _AdaptiveDialogContainer(
          childWidget: showDialogParam.dialogChildWidget,
          barrierDismissible: showDialogParam.barrierDismissible,
        );
      },
    ).then((value) {
      if (showDialogParam.actionOnCloseModal != null) {
        showDialogParam.actionOnCloseModal!(value);
      }
    });
  }
}

class _AdaptiveDialogContainer extends StatelessWidget {
  final Widget childWidget;
  final bool barrierDismissible;

  const _AdaptiveDialogContainer({
    required this.childWidget,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;

    // Check if the screen is mobile
    bool isMobile = context.screenSizeType == DeviceScreenSizeType.mobile;
    final useStaticLayout = kIsWeb && isSafariWeb;

    final dialogContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMobile) ...[
          const SizedBox(height: 18),
          Container(
            width: screenWidth / 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Divider(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              thickness: 4,
              height: 4,
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: childWidget,
        ),
      ],
    );

    final dialogBox = Container(
      constraints: BoxConstraints(
        maxWidth: isMobile
            ? screenWidth
            : ArCaptchaController.getMaxResponsiveDialogWidth,
        minWidth: isMobile
            ? screenWidth
            : ArCaptchaController.getMaxResponsiveDialogWidth,
      ),
      decoration: BoxDecoration(
        color: isMobile
            ? theme.colorScheme.surfaceContainerLowest
            : Colors.transparent,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: Radius.circular(isMobile ? 0 : 16),
        ),
      ),
      child: dialogContent,
    );

    return PopScope(
      canPop: barrierDismissible,
      child: GestureDetector(
        onTap: () {
          if (barrierDismissible) Navigator.of(context).pop();
        },
        child: Material(
          color: Colors.transparent,
          child: useStaticLayout
              ? Align(
                  alignment:
                      isMobile ? Alignment.bottomCenter : Alignment.center,
                  child: dialogBox,
                )
              : AnimatedAlign(
                  duration: animationDuration,
                  curve: Curves.easeInOut,
                  alignment:
                      isMobile ? Alignment.bottomCenter : Alignment.center,
                  child: AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration: animationDuration,
                    constraints: dialogBox.constraints!,
                    decoration: dialogBox.decoration,
                    child: dialogContent,
                  ),
                ),
        ),
      ),
    );
  }
}
