import 'package:flutter/material.dart';
import 'package:get/get.dart';

void azyxSnackBar(
  String title, {
  String? subtitle,
  double? width,
  Icon? icon,
  Duration? duration,
}) {
  final context = Get.context ?? Get.overlayContext;
  if (context == null) return;

  final colorScheme = Theme.of(context).colorScheme;
  final bottomInset = MediaQuery.of(context).padding.bottom;

  if (Get.isSnackbarOpen) {
    Get.closeCurrentSnackbar();
  }

  Get.rawSnackbar(
    snackPosition: SnackPosition.BOTTOM,
    snackStyle: SnackStyle.FLOATING,
    maxWidth: width ?? 400,
    duration: duration ?? const Duration(milliseconds: 2200),
    animationDuration: const Duration(milliseconds: 240),
    backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
    barBlur: 22.0,
    borderRadius: 28.0,
    borderColor: colorScheme.outlineVariant.withValues(alpha: 0.28),
    borderWidth: 0.8,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.24),
        blurRadius: 20,
        spreadRadius: -4,
        offset: const Offset(0, 8),
      ),
    ],
    margin: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 20),
    padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
    messageText: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon.icon,
              size: 16,
              color: icon.color ?? colorScheme.primary,
            ),
          )
        else
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/icon.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(width: 11),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
