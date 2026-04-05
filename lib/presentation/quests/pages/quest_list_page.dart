import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mh3rd/core/di/injection.dart';
import '../../../domain/entities/others.dart';
import '../bloc/quest_bloc.dart';
import '../bloc/quest_event_state.dart';
import '../widgets/quest_filter_sheet.dart';
import '../widgets/quest_list_item.dart';

class QuestListPage extends StatefulWidget {
  const QuestListPage({super.key});

  @override
  State<QuestListPage> createState() => _QuestListPageState();
}

class _QuestListPageState extends State<QuestListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late QuestBloc _questBloc;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _questBloc = QuestBloc(
      filter: getIt(),
      search: getIt(),
      getDetail: getIt(),
    )..add(const QuestListRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => QuestFilterSheet(
        searchController: _searchController,
        questBloc: _questBloc,
        activeHub: _tabController.index == 0 ? QuestHub.village : QuestHub.guild,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _questBloc,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Village'),
                  Tab(text: 'Guild'),
                ],
                onTap: (index) => setState(() {}),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _QuestTabContent(hub: QuestHub.village),
                    _QuestTabContent(hub: QuestHub.guild),
                  ],
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
      ),
    );
  }
}

class _QuestTabContent extends StatelessWidget {
  final QuestHub hub;
  const _QuestTabContent({required this.hub});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestBloc, QuestState>(
      builder: (context, state) {
        if (state is QuestLoading || state is QuestInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is QuestListLoaded) {
          final filtered = state.getFiltered(hub);
          return filtered.isEmpty
              ? const Center(child: Text('No quests found'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    return QuestListItem(
                      quest: filtered[i],
                      onTap: () =>
                          context.push('/quests/${filtered[i].id}'),
                    );
                  },
                );
        }
        if (state is QuestError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}


