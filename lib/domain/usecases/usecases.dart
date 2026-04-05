import '../entities/weapon.dart';
import '../entities/item.dart';
import '../entities/monster.dart';
import '../entities/armor.dart';
import '../entities/others.dart';
import '../repositories/repositories.dart';

// ── Weapon usecases ──────────────────────────────────────────────────────────

class GetAllWeaponCategories {
  final WeaponRepository r;
  const GetAllWeaponCategories(this.r);
  Future<List<WeaponCategory>> call() => r.getAllCategories();
}

class GetWeaponsByCategory {
  final WeaponRepository r;
  const GetWeaponsByCategory(this.r);
  Future<List<Weapon>> call(WeaponType type) => r.getByCategory(type);
}

class GetWeaponDetail {
  final WeaponRepository r;
  const GetWeaponDetail(this.r);
  Future<Weapon?> call({required WeaponType type, required int index}) =>
      r.getByIndex(type: type, index: index);
}

class SearchWeapons {
  final WeaponRepository r;
  const SearchWeapons(this.r);
  Future<List<Weapon>> call(String q) => r.searchByName(q);
}

class FilterWeapons {
  final WeaponRepository r;
  const FilterWeapons(this.r);
  Future<List<Weapon>> call({
    required WeaponType type,
    int? rarity,
    WeaponElement? element,
    String? query,
  }) async {
    List<Weapon> list = await r.getByCategory(type);

    if (rarity != null) {
      list = list.where((w) => w.rarity == rarity).toList();
    }
    
    if (element != null) {
      list = list.where((w) => w.element == element).toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((w) => w.name.toLowerCase().contains(q)).toList();
    }
    
    return list;
  }
}

class GetWeaponCraftingTree {
  final WeaponRepository r;
  const GetWeaponCraftingTree(this.r);
  Future<List<WeaponTreeNode>> call(WeaponType type) async {
    final cat = await r.getCategoryByType(type);
    if (cat == null) return [];
    return cat.roots.map((root) => _build(root, cat.weapons, 0)).toList();
  }

  WeaponTreeNode _build(Weapon w, List<Weapon> all, int depth) {
    final children =
        w.upgrades
            ?.map((idx) {
              try {
                return all.firstWhere((x) => x.index == idx);
              } catch (_) {
                return null;
              }
            })
            .whereType<Weapon>()
            .toList() ??
        [];
    return WeaponTreeNode(
      weapon: w,
      depth: depth,
      children: children.map((c) => _build(c, all, depth + 1)).toList(),
    );
  }
}

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

class GetWeaponLineage {
  final WeaponRepository r;
  const GetWeaponLineage(this.r);
  Future<List<Weapon>> call({required WeaponType type, required int index}) =>
      r.getLineage(type: type, index: index);
}

/// Join weapon materials với item names
class JoinWeaponMaterials {
  final WeaponRepository weaponRepo;
  final ItemRepository itemRepo;
  const JoinWeaponMaterials(this.weaponRepo, this.itemRepo);
  Future<Map<int, Item?>> call({
    required WeaponType type,
    required int index,
  }) async {
    final weapon = await weaponRepo.getByIndex(type: type, index: index);
    if (weapon == null) return {};
    final ids = weapon.materialIds;
    final itemMap = await itemRepo.getMapByIds(ids);
    return {for (final id in ids) id: itemMap[id]};
  }
}

// ── Item usecases ─────────────────────────────────────────────────────────────

class GetAllItems {
  final ItemRepository r;
  const GetAllItems(this.r);
  Future<List<Item>> call() => r.getAll();
}

class GetItemById {
  final ItemRepository r;
  const GetItemById(this.r);
  Future<Item?> call(int id) => r.getById(id);
}

class SearchItems {
  final ItemRepository r;
  const SearchItems(this.r);
  Future<List<Item>> call(String q) => r.searchByName(q);
}

// ── Monster usecases ──────────────────────────────────────────────────────────

class GetAllMonsters {
  final MonsterRepository r;
  const GetAllMonsters(this.r);
  Future<List<Monster>> call() => r.getAll();
}

