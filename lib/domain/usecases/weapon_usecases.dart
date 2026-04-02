import '../entities/weapon_entities.dart';
import '../repositories/weapon_repository.dart';

// ─────────────────────────────────────────────
// GetAllWeaponCategories
// ─────────────────────────────────────────────
class GetAllWeaponCategories {
  final WeaponRepository _repo;
  const GetAllWeaponCategories(this._repo);

  Future<List<WeaponCategory>> call() => _repo.getAllCategories();
}

// ─────────────────────────────────────────────
// GetWeaponsByCategory
// ─────────────────────────────────────────────
class GetWeaponsByCategory {
  final WeaponRepository _repo;
  const GetWeaponsByCategory(this._repo);

  Future<List<Weapon>> call(WeaponType type) =>
      _repo.getWeaponsByCategory(type);
}

// ─────────────────────────────────────────────
// GetWeaponDetail
// ─────────────────────────────────────────────
class GetWeaponDetail {
  final WeaponRepository _repo;
  const GetWeaponDetail(this._repo);

  Future<Weapon?> call({required WeaponType type, required int index}) =>
      _repo.getWeaponByIndex(type: type, index: index);
}

// ─────────────────────────────────────────────
// SearchWeapons
// ─────────────────────────────────────────────
class SearchWeapons {
  final WeaponRepository _repo;
  const SearchWeapons(this._repo);

  Future<List<Weapon>> call(String query) => _repo.searchByName(query);
}

// ─────────────────────────────────────────────
// FilterWeapons
// ─────────────────────────────────────────────
class FilterWeaponsParams {
  final WeaponType type;
  final int? rarity;
  final WeaponElement? element;
  final String? nameQuery;

  const FilterWeaponsParams({
    required this.type,
    this.rarity,
    this.element,
    this.nameQuery,
  });
}

class FilterWeapons {
  final WeaponRepository _repo;
  const FilterWeapons(this._repo);

  Future<List<Weapon>> call(FilterWeaponsParams params) async {
    List<Weapon> weapons;

    if (params.rarity != null) {
      weapons = await _repo.filterByRarity(
        type: params.type,
        rarity: params.rarity!,
      );
    } else if (params.element != null) {
      weapons = await _repo.filterByElement(
        type: params.type,
        element: params.element!,
      );
    } else {
      weapons = await _repo.getWeaponsByCategory(params.type);
    }

    if (params.nameQuery != null && params.nameQuery!.isNotEmpty) {
      final q = params.nameQuery!.toLowerCase();
      weapons = weapons.where((w) => w.name.toLowerCase().contains(q)).toList();
    }

    return weapons;
  }
}

// ─────────────────────────────────────────────
// GetWeaponCraftingTree
// ─────────────────────────────────────────────
class WeaponTreeNode {
  final Weapon weapon;
  final List<WeaponTreeNode> children;
  final int depth;

  const WeaponTreeNode({
    required this.weapon,
    required this.children,
    required this.depth,
  });

  bool get isLeaf => children.isEmpty;
}

class GetWeaponCraftingTree {
  final WeaponRepository _repo;
  const GetWeaponCraftingTree(this._repo);

  Future<List<WeaponTreeNode>> call(WeaponType type) async {
    final category = await _repo.getCategoryByType(type);
    if (category == null) return [];

    final roots = category.rootWeapons;
    return roots.map((r) => _buildNode(r, category.weapons, 0)).toList();
  }

  WeaponTreeNode _buildNode(Weapon weapon, List<Weapon> all, int depth) {
    final childWeapons =
        weapon.upgrades
            ?.map((idx) {
              try {
                return all.firstWhere((w) => w.index == idx);
              } catch (_) {
                return null;
              }
            })
            .whereType<Weapon>()
            .toList() ??
        [];

    return WeaponTreeNode(
      weapon: weapon,
      depth: depth,
      children: childWeapons.map((c) => _buildNode(c, all, depth + 1)).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// GetWeaponLineage
// ─────────────────────────────────────────────
class GetWeaponLineage {
  final WeaponRepository _repo;
  const GetWeaponLineage(this._repo);

  Future<List<Weapon>> call({required WeaponType type, required int index}) =>
      _repo.getLineage(type: type, index: index);
}

// ─────────────────────────────────────────────
// GetWeaponMaterialIds
// ─────────────────────────────────────────────
class GetWeaponMaterialIds {
  final WeaponRepository _repo;
  const GetWeaponMaterialIds(this._repo);

  Future<Set<int>> call({required WeaponType type, required int index}) =>
      _repo.getMaterialIds(type: type, index: index);
}
