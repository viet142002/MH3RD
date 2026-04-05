import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../bloc/monster_bloc.dart';
import '../bloc/monster_event_state.dart';
import '../widgets/monster_filter_sheet.dart';
import '../widgets/monster_list_item.dart';

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
  bool _isSheetOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    final monsterBloc = context.read<MonsterBloc>();
    setState(() => _isSheetOpen = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MonsterFilterSheet(
        searchController: _searchController,
        monsterBloc: monsterBloc,
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isSheetOpen = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<MonsterBloc, MonsterState>(
                buildWhen: (previous, current) => !_isSheetOpen,
                builder: (context, state) {
                  if (state is MonsterLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MonsterListLoaded) {
                    if (state.filtered.isEmpty) {
                      return const Center(child: Text('No monsters found'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      itemCount: state.filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        return MonsterListItem(
                          monster: state.filtered[i],
                          onTap: () =>
                              context.push('/monsters/${state.filtered[i].id}'),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: () => _showFilterSheet(context),
          child: const Icon(Icons.filter_list),
        ),
      ),
    );
  }
}
