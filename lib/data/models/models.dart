import '../../domain/entities/shared.dart';
import '../../domain/entities/weapon.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/monster.dart';
import '../../domain/entities/armor.dart';
import '../../domain/entities/others.dart';

// ── Shared ────────────────────────────────────────────────────────────────────

MaterialRequirement _mat(Map<String, dynamic> j) =>
    MaterialRequirement(id: j['id'] as int, count: j['count'] as int);

List<MaterialRequirement> _matList(dynamic raw) {
  if (raw == null) return [];
  return (raw as List).map((e) => _mat(e as Map<String, dynamic>)).toList();
}

List<int> _intList(dynamic raw) {
  if (raw == null) return [];
  return (raw as List).map((e) => e as int).toList();
}

DropEntry _drop(Map<String, dynamic> j) => DropEntry(
  itemId: j['id'] as int,
  count: j['count'] as int,
  chance: j['chance'] as int,
);

List<DropEntry> _dropList(dynamic raw) {
  if (raw == null) return [];
  return (raw as List).map((e) => _drop(e as Map<String, dynamic>)).toList();
}

SkillPoints _sp(Map<String, dynamic> j) =>
    SkillPoints(skillId: j['id'] as int, points: j['points'] as int);

// ── Weapon models ─────────────────────────────────────────────────────────────

ImproveInfo? _improveInfo(dynamic raw) {
  if (raw == null) return null;
  final j = raw as Map<String, dynamic>;
  return ImproveInfo(
    from: j['from'] as int,
    materials: _matList(j['materials']),
  );
}

UpgradeInfo? _upgradeInfo(dynamic raw) {
  if (raw == null) return null;
  final j = raw as Map<String, dynamic>;
  return UpgradeInfo(
    price: j['price'] as int,
    materials: _matList(j['materials']),
  );
}

class WeaponModel extends Weapon {
  const WeaponModel({
    required super.index,
    required super.name,
    required super.description,
    required super.rarity,
    required super.attack,
    required super.affinity,
    required super.slots,
    required super.price,
    required super.sharpness,
    super.defense,
    super.element,
    super.elemAttack,
    super.sharpnessp,
    super.create,
    super.scraps,
    super.improve,
    super.upgrade,
    super.upgrades,
    super.path,
    super.shellingType,
    super.shellingLevel,
    super.phial,
  });

  factory WeaponModel.fromJson(Map<String, dynamic> j, {required int index}) =>
      WeaponModel(
        index: index,
        name: j['name'] as String,
        description: j['description'] as String? ?? '',
        rarity: j['rarity'] as int,
        attack: j['attack'] as int,
        affinity: j['affinity'] as int? ?? 0,
        slots: j['slots'] as int? ?? 0,
        price: j['price'] as int? ?? 0,
        defense: j['defense'] as int?,
        element: WeaponElement.fromString(j['element'] as String?),
        elemAttack: j['elemAttack'] != null
            ? int.tryParse(j['elemAttack'].toString())
            : null,
        sharpness: _intList(j['sharpness']),
        sharpnessp: j['sharpnessp'] != null ? _intList(j['sharpnessp']) : null,
        create: j['create'] != null ? _matList(j['create']) : null,
        scraps: j['scraps'] != null ? _matList(j['scraps']) : null,
        improve: _improveInfo(j['improve']),
        upgrade: _upgradeInfo(j['upgrade']),
        upgrades: j['upgrades'] != null ? _intList(j['upgrades']) : null,
        path: j['path'] != null ? _intList(j['path']) : null,
        shellingType: ShellingType.fromString(j['shellingType'] as String?),
        shellingLevel: j['shellingLevel'] as int?,
        phial: PhialType.fromString(j['phial'] as String?),
      );
}

class WeaponCategoryModel extends WeaponCategory {
  const WeaponCategoryModel({
    required super.type,
    required super.displayName,
    required super.weapons,
  });

