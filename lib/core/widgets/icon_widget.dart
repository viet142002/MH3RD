import 'package:flutter/material.dart';

enum IconCategory {
  elements('elements'),
  equipment('equipment'),
  items('items'),
  monsters('monsters');

  final String folder;
  const IconCategory(this.folder);
}

class MhAssetIcon extends StatelessWidget {
  final String name;
  final IconCategory category;
  final double? size;
  final Color? color;
  final BoxFit? fit;

  const MhAssetIcon({
    super.key,
    required this.name,
    required this.category,
    this.size,
    this.color,
    this.fit,
  });

  /// Shortcut for Item icons
  factory MhAssetIcon.item(
    String name, {
    double? size,
    Color? color,
    BoxFit? fit,
  }) {
    return MhAssetIcon(
      name: name,
      category: IconCategory.items,
      size: size,
      color: color,
      fit: fit,
    );
  }

  /// Shortcut for Element icons
  factory MhAssetIcon.element(
    String name, {
    double? size,
    Color? color,
    BoxFit? fit,
  }) {
    return MhAssetIcon(
      name: name,
      category: IconCategory.elements,
      size: size,
      color: color,
      fit: fit,
    );
  }

  /// Shortcut for Equipment icons
  factory MhAssetIcon.equipment(
    String name, {
    double? size,
    Color? color,
    BoxFit? fit,
  }) {
    return MhAssetIcon(
      name: name,
      category: IconCategory.equipment,
      size: size,
      color: color,
      fit: fit,
    );
  }

  /// Shortcut for Monster icons
  factory MhAssetIcon.monster(
    String name, {
    double? size,
    Color? color,
    BoxFit? fit,
  }) {
    return MhAssetIcon(
      name: name,
      category: IconCategory.monsters,
      size: size,
      color: color,
      fit: fit,
    );
  }

  String get assetPath {
    // Ensure we don't double up on extension if provided
    final fileName = name.toLowerCase().endsWith('.png') ? name : '$name.png';
    return 'assets/images/icons/${category.folder}/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color,
      fit: fit ?? BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading asset icon: $assetPath');
        return Icon(
          Icons.broken_image_outlined,
          size: size,
          color:
              color?.withValues(alpha: 0.5) ??
              Colors.grey.withValues(alpha: 0.5),
        );
      },
    );
  }
}
