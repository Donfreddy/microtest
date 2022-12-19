import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

enum MessageType { info, success, error }

void showTopMessage(
  BuildContext context, {
  required String message,
  MessageType type = MessageType.info,
}) {
  switch (type) {
    case MessageType.info:
      showTopSnackBar(
        context,
        CustomSnackBar.info(
          message: message,
          textStyle:
              const TextStyle().copyWith(fontSize: 12, color: Colors.white),
          messagePadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        dismissType: DismissType.onSwipe,
        displayDuration: const Duration(milliseconds: 5000),
      );
      break;
    case MessageType.success:
      showTopSnackBar(
        context,
        CustomSnackBar.success(
          message: message,
          textStyle:
              const TextStyle().copyWith(fontSize: 12, color: Colors.white),
          messagePadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        dismissType: DismissType.onSwipe,
        displayDuration: const Duration(milliseconds: 5000),
      );
      break;
    case MessageType.error:
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: message,
          textStyle:
              const TextStyle().copyWith(fontSize: 12, color: Colors.white),
          messagePadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        dismissType: DismissType.onSwipe,
        displayDuration: const Duration(milliseconds: 5000),
      );
      break;
  }
}
