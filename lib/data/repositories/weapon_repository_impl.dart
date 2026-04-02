import '../../domain/entities/weapon_entities.dart';
import '../../domain/repositories/weapon_repository.dart';
import '../datasources/weapon_local_datasource.dart';

class WeaponRepositoryImpl implements WeaponRepository {
  final WeaponLocalDatasource _datasource;

  WeaponRepositoryImpl(this._datasource);

  Future<WeaponCategory?> _find(WeaponType type) async {
    final cats = await _datasource.loadAll();
    try {
      return cats.firstWhere((c) => c.type == type);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WeaponCategory>> getAllCategories() => _datasource.loadAll();

  @override
  Future<WeaponCategory?> getCategoryByType(WeaponType type) => _find(type);

  @override
  Future<List<Weapon>> getWeaponsByCategory(WeaponType type) async =>
      (await _find(type))?.weapons ?? [];

  @override
  Future<Weapon?> getWeaponByIndex({
    required WeaponType type,
    required int index,
  }) async => (await _find(type))?.getByIndex(index);

  @override
  Future<List<Weapon>> searchByName(String query) async {
    if (query.trim().isEmpty) return [];
    final cats = await _datasource.loadAll();
    final lower = query.toLowerCase();
    return [
      for (final cat in cats)
        ...cat.weapons.where((w) => w.name.toLowerCase().contains(lower)),
    ];
  }

  @override
  Future<List<Weapon>> filterByRarity({
    required WeaponType type,
    required int rarity,
  }) async => (await _find(type))?.byRarity(rarity) ?? [];

  @override
  Future<List<Weapon>> filterByElement({
    required WeaponType type,
    required WeaponElement element,
  }) async => (await _find(type))?.byElement(element) ?? [];

  @override
  Future<List<Weapon>> getRootWeapons(WeaponType type) async =>
      (await _find(type))?.rootWeapons ?? [];

  @override
  Future<Weapon?> getParent({
    required WeaponType type,
    required int index,
  }) async {
    final cat = await _find(type);
    if (cat == null) return null;
    final weapon = cat.getByIndex(index);
    if (weapon?.improve == null) return null;
    return cat.getByIndex(weapon!.improve!.from);
  }

  @override
  Future<List<Weapon>> getChildren({
    required WeaponType type,
    required int index,
  }) async {
    final cat = await _find(type);
    if (cat == null) return [];
    final weapon = cat.getByIndex(index);
    if (weapon?.upgrades == null) return [];
    return weapon!.upgrades!
        .map((idx) => cat.getByIndex(idx))
        .whereType<Weapon>()
        .toList();
  }

  @override
  Future<List<Weapon>> getLineage({
    required WeaponType type,
    required int index,
  }) async {
    final cat = await _find(type);
    if (cat == null) return [];
    final weapon = cat.getByIndex(index);
    if (weapon?.path == null) return [];
    return weapon!.path!
        .map((idx) => cat.getByIndex(idx))
        .whereType<Weapon>()
        .toList();
  }

  @override
  Future<Set<int>> getMaterialIds({
    required WeaponType type,
    required int index,
  }) async {
    final weapon = await getWeaponByIndex(type: type, index: index);
    return weapon?.allMaterialIds ?? {};
  }
}
