import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mh3rd/core/di/injection.dart';
import 'package:mh3rd/core/widgets/icon_widget.dart';
import '../bloc/quest_bloc.dart';
import '../bloc/quest_event_state.dart';
import '../../../domain/usecases/usecases.dart';
import '../../../domain/entities/others.dart';

class QuestDetailPage extends StatelessWidget {
  final int id;
  const QuestDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          QuestBloc(filter: getIt(), search: getIt(), getDetail: getIt())
            ..add(QuestDetailRequested(id)),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<QuestBloc, QuestState>(
            builder: (context, state) {
              if (state is QuestDetailLoaded) {
                return Text(state.detail.quest.name);
              }
              return const Text('Quest Detail');
            },
          ),
        ),
        body: BlocBuilder<QuestBloc, QuestState>(
          builder: (context, state) {
            if (state is QuestLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is QuestDetailLoaded) {
              return _QuestDetailView(state.detail);
            }
            if (state is QuestError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _QuestDetailView extends StatelessWidget {
  final QuestDetailData detail;
  const _QuestDetailView(this.detail);

  @override
  Widget build(BuildContext context) {
    final q = detail.quest;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          q.hub.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (q.type == QuestType.key)
                          _buildBadge('KEY', Colors.amber),
                        if (q.type == QuestType.urgent)
                          _buildBadge('URGENT', Colors.red),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        q.star,
                        (index) => const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  q.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('ID: ${q.no}', style: const TextStyle(color: Colors.grey)),
                const Divider(height: 32),
                _buildInfoRow(Icons.monetization_on, 'Reward', '${q.reward}z'),
                _buildInfoRow(
                  Icons.access_time,
                  'Time/Map',
                  '${q.time ?? "Any"} / Map ${q.mapId ?? "?"}',
                ),
                if (q.unlockCondition != null && q.unlockCondition!.isNotEmpty)
                  _buildInfoRow(
                    Icons.lock_open,
                    'Condition',
                    q.unlockCondition!,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Objectives',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...q.objectives.map((o) {
          final monster = detail.monsters[o.targetId];
          final item = detail.items[o.targetId];
          final name = monster?.name ?? item?.name ?? 'Target #${o.targetId}';
          final icon = monster != null
              ? MhAssetIcon.monster(monster.name.replaceAll(' ', '_'))
              : (item != null
                    ? MhAssetIcon.item('${item.icon}_${item.color}')
                    : const Icon(Icons.help_outline));

          return Card(
            child: ListTile(
              leading: icon,
              title: Text(
                '${o.action.toUpperCase()} $name',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Quantity: ${o.quantity}'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                if (monster != null) {
                  context.push('/monsters/${o.targetId}');
                } else if (item != null) {
                  context.push('/items/${o.targetId}');
                }
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
