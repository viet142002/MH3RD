import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mh3rd/core/di/injection.dart';
import '../../../domain/entities/others.dart';
import '../bloc/quest_bloc.dart';
import '../bloc/quest_event_state.dart';

class QuestListPage extends StatelessWidget {
  const QuestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          QuestBloc(filter: getIt(), search: getIt(), getDetail: getIt())
            ..add(const QuestListRequested(hub: QuestHub.village)),
      child: const _QuestListView(),
    );
  }
}

class _QuestListView extends StatefulWidget {
  const _QuestListView();

  @override
  State<_QuestListView> createState() => _QuestListViewState();
}

class _QuestListViewState extends State<_QuestListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final hub = _tabController.index == 0
            ? QuestHub.village
            : QuestHub.guild;
        context.read<QuestBloc>().add(QuestListRequested(hub: hub));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Village'),
            Tab(text: 'Guild'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (q) =>
                  context.read<QuestBloc>().add(QuestSearchChanged(q)),
              decoration: InputDecoration(
                hintText: 'Search quests...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<QuestBloc, QuestState>(
              builder: (context, state) {
                if (state is QuestLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is QuestListLoaded) {
                  final maxStars = state.hub == QuestHub.village ? 6 : 8;
                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            ...List.generate(maxStars, (index) {
                              final starValue = index + 1;
                              final isSelected = state.star == starValue;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text('$starValue \u2605'),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    context.read<QuestBloc>().add(
                                      QuestListRequested(
                                        hub: state.hub,
                                        star: selected ? starValue : null,
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Expanded(
                        child: state.filtered.isEmpty
                            ? const Center(child: Text('No quests found'))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: state.filtered.length,
                                itemBuilder: (context, i) {
                                  final q = state.filtered[i];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _getStarColor(q.star),
                                        child: Text(
                                          '${q.star}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          if (q.type == QuestType.key)
                                            _buildBadge('K', Colors.amber),
                                          if (q.type == QuestType.urgent)
                                            _buildBadge('U', Colors.red),
                                          if (q.type != QuestType.key &&
                                              q.type != QuestType.urgent)
                                            const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              q.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text('${q.no} \u2022 ${q.reward}z'),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        size: 20,
                                      ),
                                      onTap: () => context.go('/quests/${q.id}'),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }
                if (state is QuestError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
