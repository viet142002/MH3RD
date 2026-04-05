import '../../domain/entities/weapon.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/monster.dart';
import '../../domain/entities/armor.dart';
import '../../domain/entities/others.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/datasources.dart';

// ── Weapon ────────────────────────────────────────────────────────────────────

class WeaponRepositoryImpl implements WeaponRepository {
  final WeaponLocalDatasource _ds;
  WeaponRepositoryImpl(this._ds);

  Future<WeaponCategory?> _find(WeaponType t) async {
    final cats = await _ds.load();
    try {
      return cats.firstWhere((c) => c.type == t);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WeaponCategory>> getAllCategories() => _ds.load();
  @override
  Future<WeaponCategory?> getCategoryByType(WeaponType t) => _find(t);
  @override
  Future<List<Weapon>> getByCategory(WeaponType t) async =>
      (await _find(t))?.weapons ?? [];
  @override
  Future<Weapon?> getByIndex({
    required WeaponType type,
    required int index,
  }) async => (await _find(type))?.getByIndex(index);

  @override
  Future<List<Weapon>> searchByName(String q) async {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return (await _ds.load())
        .expand((c) => c.weapons)
        .where((w) => w.name.toLowerCase().contains(lower))
        .toList();
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
  Future<List<Weapon>> getRoots(WeaponType t) async =>
      (await _find(t))?.roots ?? [];

  @override
  Future<Weapon?> getParent({
    required WeaponType type,
    required int index,
  }) async {
    final cat = await _find(type);
    final w = cat?.getByIndex(index);
    if (w?.improve == null) return null;
    return cat!.getByIndex(w!.improve!.from);
  }

  @override
  Future<List<Weapon>> getChildren({
    required WeaponType type,
    required int index,
  }) async {
    final cat = await _find(type);
    final w = cat?.getByIndex(index);
    return w?.upgrades
            ?.map((i) => cat!.getByIndex(i))
            .whereType<Weapon>()
            .toList() ??
        [];
  }

  @override
  Future<List<Weapon>> getLineage({
    required WeaponType type,
    required int index,
  }) async {
    final cat = await _find(type);
    final w = cat?.getByIndex(index);
    return w?.path
            ?.map((i) => cat!.getByIndex(i))
            .whereType<Weapon>()
            .toList() ??
        [];
  }
}

// ── Item ──────────────────────────────────────────────────────────────────────

class ItemRepositoryImpl implements ItemRepository {
  final ItemLocalDatasource _ds;
  ItemRepositoryImpl(this._ds);

  @override
  Future<List<Item>> getAll() => _ds.load();

  @override
  Future<Item?> getById(int id) async {
    final list = await _ds.load();
    try {
      return list.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Item>> searchByName(String q) async {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return (await _ds.load())
        .where((i) => i.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Future<Map<int, Item>> getMapByIds(Set<int> ids) async {
    final all = await _ds.load();
    return {
      for (final item in all)
        if (ids.contains(item.id)) item.id: item,
    };
  }
}

// ── Monster ───────────────────────────────────────────────────────────────────

class MonsterRepositoryImpl implements MonsterRepository {
  final MonsterLocalDatasource _ds;
  MonsterRepositoryImpl(this._ds);

  @override
  Future<List<Monster>> getAll() => _ds.load();

  @override
  Future<Monster?> getById(int id) async {
    try {
      return (await _ds.load()).firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Monster>> searchByName(String q) async {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return (await _ds.load())
        .where((m) => m.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Future<List<Monster>> getMonstersByItemId(int itemId) async =>
      (await _ds.load()).where((m) => m.allItemIds.contains(itemId)).toList();
}

// ── Armor ─────────────────────────────────────────────────────────────────────

class ArmorRepositoryImpl implements ArmorRepository {
  final ArmorLocalDatasource _ds;
  ArmorRepositoryImpl(this._ds);

  @override
  Future<List<ArmorCategory>> getAllCategories() => _ds.load();

  @override
  Future<ArmorCategory?> getBySlot(ArmorSlot slot) async {
    try {
      return (await _ds.load()).firstWhere((c) => c.slot == slot);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ArmorPiece>> searchByName(String q) async {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return (await _ds.load())
        .expand((c) => c.pieces)
        .where((p) => p.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Future<List<ArmorPiece>> filterBySkill(int skillId) async =>
      (await _ds.load())
          .expand((c) => c.pieces)
          .where((p) => p.skillIds.contains(skillId))
          .toList();

  @override
  Future<List<ArmorPiece>> filterByRarity(int rarity) async =>
      (await _ds.load())
          .expand((c) => c.pieces)
          .where((p) => p.rarity == rarity)
          .toList();
}

// ── Skill ─────────────────────────────────────────────────────────────────────

class SkillRepositoryImpl implements SkillRepository {
  final SkillLocalDatasource _ds;
  SkillRepositoryImpl(this._ds);

  @override
  Future<List<Skill>> getAll() => _ds.load();

  @override
  Future<Skill?> getById(int id) async {
    try {
      return (await _ds.load()).firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Skill>> searchByName(String q) async {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return (await _ds.load())
        .where((s) => s.name.toLowerCase().contains(lower))
        .toList();
  }
}

// ── Charm ─────────────────────────────────────────────────────────────────────

class CharmRepositoryImpl implements CharmRepository {
  final CharmLocalDatasource _ds;
  CharmRepositoryImpl(this._ds);

  @override
  Future<List<Charm>> getAll() => _ds.loadAll();
  @override
  Future<List<Charm>> getFiltered() => _ds.loadFiltered();

  @override
  Future<List<Charm>> getByType(String type) async =>
      (await _ds.loadFiltered()).where((c) => c.type == type).toList();

  @override
  Future<List<Charm>> getBySkillId(int skillId) async =>
      (await _ds.loadFiltered())
          .where((c) => c.skills.any((s) => s.skillId == skillId))
          .toList();

  @override
  Future<List<String>> getAllTypes() async =>
      (await _ds.loadFiltered()).map((c) => c.type).toSet().toList()..sort();
}

// ── Gun ───────────────────────────────────────────────────────────────────────

class GunRepositoryImpl implements GunRepository {
  final GunLocalDatasource _gunDs;
  final ShotLocalDatasource _shotDs;
  GunRepositoryImpl(this._gunDs, this._shotDs);

  Future<GunCategory?> _find(GunType t) async {
    try {
      return (await _gunDs.load()).firstWhere((c) => c.type == t);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<GunCategory>> getAllCategories() => _gunDs.load();
  @override
  Future<GunCategory?> getCategoryByType(GunType t) => _find(t);
  @override
  Future<List<Gun>> getByCategory(GunType t) async =>
      (await _find(t))?.guns ?? [];
  @override
  Future<Gun?> getByIndex({required GunType type, required int index}) async =>
      (await _find(type))?.getByIndex(index);

  @override
  Future<List<Gun>> searchByName(String q) async {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return (await _gunDs.load())
        .expand((c) => c.guns)
        .where((g) => g.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Future<List<Shot>> getAllShots() => _shotDs.load();
}

// ── Quest ─────────────────────────────────────────────────────────────────────

class QuestRepositoryImpl implements QuestRepository {
  final QuestLocalDatasource _ds;
  QuestRepositoryImpl(this._ds);

  @override
  Future<List<Quest>> getAll() => _ds.load();

  @override
  Future<Quest?> getById(int id) async {
    try {
      return (await _ds.load()).firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Quest>> searchByName(String q) async {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return (await _ds.load())
        .where((q) => q.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Future<List<Quest>> filterByHub(QuestHub hub) async =>
      (await _ds.load()).where((q) => q.hub == hub).toList();

  @override
  Future<List<Quest>> filterByStar(int star) async =>
      (await _ds.load()).where((q) => q.star == star).toList();

  @override
  Future<List<Quest>> filterByMonster(int monsterId) async => (await _ds.load())
      .where(
        (q) => q.objectives.any(
          (o) => o.targetType == 'monster' && o.targetId == monsterId,
        ),
      )
      .toList();
}
