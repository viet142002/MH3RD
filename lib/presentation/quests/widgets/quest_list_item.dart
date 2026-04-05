import 'package:flutter/material.dart';
import '../../../domain/entities/others.dart';

class QuestListItem extends StatelessWidget {
  final Quest quest;
  final VoidCallback onTap;

  const QuestListItem({
    super.key,
    required this.quest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getStarColor(quest.star),
          child: Text(
            '${quest.star}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            if (quest.type == QuestType.key)
              _buildBadge('K', Colors.amber),
            if (quest.type == QuestType.urgent)
              _buildBadge('U', Colors.red),
            if (quest.type != QuestType.key && quest.type != QuestType.urgent)
              const SizedBox(width: 4),
            Expanded(
              child: Text(
                quest.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${quest.no} \u2022 ${quest.reward}z',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStarColor(int star) {
    if (star <= 2) return Colors.green;
    if (star <= 4) return Colors.blue;
    if (star <= 6) return Colors.orange;
    return Colors.red;
  }
}