class GetMonsterById {
  final MonsterRepository r;
  const GetMonsterById(this.r);
  Future<Monster?> call(int id) => r.getById(id);
}

class SearchMonsters {
  final MonsterRepository r;
  const SearchMonsters(this.r);
  Future<List<Monster>> call(String q) => r.searchByName(q);
}

class GetMonstersByItem {
  final MonsterRepository r;
  const GetMonstersByItem(this.r);
  Future<List<Monster>> call(int itemId) => r.getMonstersByItemId(itemId);
}

class MonsterDetail {
  final Monster monster;
  final Map<int, Item> items;
  const MonsterDetail({required this.monster, required this.items});
}

/// Lấy dữ liệu monster kèm theo map các item liên quan
class GetMonsterDetail {
  final MonsterRepository monsterRepo;
  final ItemRepository itemRepo;
  const GetMonsterDetail(this.monsterRepo, this.itemRepo);
  Future<MonsterDetail?> call(int monsterId) async {
    final monster = await monsterRepo.getById(monsterId);
    if (monster == null) return null;
    final allIds = monster.allItemIds;
    final itemMap = await itemRepo.getMapByIds(allIds);
    return MonsterDetail(monster: monster, items: itemMap);
  }
}

// ── Armor usecases ────────────────────────────────────────────────────────────

class GetAllArmorCategories {
  final ArmorRepository r;
  const GetAllArmorCategories(this.r);
  Future<List<ArmorCategory>> call() => r.getAllCategories();
}

class GetArmorBySlot {
  final ArmorRepository r;
  const GetArmorBySlot(this.r);
  Future<ArmorCategory?> call(ArmorSlot slot) => r.getBySlot(slot);
}

class SearchArmors {
  final ArmorRepository r;
  const SearchArmors(this.r);
  Future<List<ArmorPiece>> call(String q) => r.searchByName(q);
}

class FilterArmorsBySkill {
  final ArmorRepository armorRepo;
  final SkillRepository skillRepo;
  const FilterArmorsBySkill(this.armorRepo, this.skillRepo);
  Future<({List<ArmorPiece> pieces, Skill? skill})> call(int skillId) async {
    final pieces = await armorRepo.filterBySkill(skillId);
    final skill = await skillRepo.getById(skillId);
    return (pieces: pieces, skill: skill);
  }
}

// ── Skill usecases ────────────────────────────────────────────────────────────

class GetAllSkills {
  final SkillRepository r;
  const GetAllSkills(this.r);
  Future<List<Skill>> call() => r.getAll();
}

class SearchSkills {
  final SkillRepository r;
  const SearchSkills(this.r);
  Future<List<Skill>> call(String q) => r.searchByName(q);
}

// ── Charm usecases ────────────────────────────────────────────────────────────

class GetFilteredCharms {
  final CharmRepository r;
  const GetFilteredCharms(this.r);
  Future<List<Charm>> call() => r.getFiltered();
}

class GetCharmsBySkill {
  final CharmRepository r;
  const GetCharmsBySkill(this.r);
  Future<List<Charm>> call(int skillId) => r.getBySkillId(skillId);
}

class GetAllCharmTypes {
  final CharmRepository r;
  const GetAllCharmTypes(this.r);
  Future<List<String>> call() => r.getAllTypes();
}

// ── Gun usecases ──────────────────────────────────────────────────────────────

class GetAllGunCategories {
  final GunRepository r;
  const GetAllGunCategories(this.r);
  Future<List<GunCategory>> call() => r.getAllCategories();
}

class GetGunsByCategory {
  final GunRepository r;
  const GetGunsByCategory(this.r);
  Future<List<Gun>> call(GunType type) => r.getByCategory(type);
}

class GetGunDetail {
  final GunRepository r;
  const GetGunDetail(this.r);
  Future<Gun?> call({required GunType type, required int index}) =>
      r.getByIndex(type: type, index: index);
}

class SearchGuns {
  final GunRepository r;
  const SearchGuns(this.r);
  Future<List<Gun>> call(String q) => r.searchByName(q);
}

