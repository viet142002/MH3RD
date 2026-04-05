import '../entities/weapon.dart';
import '../entities/item.dart';
import '../entities/monster.dart';
import '../entities/armor.dart';
import '../entities/others.dart';

abstract class WeaponRepository {
  Future<List<WeaponCategory>> getAllCategories();
  Future<WeaponCategory?> getCategoryByType(WeaponType type);
  Future<List<Weapon>> getByCategory(WeaponType type);
  Future<Weapon?> getByIndex({required WeaponType type, required int index});
  Future<List<Weapon>> searchByName(String query);
  Future<List<Weapon>> filterByRarity({
    required WeaponType type,
    required int rarity,
  });
  Future<List<Weapon>> filterByElement({
    required WeaponType type,
    required WeaponElement element,
  });
  Future<List<Weapon>> getRoots(WeaponType type);
  Future<Weapon?> getParent({required WeaponType type, required int index});
  Future<List<Weapon>> getChildren({
    required WeaponType type,
    required int index,
  });
  Future<List<Weapon>> getLineage({
    required WeaponType type,
    required int index,
  });
}

abstract class ItemRepository {
  Future<List<Item>> getAll();
  Future<Item?> getById(int id);
  Future<List<Item>> searchByName(String query);
  Future<Map<int, Item>> getMapByIds(Set<int> ids);
}

abstract class MonsterRepository {
  Future<List<Monster>> getAll();
  Future<Monster?> getById(int id);
  Future<List<Monster>> searchByName(String query);

  /// Quái vật nào drop item này
  Future<List<Monster>> getMonstersByItemId(int itemId);
}

abstract class ArmorRepository {
  Future<List<ArmorCategory>> getAllCategories();
  Future<ArmorCategory?> getBySlot(ArmorSlot slot);
  Future<List<ArmorPiece>> searchByName(String query);
  Future<List<ArmorPiece>> filterBySkill(int skillId);
  Future<List<ArmorPiece>> filterByRarity(int rarity);
}

abstract class SkillRepository {
  Future<List<Skill>> getAll();
  Future<Skill?> getById(int id);
  Future<List<Skill>> searchByName(String query);
}

abstract class CharmRepository {
  Future<List<Charm>> getAll();
  Future<List<Charm>> getFiltered(); // charmsFiltered.json
  Future<List<Charm>> getByType(String type);
  Future<List<Charm>> getBySkillId(int skillId);
  Future<List<String>> getAllTypes();
}

abstract class GunRepository {
  Future<List<GunCategory>> getAllCategories();
  Future<GunCategory?> getCategoryByType(GunType type);
  Future<List<Gun>> getByCategory(GunType type);
  Future<Gun?> getByIndex({required GunType type, required int index});
  Future<List<Gun>> searchByName(String query);
  Future<List<Shot>> getAllShots();
}

abstract class QuestRepository {
  Future<List<Quest>> getAll();
  Future<Quest?> getById(int id);
  Future<List<Quest>> searchByName(String query);
  Future<List<Quest>> filterByHub(QuestHub hub);
  Future<List<Quest>> filterByStar(int star);
  Future<List<Quest>> filterByMonster(int monsterId);
}
