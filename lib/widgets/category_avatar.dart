import 'package:flutter/material.dart';

import '../core/constants/categories.dart';

class CategoryAvatar extends StatelessWidget {
  final CategoryInfo info;
  final double size;

  const CategoryAvatar({super.key, required this.info, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(info.icon, color: info.color, size: size * 0.5),
    );
  }
}
