import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/weapon_widgets.dart';
import '../../../domain/entities/weapon_entities.dart';
import '../bloc/weapon_bloc.dart';
import '../bloc/weapon_event_state.dart';

class WeaponDetailPage extends StatelessWidget {
  final WeaponType type;
  final int index;
  const WeaponDetailPage({super.key, required this.type, required this.index});

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
      )..add(WeaponDetailRequested(type: type, index: index)),
      child: BlocBuilder<WeaponBloc, WeaponState>(
        builder: (context, state) {
          if (state is WeaponLoading) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (state is WeaponDetailLoaded) {
            return _WeaponDetailView(state: state);
          }
          if (state is WeaponError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(state.message)),
            );
          }
          return const Scaffold();
        },
      ),
    );
  }
}

class _WeaponDetailView extends StatelessWidget {
  final WeaponDetailLoaded state;
  const _WeaponDetailView({required this.state});

  @override
  Widget build(BuildContext context) {
    final w = state.weapon;
    return Scaffold(
      appBar: AppBar(
        title: Text(w.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree_outlined),
            tooltip: 'Full upgrade tree',
            onPressed: () => context.go('/weapons/${state.type.short}/tree'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatsCard(w: w),
          const SizedBox(height: 12),
          _SharpnessCard(w: w),
          if (w.create != null && w.create!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _MaterialsCard(
              title: 'Crafting materials',
              icon: Icons.construction,
              materials: w.create!,
            ),
          ],
          if (w.improve != null) ...[
            const SizedBox(height: 12),
            _MaterialsCard(
              title: 'Upgrade materials',
              icon: Icons.upgrade,
              materials: w.improve!.materials,
              fromIndex: w.improve!.from,
              fromType: state.type,
            ),
          ],
          if (w.scraps != null && w.scraps!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _MaterialsCard(
              title: 'Scraps when broken',
              icon: Icons.recycling,
              materials: w.scraps!,
            ),
          ],
          if (state.lineage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _LineageCard(
              lineage: state.lineage,
              type: state.type,
              currentIndex: w.index,
            ),
          ],
          if (state.children.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ChildrenCard(children: state.children, type: state.type),
          ],
        ],
      ),
    );
  }
}

// ── Sub-cards ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final Weapon w;
  const _StatsCard({required this.w});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RarityIndicator(rarity: w.rarity),
                const Spacer(),
                if (w.slots > 0) SlotIndicator(slots: w.slots),
              ],
            ),
            const SizedBox(height: 12),
            _StatRow(label: 'Attack', value: '${w.attack}', bold: true),
            _StatRow(
              label: 'Affinity',
              value: '${w.affinity > 0 ? '+' : ''}${w.affinity}%',
              valueColor: w.affinity > 0
                  ? Colors.green
                  : w.affinity < 0
                  ? Colors.red
                  : null,
            ),
            if (w.hasElement) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Element', style: TextStyle(fontSize: 13)),
                  const Spacer(),
                  ElementBadge(element: w.element, value: w.elemAttack),
                ],
              ),
            ],
            if (w.hasDefenseBonus)
              _StatRow(
                label: 'Defense bonus',
                value: '+${w.defense}',
                valueColor: Colors.blue,
              ),
            _StatRow(label: 'Price', value: '${w.price}z'),
            if (w.shellingType != null)
              _StatRow(
                label: 'Shelling',
                value:
                    '${w.shellingType!.name.toUpperCase()} Lv${w.shellingLevel ?? 1}',
              ),
            if (w.phial != null)
              _StatRow(label: 'Phial', value: w.phial!.name.toUpperCase()),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: bold ? 16 : 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SharpnessCard extends StatelessWidget {
  final Weapon w;
  const _SharpnessCard({required this.w});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sharpness', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            SharpnessBar(
              sharpness: w.sharpness,
              sharpnessp: w.sharpnessp,
              height: 14,
            ),
            if (w.sharpnessp != null) ...[
              const SizedBox(height: 6),
              Text(
                'Bottom bar = with Sharpness+1',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MaterialsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<MaterialRequirement> materials;
  final int? fromIndex;
  final WeaponType? fromType;

  const _MaterialsCard({
    required this.title,
    required this.icon,
    required this.materials,
    this.fromIndex,
    this.fromType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                if (fromIndex != null && fromType != null) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        context.go('/weapons/${fromType!.short}/$fromIndex'),
                    icon: const Icon(Icons.arrow_upward, size: 14),
                    label: const Text('From #'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            for (final m in materials)
              MaterialRow(materialId: m.id, count: m.count),
          ],
        ),
      ),
    );
  }
}

class _LineageCard extends StatelessWidget {
  final List<Weapon> lineage;
  final WeaponType type;
  final int currentIndex;

  const _LineageCard({
    required this.lineage,
    required this.type,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Upgrade path',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < lineage.length; i++) ...[
              _LineageItem(
                weapon: lineage[i],
                type: type,
                depth: i,
                isLast: i == lineage.length - 1,
              ),
              if (i < lineage.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: 16.0 + i * 16),
                  child: const Icon(Icons.keyboard_arrow_down, size: 16),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineageItem extends StatelessWidget {
  final Weapon weapon;
  final WeaponType type;
  final int depth;
  final bool isLast;

  const _LineageItem({
    required this.weapon,
    required this.type,
    required this.depth,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: InkWell(
        onTap: () => context.go('/weapons/${type.short}/${weapon.index}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              RarityIndicator(rarity: weapon.rarity, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weapon.name,
                  style: TextStyle(
                    fontWeight: isLast ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                '${weapon.attack}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildrenCard extends StatelessWidget {
  final List<Weapon> children;
  final WeaponType type;

  const _ChildrenCard({required this.children, required this.type});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Can upgrade to',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final child in children)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: RarityIndicator(rarity: child.rarity, size: 12),
                title: Text(child.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (child.element != null)
                      ElementBadge(element: child.element, fontSize: 11),
                    const SizedBox(width: 8),
                    Text(
                      '${child.attack}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () =>
                    context.go('/weapons/${type.short}/${child.index}'),
              ),
          ],
        ),
      ),
    );
  }
}
