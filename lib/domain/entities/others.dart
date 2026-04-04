import 'package:equatable/equatable.dart';
import 'shared.dart';

// ─── Skill ───────────────────────────────────────────────────────────────────

class SkillBound extends Equatable {
  final String name; // e.g. "Poison Negated"
  final int points; // e.g. 10 or -10
  const SkillBound({required this.name, required this.points});
  @override
  List<Object?> get props => [name, points];
}

class Skill extends Equatable {
  final int id; // index trong list (0-based → display 1-based)
  final String name;
  final String? copy; // armor slot short nó thuộc về (plt, hlm, ...)
  final List<SkillBound> bounds;

  const Skill({
    required this.id,
    required this.name,
    this.copy,
    required this.bounds,
  });
  @override
  List<Object?> get props => [id];
  @override
  String toString() => 'Skill(#$id $name)';
}

// ─── Charm ───────────────────────────────────────────────────────────────────

class Charm extends Equatable {
  final String type; // queen, king, dragon, v.v.
  final int table;
  final int slots;
  final List<SkillPoints> skills;

  const Charm({
    required this.type,
    required this.table,
    required this.slots,
    required this.skills,
  });
  @override
  List<Object?> get props => [type, table, slots, skills];
}

// ─── Gun (LBG / HBG) ────────────────────────────────────────────────────────

enum GunType {
  lightBowgun('lbg', 'Light Bowguns'),
  heavyBowgun('hbg', 'Heavy Bowguns'),
  bow('bow', 'Bows');

  final String short;
  final String displayName;
  const GunType(this.short, this.displayName);
  static GunType? fromShort(String s) {
    for (final t in values) {
      if (t.short == s) return t;
    }
    return null;
  }
}

class ShotClip extends Equatable {
  final int clip;
  final int? rapid; // rapid fire count (HBG only)
  const ShotClip({required this.clip, this.rapid});
  @override
  List<Object?> get props => [clip, rapid];
}

class BowCharge extends Equatable {
  final int level;
  final String type; // rapid, pierce, scatter
  final String? load; // "!" = heavy load
  const BowCharge({required this.level, required this.type, this.load});
  @override
  List<Object?> get props => [level, type];
}

class BowCoatings extends Equatable {
  final bool power;
  final bool poison;
  final bool paralyze;
  final bool sleep;
  final bool fatigue;
  final bool razor;
  final bool paint;
  const BowCoatings({
    required this.power,
    required this.poison,
    required this.paralyze,
    required this.sleep,
    required this.fatigue,
    required this.razor,
    required this.paint,
  });
  @override
  List<Object?> get props => [
    power,
    poison,
    paralyze,
    sleep,
    fatigue,
    razor,
    paint,
  ];
}

class Gun extends Equatable {
  final int index;
  final String name;
  final String description;
  final int rarity;
  final int attack;
  final int affinity;
  final int slots;
  final int price;
  final String? drift; // LBG/HBG: None, Low, High
  final String? reload; // LBG/HBG: slow/normal/fast/v.fast
  final String? recoil; // LBG/HBG
  // shots[shotIndex][levelIndex] = {clip, rapid?}
  final List<List<ShotClip>>? shots;
  // Bow specific
  final List<BowCharge>? charges;
  final BowCoatings? coatings;
  final String? rain; // spread, narrow
  // Upgrade tree (same as weapon)
  final List<MaterialRequirement>? create;
  final List<MaterialRequirement>? scraps;
  final ImproveInfoGun? improve;
  final List<int>? upgrades;
  final List<int>? path;

  const Gun({
    required this.index,
    required this.name,
    required this.description,
    required this.rarity,
    required this.attack,
    required this.affinity,
    required this.slots,
    required this.price,
    this.drift,
    this.reload,
    this.recoil,
    this.shots,
    this.charges,
    this.coatings,
    this.rain,
    this.create,
    this.scraps,
    this.improve,
    this.upgrades,
    this.path,
  });

  bool get isRoot => improve == null;
  @override
  List<Object?> get props => [index, name, rarity];
}

class ImproveInfoGun extends Equatable {
  final int from;
  final List<MaterialRequirement> materials;
  const ImproveInfoGun({required this.from, required this.materials});
  @override
  List<Object?> get props => [from, materials];
}

class GunCategory extends Equatable {
  final GunType type;
  final String displayName;
  final List<Gun> guns;
  const GunCategory({
    required this.type,
    required this.displayName,
    required this.guns,
  });
  Gun? getByIndex(int i) {
    try {
      return guns.firstWhere((g) => g.index == i);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [type];
}

// ─── Shot ────────────────────────────────────────────────────────────────────

class Shot extends Equatable {
  final String name;
  final int levels;
  const Shot({required this.name, required this.levels});
  @override
  List<Object?> get props => [name];
}

// ─── Quest ───────────────────────────────────────────────────────────────────

enum QuestHub {
  village('V'),
  guild('G');

  final String code;
  const QuestHub(this.code);
  static QuestHub fromCode(String c) => c == 'V' ? village : guild;
}

enum QuestType {
  normal('N'),
  event('E'),
  special('S');

  final String code;
  const QuestType(this.code);
  static QuestType fromCode(String c) => switch (c) {
    'E' => event,
    'S' => special,
    _ => normal,
  };
}

class QuestObjective extends Equatable {
  final String targetType; // monster / item
  final int targetId;
  final int quantity;
  final String action; // hunt / gather / slay / capture
  const QuestObjective({
    required this.targetType,
    required this.targetId,
    required this.quantity,
    required this.action,
  });
  @override
  List<Object?> get props => [targetType, targetId, quantity, action];
}

class Quest extends Equatable {
  final int id;
  final String no; // e.g. "1/9"
  final String name;
  final String? time; // Day / Night
  final int reward;
  final QuestType type;
  final QuestHub hub;
  final int star;
  final int? mapId;
  final String? unlockCondition;
  final List<QuestObjective> objectives;

  const Quest({
    required this.id,
    required this.no,
    required this.name,
    required this.reward,
    required this.type,
    required this.hub,
    required this.star,
    required this.objectives,
    this.time,
    this.mapId,
    this.unlockCondition,
  });

  @override
  List<Object?> get props => [id];
  @override
  String toString() => 'Quest(#$id $name ★$star)';
}
