import 'package:flutter/material.dart';
import '../../domain/entities/weapon.dart';
import '../constants/weapon_constants.dart';

// ─────────────────────────────────────────────
// SharpnessBar
// ─────────────────────────────────────────────

class SharpnessBar extends StatelessWidget {
  final List<int> sharpness;
  final List<int>? sharpnessp;
  final double height;
  final bool showLabel;

  const SharpnessBar({
    super.key,
    required this.sharpness,
    this.sharpnessp,
    this.height = 12,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Sharpness',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        _buildBar(sharpness, opacity: 1.0),
        if (sharpnessp != null) ...[
          const SizedBox(height: 3),
          _buildBar(sharpnessp!, opacity: 0.55),
        ],
      ],
    );
  }

  Widget _buildBar(List<int> data, {required double opacity}) {
    final total = data.fold(0, (sum, v) => sum + v);
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (int i = 0; i < data.length && i < kSharpnessColors.length; i++)
              if (data[i] > 0)
                Expanded(
                  flex: data[i],
                  child: ColoredBox(
                    color: kSharpnessColors[i].withOpacity(opacity),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ElementBadge
// ─────────────────────────────────────────────

class ElementBadge extends StatelessWidget {
  final WeaponElement? element;
  final int? value;
  final double fontSize;

  const ElementBadge({
    super.key,
    required this.element,
    this.value,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (element == null) return const SizedBox.shrink();
    final color = elementColor(element);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_elementIcon(element!), color: color, size: fontSize + 2),
          const SizedBox(width: 4),
          Text(
            value != null
                ? '${element!.displayName} $value'
                : element!.displayName,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _elementIcon(WeaponElement el) => switch (el) {
    WeaponElement.fire => Icons.local_fire_department,
    WeaponElement.water => Icons.water_drop,
    WeaponElement.thunder => Icons.bolt,
    WeaponElement.ice => Icons.ac_unit,
    WeaponElement.dragon => Icons.auto_awesome,
    WeaponElement.poison => Icons.science,
    WeaponElement.paralyze => Icons.electric_bolt,
    WeaponElement.sleep => Icons.bedtime,
    WeaponElement.blast => Icons.flare,
  };
}

// ─────────────────────────────────────────────
// RarityIndicator
// ─────────────────────────────────────────────

class RarityIndicator extends StatelessWidget {
  final int rarity;
  final double size;

  const RarityIndicator({super.key, required this.rarity, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(rarity);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.diamond, color: color, size: size),
        const SizedBox(width: 4),
        Text(
          'R$rarity',
          style: TextStyle(
            color: color,
            fontSize: size - 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SlotIndicator
// ─────────────────────────────────────────────

class SlotIndicator extends StatelessWidget {
  final int slots;
  final double size;

  const SlotIndicator({super.key, required this.slots, this.size = 13});

  @override
  Widget build(BuildContext context) {
    if (slots == 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        slots,
        (_) => Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            Icons.circle,
            size: size,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MaterialRow
// ─────────────────────────────────────────────

class MaterialRow extends StatelessWidget {
  final int materialId;
  final int count;
  final String? name;

  const MaterialRow({
    super.key,
    required this.materialId,
    required this.count,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '#${materialId.toString().substring(materialId.toString().length > 3 ? materialId.toString().length - 3 : 0)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name ?? 'Item #$materialId',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'x$count',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
