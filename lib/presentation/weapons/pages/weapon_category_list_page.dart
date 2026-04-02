import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/weapon_constants.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/weapon_entities.dart';
import '../bloc/weapon_bloc.dart';
import '../bloc/weapon_event_state.dart';

class WeaponCategoryListPage extends StatelessWidget {
  const WeaponCategoryListPage({super.key});

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
      )..add(const WeaponCategoriesRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('MH3rd Database'), centerTitle: false),
        body: BlocBuilder<WeaponBloc, WeaponState>(
          builder: (context, state) {
            if (state is WeaponLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WeaponCategoriesLoaded) {
              return _CategoryGrid(categories: state.categories);
            }
            if (state is WeaponError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<WeaponCategory> categories;
  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        return _CategoryCard(category: cat);
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final WeaponCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors =
        _categoryColors[category.type] ??
        (
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.primaryContainer,
        );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/weapons/${category.type.short}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: colors.$1, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.displayName,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.$2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category.weapons.length} weapons',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.$1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

const _categoryColors = <WeaponType, (Color, Color)>{
  WeaponType.greatSword: (Color(0xFFE53935), Color(0xFFFFEBEE)),
  WeaponType.longSword: (Color(0xFF8E24AA), Color(0xFFF3E5F5)),
  WeaponType.swordAndShield: (Color(0xFF1E88E5), Color(0xFFE3F2FD)),
  WeaponType.dualSwords: (Color(0xFF00ACC1), Color(0xFFE0F7FA)),
  WeaponType.hammer: (Color(0xFFFF6F00), Color(0xFFFFF8E1)),
  WeaponType.huntingHorn: (Color(0xFF43A047), Color(0xFFE8F5E9)),
  WeaponType.lance: (Color(0xFF6D4C41), Color(0xFFEFEBE9)),
  WeaponType.gunlance: (Color(0xFF546E7A), Color(0xFFECEFF1)),
  WeaponType.switchAxe: (Color(0xFFFFD600), Color(0xFFFFFDE7)),
};
