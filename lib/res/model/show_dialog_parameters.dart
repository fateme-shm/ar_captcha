import 'package:flutter/material.dart';

// Use this class in changeable dialog
class ShowDialogParameters {
  final BuildContext context;

  final bool barrierDismissible;

  final Widget dialogChildWidget;

  final Function(dynamic)? actionOnCloseModal;

  ShowDialogParameters({
    this.actionOnCloseModal,
    this.barrierDismissible = true,
    required this.context,
    required this.dialogChildWidget,
  });
}
