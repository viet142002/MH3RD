import 'package:flutter/material.dart';
import 'package:mh3rd/core/widgets/icon_widget.dart';
import '../../../domain/entities/monster.dart';

class MonsterListItem extends StatelessWidget {
  final Monster monster;
  final VoidCallback onTap;

  const MonsterListItem({
    super.key,
    required this.monster,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: MhAssetIcon.monster(
              monster.name.replaceAll(' ', '_'),
            ),
          ),
        ),
        title: Text(
          monster.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
