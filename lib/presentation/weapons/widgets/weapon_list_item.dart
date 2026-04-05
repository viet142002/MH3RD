import 'package:flutter/material.dart';
import 'package:mh3rd/core/widgets/icon_widget.dart';
import '../../../../core/widgets/weapon_widgets.dart';
import '../../../../domain/entities/weapon.dart';

class WeaponListItem extends StatelessWidget {
  final Weapon weapon;
  final WeaponType weaponType;
  final VoidCallback onTap;

  const WeaponListItem({
    super.key,
    required this.weapon,
    required this.weaponType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   RarityIndicator(rarity: weapon.rarity),
                   const Spacer(),
                   if (weapon.slots > 0) SlotIndicator(slots: weapon.slots),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: MhAssetIcon.equipment(
                        "${weaponType.short}_rare${weapon.rarity}",
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weapon.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _InfoChip(
                              label: 'ATK: ${weapon.attack}',
                              icon: Icons.flash_on_outlined,
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              label: 'AFF: ${weapon.affinity > 0 ? '+' : ''}${weapon.affinity}%',
                              icon: Icons.percent,
                            ),
                          ],
                        ),
                        if (weapon.element != null) ...[
                          const SizedBox(height: 8),
                          _InfoChip(
                            label: '${weapon.elemAttack} ${weapon.element!.displayName}',
                            icon: Icons.water_drop_outlined,
                          ),
                        ]
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
