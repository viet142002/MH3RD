import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mh3rd/core/widgets/icon_widget.dart';
import '../../../core/di/injection.dart';
import '../bloc/monster_bloc.dart';
import '../bloc/monster_event_state.dart';

class MonsterListPage extends StatelessWidget {
  const MonsterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MonsterBloc(getAll: getIt(), getDetail: getIt(), search: getIt())
            ..add(const MonsterListRequested()),
      child: const _MonsterListView(),
    );
  }
}

class _MonsterListView extends StatefulWidget {
  const _MonsterListView();

  @override
  State<_MonsterListView> createState() => _MonsterListViewState();
}

class _MonsterListViewState extends State<_MonsterListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (q) =>
                  context.read<MonsterBloc>().add(MonsterSearchChanged(q)),
              decoration: InputDecoration(
                hintText: 'Search monsters...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<MonsterBloc, MonsterState>(
              builder: (context, state) {
                if (state is MonsterLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MonsterListLoaded) {
                  if (state.filtered.isEmpty) {
                    return const Center(child: Text('No monsters found'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: state.filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = state.filtered[i];
                      return Card(
                        child: ListTile(
                          leading: MhAssetIcon.monster(
                            m.name.replaceAll(' ', '_'),
                          ),
                          title: Text(
                            m.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () => context.push('/monsters/${m.id}'),
                        ),
                      );
                    },
                  );
                }
                if (state is MonsterError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
