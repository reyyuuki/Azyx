import 'dart:math';
import 'package:flutter/material.dart';

class AzTokens {
  AzTokens._();

  static const double radiusCover = 20.0;
  static const double radiusCard = 22.0;
  static const double radiusCards = 22.0;
  static const double radiusSmallCard = 18.0;
  static const double radiusSmallCards = 18.0;
  static const double radiusPoster = 14.0;
  static const double radiusPosters = 14.0;
  static const double radiusChip = 14.0;
  static const double radiusChips = 14.0;
  static const double radiusButton = 25.0;
  static const double radiusTabContainer = 24.0;
  static const double radiusTabItem = 19.0;
  static const double radiusDock = 34.0;
  static const double radiusBottomSheet = 28.0;
  static const double radiusSearchBox = 26.0;

  static const double contentMaxWidth = 1180.0;
  static const double contentPaddingHorizontal = 24.0;
  static const double horizontalPadding = 24.0;
  static const double heroTopPadding = 96.0;
  static const double heroPaddingTop = 96.0;
  static const double heroBottomPadding = 28.0;
  static const double sectionGap = 48.0;

  static const double breakpointExpanded = 1080.0;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointExpanded;

  static double coverWidth(double screenWidth) {
    return max(128.0, min(0.22 * screenWidth, 220.0));
  }

  static double titleFontSize(double screenWidth) {
    return max(32.0, min(0.060 * screenWidth, 68.0));
  }

  static TextStyle titleStyle(BuildContext context, {Color? color}) {
    final width = MediaQuery.of(context).size.width;
    final size = titleFontSize(width);
    return TextStyle(
      fontFamily: 'Poppins-Bold',
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.02 * size,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle sectionHeading(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins-Bold',
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle h2(BuildContext context, {Color? color}) =>
      sectionHeading(context, color: color);

  static TextStyle subHeading(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15.0,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle h3(BuildContext context, {Color? color}) =>
      subHeading(context, color: color);

  static TextStyle body({
    BuildContext? context,
    Color? color,
    double? size,
    FontWeight? weight,
    double? height,
  }) {
    Color? resolvedColor = color;
    if (resolvedColor == null && context != null) {
      resolvedColor = Theme.of(context).colorScheme.onSurface;
    }
    final isBold = weight != null && weight.index >= FontWeight.w600.index;
    return TextStyle(
      fontFamily: isBold ? 'Poppins-Bold' : 'Poppins',
      fontSize: size ?? 14.5,
      fontWeight: weight ?? FontWeight.w400,
      height: height ?? 1.5,
      color: resolvedColor,
    );
  }

  static TextStyle caption([
    Color? color,
    double? size,
    FontWeight? weight,
  ]) {
    final isBold = weight != null && weight.index >= FontWeight.w600.index;
    return TextStyle(
      fontFamily: isBold ? 'Poppins-Bold' : 'Poppins',
      fontSize: size ?? 12.0,
      fontWeight: weight ?? FontWeight.w400,
      color: color,
    );
  }

  static TextStyle synopsis(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15.0,
      fontWeight: FontWeight.w400,
      height: 1.65,
      color: color ??
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.92),
    );
  }

  static TextStyle statNumber(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins-Bold',
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle statCaption(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle chipText({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle buttonText({Color? color}) {
    return TextStyle(
      fontFamily: 'Poppins-Bold',
      fontSize: 14.5,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
}
