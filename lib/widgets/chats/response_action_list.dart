import 'package:flutter/material.dart';

class ResponseActionList extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponseActionList({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          children[i],
        ],
      ],
    );
  }
}
