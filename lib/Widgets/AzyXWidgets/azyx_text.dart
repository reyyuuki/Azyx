import 'package:flutter/material.dart';

enum FontVariant {
  regular,
  bold,
}

class AzyXText extends StatelessWidget {
  final String text;
  final FontVariant fontVariant;
  final TextAlign? textAlign;
  final double? fontSize;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? lineHeight;
  final FontStyle? fontStyle;

  const AzyXText(
      {super.key,
      required this.text,
      this.fontVariant = FontVariant.regular,
      this.textAlign,
      this.overflow = TextOverflow.clip,
      this.maxLines,
      this.color,
      this.fontSize,
      this.fontStyle,
      this.lineHeight});

  TextStyle _getTextStyle() {
    switch (fontVariant) {
      case FontVariant.bold:
        return TextStyle(
            fontFamily: "Poppins-Bold",
            fontSize: fontSize,
            color: color,
            fontStyle: fontStyle,
            height: lineHeight);
      case FontVariant.regular:
        return TextStyle(
            fontFamily: "Poppins",
            fontSize: fontSize,
            color: color,
            fontStyle: fontStyle,
            height: lineHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _getTextStyle(),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
