import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/weapon.dart';
import '../bloc/weapon_bloc.dart';
import '../bloc/weapon_event_state.dart';
import '../widgets/weapon_filter_sheet.dart';
import '../widgets/weapon_list_item.dart';

class WeaponListPage extends StatelessWidget {
  final WeaponType type;
  const WeaponListPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeaponBloc(
        getAllCategories: getIt(),
        getByCategory: getIt(),
        getDetail: getIt(),
        filterWeapons: getIt(),
        getTree: getIt(),
        getLineage: getIt(),
      )..add(WeaponListRequested(type)),
      child: _WeaponListView(type: type),
    );
  }
}

class _WeaponListView extends StatefulWidget {
  final WeaponType type;
  const _WeaponListView({required this.type});

  @override
  State<_WeaponListView> createState() => _WeaponListViewState();
}

class _WeaponListViewState extends State<_WeaponListView> {
  final _searchController = TextEditingController();
  int? _activeRarity;
  WeaponElement? _activeElement;
  bool _isSheetOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    final weaponBloc = context.read<WeaponBloc>();
    setState(() => _isSheetOpen = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => WeaponFilterSheet(
        searchController: _searchController,
        weaponBloc: weaponBloc,
        weaponType: widget.type,
        initialRarity: _activeRarity,
        initialElement: _activeElement,
        onFilterChanged: (r, e) {
          setState(() {
            _activeRarity = r;
            _activeElement = e;
          });
        },
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
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<WeaponBloc, WeaponState>(
                buildWhen: (previous, current) => !_isSheetOpen,
                builder: (context, state) {
                  if (state is WeaponLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is WeaponListLoaded) {
                    if (state.filtered.isEmpty) {
                      return const Center(
                        child: Text('No weapons match your filter'),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: state.filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) => WeaponListItem(
                        weapon: state.filtered[i],
                        weaponType: widget.type,
                        onTap: () => context.push(
                            '/weapons/${widget.type.short}/${state.filtered[i].index}'),
                      ),
                    );
                  }
                  if (state is WeaponError) {
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.type.displayName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: 'Upgrade tree',
            onPressed: () => context.go('/weapons/${widget.type.short}/tree'),
          ),
          _SortMenu(),
        ],
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeaponBloc, WeaponState>(
      builder: (context, state) {
        final current =
            state is WeaponListLoaded ? state.sortBy : WeaponSortBy.name;
        return PopupMenuButton<WeaponSortBy>(
          icon: const Icon(Icons.sort),
          tooltip: 'Sort by',
          initialValue: current,
          onSelected: (v) =>
              context.read<WeaponBloc>().add(WeaponSortChanged(v)),
          itemBuilder: (_) => [
            for (final s in WeaponSortBy.values)
              PopupMenuItem(
                value: s,
                child: Row(
                  children: [
                    if (s == current)
                      const Icon(Icons.check, size: 16)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 10),
                    Text(_sortLabel(s)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _sortLabel(WeaponSortBy s) => switch (s) {
        WeaponSortBy.name => 'Name',
        WeaponSortBy.attack => 'Attack (high → low)',
        WeaponSortBy.rarity => 'Rarity (high → low)',
        WeaponSortBy.price => 'Price (high → low)',
      };
}