class GetAllShots {
  final GunRepository r;
  const GetAllShots(this.r);
  Future<List<Shot>> call() => r.getAllShots();
}

// ── Quest usecases ────────────────────────────────────────────────────────────

class GetAllQuests {
  final QuestRepository r;
  const GetAllQuests(this.r);
  Future<List<Quest>> call() => r.getAll();
}

class SearchQuests {
  final QuestRepository r;
  const SearchQuests(this.r);
  Future<List<Quest>> call(String q) => r.searchByName(q);
}

class FilterQuests {
  final QuestRepository r;
  const FilterQuests(this.r);
  Future<List<Quest>> call({QuestHub? hub, int? star, int? monsterId}) async {
    List<Quest> quests;

    if (hub != null) {
      quests = await r.filterByHub(hub);
    } else if (star != null) {
      quests = await r.filterByStar(star);
    } else if (monsterId != null) {
      quests = await r.filterByMonster(monsterId);
    } else {
      quests = await r.getAll();
    }

    if (hub != null && star != null) {
      quests = quests.where((q) => q.star == star).toList();
    }
    if (monsterId != null) {
      quests = quests.where((q) => q.objectives.any((o) => o.targetId == monsterId)).toList();
    }

    return quests;
  }
}

class QuestDetailData {
  final Quest quest;
  final Map<int, Monster> monsters;
  final Map<int, Item> items;
  const QuestDetailData({
    required this.quest,
    required this.monsters,
    required this.items,
  });
}

class GetQuestDetail {
  final QuestRepository questRepo;
  final MonsterRepository monsterRepo;
  final ItemRepository itemRepo;
  const GetQuestDetail(this.questRepo, this.monsterRepo, this.itemRepo);

  Future<QuestDetailData?> call(int id) async {
    final quest = await questRepo.getById(id);
    if (quest == null) return null;

    final monsterIds =
        quest.objectives
            .where((o) => o.targetType == 'monster')
            .map((o) => o.targetId)
            .toSet();
    final itemIds =
        quest.objectives
            .where((o) => o.targetType == 'item')
            .map((o) => o.targetId)
            .toSet();

    final monsters = <int, Monster>{};
    for (final mid in monsterIds) {
      final m = await monsterRepo.getById(mid);
      if (m != null) monsters[mid] = m;
    }

    final items = await itemRepo.getMapByIds(itemIds);

    return QuestDetailData(quest: quest, monsters: monsters, items: items);
  }
}

// ── Cross-entity: Global search ───────────────────────────────────────────────

class GlobalSearchResult {
  final List<Weapon> weapons;
  final List<Item> items;
  final List<Monster> monsters;
  final List<ArmorPiece> armors;
  final List<Quest> quests;
  const GlobalSearchResult({
    required this.weapons,
    required this.items,
    required this.monsters,
    required this.armors,
    required this.quests,
  });
  bool get isEmpty =>
      weapons.isEmpty &&
      items.isEmpty &&
      monsters.isEmpty &&
      armors.isEmpty &&
      quests.isEmpty;
}

class GlobalSearch {
  final WeaponRepository weaponRepo;
  final ItemRepository itemRepo;
  final MonsterRepository monsterRepo;
  final ArmorRepository armorRepo;
  final QuestRepository questRepo;
  const GlobalSearch(
    this.weaponRepo,
    this.itemRepo,
    this.monsterRepo,
    this.armorRepo,
    this.questRepo,
  );

  Future<GlobalSearchResult> call(String query) async {
    if (query.trim().isEmpty) {
      return const GlobalSearchResult(
        weapons: [],
        items: [],
        monsters: [],
        armors: [],
        quests: [],
      );
    }
    final results = await Future.wait([
      weaponRepo.searchByName(query),
      itemRepo.searchByName(query),
      monsterRepo.searchByName(query),
      armorRepo.searchByName(query),
      questRepo.searchByName(query),
    ]);
    return GlobalSearchResult(
      weapons: results[0] as List<Weapon>,
      items: results[1] as List<Item>,
      monsters: results[2] as List<Monster>,
      armors: results[3] as List<ArmorPiece>,
      quests: results[4] as List<Quest>,
    );
  }
}
