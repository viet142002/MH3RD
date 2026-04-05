import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mh3rd/core/widgets/icon_widget.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/monster.dart';
import '../../../domain/entities/shared.dart';
import '../../../domain/usecases/usecases.dart';
import '../bloc/monster_bloc.dart';
import '../bloc/monster_event_state.dart';

class MonsterDetailPage extends StatelessWidget {
  final int id;
  const MonsterDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MonsterBloc(getAll: getIt(), getDetail: getIt(), search: getIt())
            ..add(MonsterDetailRequested(id)),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<MonsterBloc, MonsterState>(
            builder: (context, state) {
              if (state is MonsterDetailLoaded) {
                return Text(state.detail.monster.name);
              }
              return const Text('Monster Detail');
            },
          ),
        ),
        body: BlocBuilder<MonsterBloc, MonsterState>(
          builder: (context, state) {
            if (state is MonsterLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MonsterDetailLoaded) {
              return _MonsterDetailView(detail: state.detail);
            }
            if (state is MonsterError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _MonsterDetailView extends StatefulWidget {
  final MonsterDetail detail;
  const _MonsterDetailView({required this.detail});

  @override
  State<_MonsterDetailView> createState() => _MonsterDetailViewState();
}

class _MonsterDetailViewState extends State<_MonsterDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Rank _currentRank = Rank.low;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.detail.monster;
    return Column(
      children: [
        _buildRankSelector(),
        Expanded(
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Carves'),
                  Tab(text: 'Shinies'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCarvesList(m.carves),
                    _buildShiniesList(m.shinies),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Rank.values.map((rank) {
          final isSelected = _currentRank == rank;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(rank.name.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _currentRank = rank);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCarvesList(List<CarveGroup> groups) {
    if (groups.isEmpty) {
      return const Center(
        child: Text('No carves data available for this rank'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final drops = group.forRank(_currentRank);
        if (drops.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  group.partName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...drops.map((d) => _buildDropTile(d)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShiniesList(List<ShinyGroup> groups) {
    if (groups.isEmpty) {
      return const Center(
        child: Text('No shinies data available for this rank'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final drops = group.forRank(_currentRank);
        if (drops.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  group.action,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ...drops.map((d) => _buildDropTile(d)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropTile(DropEntry drop) {
    final item = widget.detail.items[drop.itemId];
    String icon = '${item?.icon}_${item?.color}';
    return ListTile(
      dense: true,
      leading: MhAssetIcon.item(icon),
      title: Text(item?.name ?? 'Unknown Item'),
      subtitle: drop.count > 1 ? Text('Quantity: ${drop.count}') : null,
      trailing: Text(
        '${drop.chance}%',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
