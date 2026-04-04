import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mh3rd/core/widgets/icon_widget.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/weapon_widgets.dart';
import '../../../core/constants/weapon_constants.dart';
import '../../../domain/entities/weapon.dart';
import '../bloc/weapon_bloc.dart';
import '../bloc/weapon_event_state.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter(BuildContext context) {
    context.read<WeaponBloc>().add(
      WeaponFilterChanged(
        type: widget.type,
        rarity: _activeRarity,
        element: _activeElement,
        nameQuery: _searchController.text.isEmpty
            ? null
            : _searchController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: 'Upgrade tree',
            onPressed: () => context.go('/weapons/${widget.type.short}/tree'),
          ),
          _SortMenu(),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onChanged: (_) => _applyFilter(context),
          ),
          _FilterChips(
            activeRarity: _activeRarity,
            activeElement: _activeElement,
            onRarityChanged: (r) {
              setState(() => _activeRarity = _activeRarity == r ? null : r);
              _applyFilter(context);
            },
            onElementChanged: (el) {
              setState(() => _activeElement = _activeElement == el ? null : el);
              _applyFilter(context);
            },
            onClear: () {
              setState(() {
                _activeRarity = null;
                _activeElement = null;
                _searchController.clear();
              });
              _applyFilter(context);
            },
          ),
          Expanded(
            child: BlocBuilder<WeaponBloc, WeaponState>(
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
                  return _WeaponList(
                    weapons: state.filtered,
                    type: widget.type,
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
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search weapons...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int? activeRarity;
  final WeaponElement? activeElement;
  final ValueChanged<int> onRarityChanged;
  final ValueChanged<WeaponElement> onElementChanged;
  final VoidCallback onClear;

  const _FilterChips({
    required this.activeRarity,
    required this.activeElement,
    required this.onRarityChanged,
    required this.onElementChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilter = activeRarity != null || activeElement != null;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          if (hasFilter)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                avatar: const Icon(Icons.clear, size: 14),
                label: const Text('Clear'),
                onPressed: onClear,
              ),
            ),
          for (int r = 1; r <= 7; r++)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text('R$r'),
                selected: activeRarity == r,
                selectedColor: rarityColor(r).withValues(alpha: 0.2),
                checkmarkColor: rarityColor(r),
                labelStyle: TextStyle(
                  color: activeRarity == r ? rarityColor(r) : null,
                  fontWeight: activeRarity == r
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
                onSelected: (_) => onRarityChanged(r),
              ),
            ),
          const VerticalDivider(width: 16),
          for (final el in WeaponElement.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(el.displayName),
                selected: activeElement == el,
                selectedColor: elementColor(el).withValues(alpha: 0.15),
                checkmarkColor: elementColor(el),
                labelStyle: TextStyle(
                  color: activeElement == el ? elementColor(el) : null,
                ),
                onSelected: (_) => onElementChanged(el),
              ),
            ),
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
        final current = state is WeaponListLoaded
            ? state.sortBy
            : WeaponSortBy.name;
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
                    const SizedBox(width: 8),
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

class _WeaponList extends StatelessWidget {
  final List<Weapon> weapons;
  final WeaponType type;
  const _WeaponList({required this.weapons, required this.type});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: weapons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _WeaponCard(
        weapon: weapons[i],
        weaponType: type,
        onTap: () => context.go('/weapons/${type.short}/${weapons[i].index}'),
      ),
    );
  }
}

class _WeaponCard extends StatelessWidget {
  final Weapon weapon;
  final WeaponType weaponType;
  final VoidCallback onTap;

  const _WeaponCard({
    required this.weapon,
    required this.weaponType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  MhAssetIcon.equipment(
                    "${weaponType.short}_rare${weapon.rarity}",
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weapon.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Attack: ${weapon.attack}'),
                          const SizedBox(width: 12),
                          Text(
                            'Affinity: ${weapon.affinity > 0 ? '+' : ''}${weapon.affinity}%',
                          ),
                        ],
                      ),
                    ],
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
