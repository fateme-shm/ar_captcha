import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '/../controller/ar_captcha_controller.dart';

/// A reusable wrapper around [showCupertinoModalBottomSheet] that
/// displays the captcha (or any widget) inside a Cupertino-style
/// modal bottom sheet.
///
/// The modal’s drag and dismiss behavior can be configured globally
/// using [ArCaptchaController.enableModalDrag] and
/// [ArCaptchaController.isModalDismissible].
///
class CustomModalBottomSheet {
  /// The widget to display inside the modal bottom sheet.
  final Widget bottomSheetModal;

  /// Optional callback invoked when the modal is closed.
  ///
  /// Receives the result passed to `Navigator.pop(...)` inside
  /// the modal.
  final Function(dynamic)? actionOnCloseModal;

  const CustomModalBottomSheet({
    this.actionOnCloseModal,
    required this.bottomSheetModal,
  });

  /// Opens the bottom sheet using [showCupertinoModalBottomSheet].
  ///
  /// The modal includes a Cupertino-style navigation bar with
  /// a visual drag handle.
  void openBottomSheet({required BuildContext context}) {
    showCupertinoModalBottomSheet(
      context: context,
      enableDrag: ArCaptchaController.enableModalDrag ?? true,
      useRootNavigator: true,
      isDismissible: ArCaptchaController.isModalDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (context) => Material(
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            automaticallyImplyLeading: false,
            border: null,
            backgroundColor: Theme.of(context).colorScheme.surface,
            middle: Container(
              width: MediaQuery.of(context).size.width / 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Divider(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.4),
                thickness: 4,
                height: 4,
              ),
            ),
          ),
          child: SafeArea(bottom: false, child: bottomSheetModal),
        ),
      ),
    ).then((value) {
      if (actionOnCloseModal != null) actionOnCloseModal!(value);
    });
  }
}