  factory WeaponCategoryModel.fromJson(Map<String, dynamic> j) {
    final short = j['short'] as String;
    final type =
        WeaponType.fromShort(short) ?? (throw ArgumentError('Unknown: $short'));
    final weapons = (j['weapons'] as List)
        .asMap()
        .entries
        .map(
          (e) => WeaponModel.fromJson(
            e.value as Map<String, dynamic>,
            index: e.key + 1,
          ),
        )
        .toList();
    return WeaponCategoryModel(
      type: type,
      displayName: j['name'] as String,
      weapons: weapons,
    );
  }
}

// ── Item model ────────────────────────────────────────────────────────────────

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.name,
    required super.rarity,
    super.color,
    super.icon,
    super.value,
    super.obtain,
    super.uses,
  });

  factory ItemModel.fromJson(Map<String, dynamic> j) {
    ItemObtain? obtain;
    if (j['obtain'] != null) {
      final o = j['obtain'] as Map<String, dynamic>;
      final buy = o['buy'] as Map<String, dynamic>?;
      obtain = ItemObtain(buyPrice: buy?['price'] as int?);
    }
    ItemUses? uses;
    if (j['uses'] != null) {
      final u = j['uses'] as Map<String, dynamic>;
      final decs = u['decorations'];
      uses = ItemUses(
        decorationIds: decs != null && decs is List
            ? (decs as List)
                  .map((e) => (e as Map<String, dynamic>)['id'] as int)
                  .toList()
            : null,
      );
    }
    return ItemModel(
      id: j['_id'] as int,
      name: j['name'] as String,
      rarity: j['rarity'] as int? ?? 1,
      color: j['color'] as String?,
      icon: j['icon'] as String?,
      value: j['value'] as int?,
      obtain: obtain,
      uses: uses,
    );
  }
}

// ── Monster model ─────────────────────────────────────────────────────────────

class MonsterModel extends Monster {
  const MonsterModel({
    required super.id,
    required super.name,
    required super.carves,
    required super.shinies,
  });

  factory MonsterModel.fromJson(Map<String, dynamic> j) {
    List<CarveGroup> carves = [];
    if (j['carves'] != null) {
      carves = (j['carves'] as List).map((c) {
        final cm = c as Map<String, dynamic>;
        final name = (cm['name'] as Map<String, dynamic>)['hgg'] != null
            ? (cm['name'] as Map<String, dynamic>)['hgg'] as String? ?? 'Body'
            : 'Body';
        return CarveGroup(
          partName: name,
          low: _dropList(cm['low']),
          high: _dropList(cm['high']),
          baby: _dropList(cm['baby']),
        );
      }).toList();
    }
    List<ShinyGroup> shinies = [];
    if (j['shinies'] != null) {
      shinies = (j['shinies'] as List).map((s) {
        final sm = s as Map<String, dynamic>;
        final action = (sm['action'] as Map<String, dynamic>)['hgg'] != null
            ? (sm['action'] as Map<String, dynamic>)['hgg'] as String? ?? '?'
            : '?';
        return ShinyGroup(
          action: action,
          low: _dropList(sm['low']),
          high: _dropList(sm['high']),
          baby: _dropList(sm['baby']),
        );
      }).toList();
    }
    return MonsterModel(
      id: j['_id'] as int,
      name: j['name'] as String,
      carves: carves,
      shinies: shinies,
    );
  }
}

// ── Armor model ───────────────────────────────────────────────────────────────

class ArmorPieceModel extends ArmorPiece {
  const ArmorPieceModel({
    required super.name,
    required super.rarity,
    required super.price,
    required super.description,
    required super.slots,
    required super.defense,
    required super.isBladeArmor,
    required super.isGunnerArmor,
    required super.fireRes,
    required super.waterRes,
    required super.thunderRes,
    required super.iceRes,
    required super.dragonRes,
    required super.create,
    required super.scraps,
    required super.skills,
  });

