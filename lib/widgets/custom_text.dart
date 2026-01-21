import 'package:flutter/material.dart';

enum VariantType {
  title,
  body,
  label,
  labelLarge,
  label1Bold,
  label2,
  label3,
  h3,
  h4,
  h5,
  label1
}

class CustomText extends StatelessWidget {
  final String text;
  final VariantType variant;
  final Color color;
  final TextAlign textAlign;
  final TextOverflow overflow;

  const CustomText({
    super.key,
    required this.text,
    required this.variant,
    this.color = Colors.black,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style = _getTextStyle(variant);

    return Text(
      text,
      style: style.copyWith(color: color),
      textAlign: textAlign,

      maxLines: null, // 제한 없음
      overflow: TextOverflow.visible, // 또는 제거
      softWrap: true, // 자동 줄바꿈 허용
    );
  }

  TextStyle _getTextStyle(VariantType variant) {
    switch (variant) {
      case VariantType.title:
        return TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        );
      case VariantType.body:
        return TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        );
      case VariantType.label:
        return TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        );
      case VariantType.labelLarge:
        return TextStyle(
          fontSize: 16.0,
          // lineHeight: 1.4,
        );
      case VariantType.label1Bold:
        return TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
        );
      case VariantType.label2:
        return TextStyle(
          fontSize: 14.0,
          height: 1.4,
          fontWeight: FontWeight.w400,
        );
      case VariantType.label3:
        return TextStyle(
          fontSize: 14.0,
          height: 1.4,
          fontWeight: FontWeight.w400,
        );

      case VariantType.h3:
        return TextStyle(
          fontSize: 32.0,
          height: 1.3,
          fontWeight: FontWeight.w700,
        );
      case VariantType.h4:
        return TextStyle(
          fontSize: 24.0,
          height: 1.35,
          fontWeight: FontWeight.w700,
        );
      case VariantType.h5:
        return TextStyle(
          fontSize: 20.0,
          height: 1.4,
          fontWeight: FontWeight.w700,
        );
      case VariantType.label1:
        return TextStyle(
          fontSize: 16.0,
          height: 1.5,
          fontWeight: FontWeight.normal,
        );
    }
  }
}
