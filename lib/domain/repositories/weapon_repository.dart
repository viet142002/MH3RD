import '../entities/weapon.dart';

abstract class WeaponRepository {
  Future<List<WeaponCategory>> getAllCategories();
  Future<WeaponCategory?> getCategoryByType(WeaponType type);
  Future<List<Weapon>> getWeaponsByCategory(WeaponType type);
  Future<Weapon?> getWeaponByIndex({
    required WeaponType type,
    required int index,
  });
  Future<List<Weapon>> searchByName(String query);
  Future<List<Weapon>> filterByRarity({
    required WeaponType type,
    required int rarity,
  });
  Future<List<Weapon>> filterByElement({
    required WeaponType type,
    required WeaponElement element,
  });
  Future<List<Weapon>> getRootWeapons(WeaponType type);
  Future<Weapon?> getParent({required WeaponType type, required int index});
  Future<List<Weapon>> getChildren({
    required WeaponType type,
    required int index,
  });
  Future<List<Weapon>> getLineage({
    required WeaponType type,
    required int index,
  });
  Future<Set<int>> getMaterialIds({
    required WeaponType type,
    required int index,
  });
}