  factory ArmorPieceModel.fromJson(Map<String, dynamic> j) => ArmorPieceModel(
    name: j['name'] as String,
    rarity: j['rarity'] as int,
    price: j['price'] as int? ?? 0,
    description: j['description'] as String? ?? '',
    slots: j['slots'] as int? ?? 0,
    defense: j['defense'] as int? ?? 0,
    isBladeArmor: j['blade'] as bool? ?? false,
    isGunnerArmor: j['gunner'] as bool? ?? false,
    fireRes: j['fireRes'] as int? ?? 0,
    waterRes: j['waterRes'] as int? ?? 0,
    thunderRes: j['thunderRes'] as int? ?? 0,
    iceRes: j['iceRes'] as int? ?? 0,
    dragonRes: j['dragonRes'] as int? ?? 0,
    create: _matList(j['create']),
    scraps: _matList(j['scraps']),
    skills: j['skills'] != null
        ? (j['skills'] as List)
              .map((s) => _sp(s as Map<String, dynamic>))
              .toList()
        : [],
  );
}

class ArmorCategoryModel extends ArmorCategory {
  const ArmorCategoryModel({
    required super.slot,
    required super.displayName,
    required super.pieces,
  });

  factory ArmorCategoryModel.fromJson(Map<String, dynamic> j) {
    final short = j['short'] as String;
    final slot =
        ArmorSlot.fromShort(short) ??
        (throw ArgumentError('Unknown armor slot: $short'));
    final nameRaw = j['name'];
    final displayName = nameRaw as String;
    return ArmorCategoryModel(
      slot: slot,
      displayName: displayName,
      pieces: (j['pieces'] as List)
          .map((p) => ArmorPieceModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Skill model ───────────────────────────────────────────────────────────────

class SkillModel extends Skill {
  const SkillModel({
    required super.id,
    required super.name,
    super.copy,
    required super.bounds,
  });

  factory SkillModel.fromJson(Map<String, dynamic> j, {required int index}) =>
      SkillModel(
        id: index,
        name: j['name'] as String,
        copy: j['copy'] as String?,
        bounds: j['bounds'] != null
            ? (j['bounds'] as List).map((b) {
                final bm = b as Map<String, dynamic>;
                return SkillBound(
                  name: bm['name'] as String,
                  points: int.tryParse(bm['points'].toString()) ?? 0,
                );
              }).toList()
            : [],
      );
}

// ── Charm model ───────────────────────────────────────────────────────────────

class CharmModel extends Charm {
  const CharmModel({
    required super.type,
    required super.table,
    required super.slots,
    required super.skills,
  });

  factory CharmModel.fromJson(Map<String, dynamic> j) => CharmModel(
    type: j['type'] as String,
    table: j['table'] as int,
    slots: j['slots'] as int? ?? 0,
    skills: (j['skills'] as List)
        .map((s) => _sp(s as Map<String, dynamic>))
        .toList(),
  );
}

// ── Gun model ─────────────────────────────────────────────────────────────────

ImproveInfoGun? _improveGun(dynamic raw) {
  if (raw == null) return null;
  final j = raw as Map<String, dynamic>;
  return ImproveInfoGun(
    from: j['from'] as int,
    materials: _matList(j['materials']),
  );
}

class GunModel extends Gun {
  const GunModel({
    required super.index,
    required super.name,
    required super.description,
    required super.rarity,
    required super.attack,
    required super.affinity,
    required super.slots,
    required super.price,
    super.drift,
    super.reload,
    super.recoil,
    super.shots,
    super.charges,
    super.coatings,
    super.rain,
    super.create,
    super.scraps,
    super.improve,
    super.upgrades,
    super.path,
  });

  factory GunModel.fromJson(Map<String, dynamic> j, {required int index}) {
    // Parse shots[shotType][level] = {clip, rapid?}
    List<List<ShotClip>>? shots;
    if (j['shots'] != null) {
      shots = (j['shots'] as List).map((shotType) {
        return (shotType as List).map((lv) {
          final lm = lv as Map<String, dynamic>;
          return ShotClip(
            clip: lm['clip'] as int? ?? 0,
            rapid: lm['rapid'] as int?,
          );
        }).toList();
      }).toList();
    }
    // Parse bow charges
    List<BowCharge>? charges;
    if (j['charges'] != null) {
      charges = (j['charges'] as List).map((c) {
        final cm = c as Map<String, dynamic>;
        return BowCharge(
          level: cm['level'] as int,
          type: cm['type'] as String,
          load: cm['load'] as String?,
        );
      }).toList();
    }
    // Parse bow coatings
    BowCoatings? coatings;
    if (j['coatings'] != null) {
      final c = j['coatings'] as Map<String, dynamic>;
      coatings = BowCoatings(
        power: c['power'] as bool? ?? false,
        poison: c['poison'] as bool? ?? false,
        paralyze: c['paralyze'] as bool? ?? false,
        sleep: c['sleep'] as bool? ?? false,
        fatigue: c['fatigue'] as bool? ?? false,
        razor: c['razor'] as bool? ?? false,
        paint: c['paint'] as bool? ?? false,
      );
    }
    final nameRaw = j['name'];
    final name = nameRaw as String;
    return GunModel(
      index: index,
      name: name,
      description: j['description'] as String? ?? '',
      rarity: j['rarity'] as int,
      attack: j['attack'] as int,
      affinity: j['affinity'] as int? ?? 0,
      slots: j['slots'] as int? ?? 0,
      price: j['price'] as int? ?? 0,
      drift: j['drift'] as String?,
      reload: j['reload'] as String?,
      recoil: j['recoil'] as String?,
      shots: shots,
      charges: charges,
      coatings: coatings,
      rain: j['rain'] as String?,
      create: j['create'] != null ? _matList(j['create']) : null,
      scraps: j['scraps'] != null ? _matList(j['scraps']) : null,
      improve: _improveGun(j['improve']),
      upgrades: j['upgrades'] != null ? _intList(j['upgrades']) : null,
      path: j['path'] != null ? _intList(j['path']) : null,
    );
  }
}

class GunCategoryModel extends GunCategory {
  const GunCategoryModel({
    required super.type,
    required super.displayName,
    required super.guns,
  });

  factory GunCategoryModel.fromJson(Map<String, dynamic> j) {
    final short = j['short'] as String;
    final type =
        GunType.fromShort(short) ??
        (throw ArgumentError('Unknown gun type: $short'));
    final nameRaw = j['name'];
    final displayName = nameRaw as String;
    final guns = (j['weapons'] as List)
        .asMap()
        .entries
        .map(
          (e) => GunModel.fromJson(
            e.value as Map<String, dynamic>,
            index: e.key + 1,
          ),
        )
        .toList();
    return GunCategoryModel(type: type, displayName: displayName, guns: guns);
  }
}

class ShotModel extends Shot {
  const ShotModel({required super.name, required super.levels});
  factory ShotModel.fromJson(Map<String, dynamic> j) =>
      ShotModel(name: j['name'] as String, levels: j['levels'] as int);
}

// ── Quest model ───────────────────────────────────────────────────────────────

class QuestModel extends Quest {
  const QuestModel({
    required super.id,
    required super.no,
    required super.name,
    required super.reward,
    required super.type,
    required super.hub,
    required super.star,
    required super.objectives,
    super.time,
    super.mapId,
    super.unlockCondition,
  });

  factory QuestModel.fromJson(Map<String, dynamic> j) => QuestModel(
    id: j['_id'] as int,
    no: j['no'] as String,
    name: j['name'] as String,
    time: j['time'] as String?,
    reward: j['reward'] as int? ?? 0,
    type: QuestType.fromCode(j['type'] as String? ?? 'N'),
    hub: QuestHub.fromCode(j['hub'] as String? ?? 'G'),
    star: j['star'] as int? ?? 1,
    mapId: j['map_id'] as int?,
    unlockCondition: j['unlock_condition'] as String?,
    objectives: j['objectives'] != null
        ? (j['objectives'] as List).map((o) {
            final om = o as Map<String, dynamic>;
            return QuestObjective(
              targetType: om['targetType'] as String,
              targetId: om['_id'] as int,
              quantity: om['quantity'] as int,
              action: om['action'] as String,
            );
          }).toList()
        : [],
  );
}
