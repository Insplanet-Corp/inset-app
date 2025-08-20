import 'package:flutter/material.dart';
import 'custom_button.dart';

class ImageUploadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ImageUploadButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      variant: 'primary',
      size: 'large',
      text: '이미지 업로드',
      isFullWidth: true,
      onPressed: onPressed,
    );
  }
}
