import 'package:equatable/equatable.dart';
import 'shared.dart';
export 'shared.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum WeaponType {
  greatSword('gs', 'Great Swords'),
  longSword('ls', 'Long Swords'),
  swordAndShield('sns', 'Sword & Shield'),
  dualSwords('ds', 'Dual Swords'),
  hammer('hm', 'Hammer'),
  huntingHorn('hh', 'Hunting Horn'),
  lance('lc', 'Lance'),
  gunlance('gl', 'Gunlance'),
  switchAxe('sa', 'Switch Axe');

  final String short;
  final String displayName;
  const WeaponType(this.short, this.displayName);

  static WeaponType? fromShort(String s) {
    for (final t in values) {
      if (t.short == s) return t;
    }
    return null;
  }
}

enum WeaponElement {
  fire,
  water,
  thunder,
  ice,
  dragon,
  poison,
  paralyze,
  sleep,
  blast;

  static WeaponElement? fromString(String? v) {
    if (v == null) return null;
    for (final e in values) {
      if (e.name == v.toLowerCase()) return e;
    }
    return null;
  }

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

enum PhialType {
  power,
  element,
  exhaust,
  paralysis,
  poison;

  static PhialType? fromString(String? v) {
    if (v == null) return null;
    for (final e in values) {
      if (e.name == v.toLowerCase()) return e;
    }
    return null;
  }
}

enum ShellingType {
  normal,
  wide,
  long;

  static ShellingType? fromString(String? v) {
    if (v == null) return null;
    for (final e in values) {
      if (e.name == v.toLowerCase()) return e;
    }
    return null;
  }
}

// ─── Value objects ───────────────────────────────────────────────────────────

class ImproveInfo extends Equatable {
  final int from;
  final List<MaterialRequirement> materials;
  const ImproveInfo({required this.from, required this.materials});
  @override
  List<Object?> get props => [from, materials];
}

class UpgradeInfo extends Equatable {
  final int price;
  final List<MaterialRequirement> materials;
  const UpgradeInfo({required this.price, required this.materials});
  @override
  List<Object?> get props => [price, materials];
}

// ─── Weapon entity ───────────────────────────────────────────────────────────

class Weapon extends Equatable {
  final int index; // 1-based, khớp với upgrades/path/improve.from
  final String name;
  final String description;
  final int rarity;
  final int attack;
  final int affinity;
  final int slots;
  final int price;
  final int? defense;
  final WeaponElement? element;
  final int? elemAttack;
  final List<int>
  sharpness; // [red, orange, yellow, green, blue, white, purple]
  final List<int>? sharpnessp; // với Sharpness+1
  final List<MaterialRequirement>? create;
  final List<MaterialRequirement>? scraps;
  final ImproveInfo? improve;
  final UpgradeInfo? upgrade;
  final List<int>? upgrades; // index con
  final List<int>? path; // cây phả hệ
  // Gunlance
  final ShellingType? shellingType;
  final int? shellingLevel;
  // Switch Axe
  final PhialType? phial;

  const Weapon({
    required this.index,
    required this.name,
    required this.description,
    required this.rarity,
    required this.attack,
    required this.affinity,
    required this.slots,
    required this.price,
    required this.sharpness,
    this.defense,
    this.element,
    this.elemAttack,
    this.sharpnessp,
    this.create,
    this.scraps,
    this.improve,
    this.upgrade,
    this.upgrades,
    this.path,
    this.shellingType,
    this.shellingLevel,
    this.phial,
  });

  bool get isRoot => improve == null;
  bool get hasElement => element != null;
  bool get hasDefenseBonus => defense != null && defense! > 0;
  Set<int> get materialIds {
    final ids = <int>{};
    create?.forEach((m) => ids.add(m.id));
    scraps?.forEach((m) => ids.add(m.id));
    improve?.materials.forEach((m) => ids.add(m.id));
    upgrade?.materials.forEach((m) => ids.add(m.id));
    return ids;
  }

  @override
  List<Object?> get props => [index, name, rarity];
}

class WeaponCategory extends Equatable {
  final WeaponType type;
  final String displayName;
  final List<Weapon> weapons;

  const WeaponCategory({
    required this.type,
    required this.displayName,
    required this.weapons,
  });

  Weapon? getByIndex(int i) {
    try {
      return weapons.firstWhere((w) => w.index == i);
    } catch (_) {
      return null;
    }
  }

  List<Weapon> get roots => weapons.where((w) => w.isRoot).toList();
  List<Weapon> byRarity(int r) => weapons.where((w) => w.rarity == r).toList();
  List<Weapon> byElement(WeaponElement el) =>
      weapons.where((w) => w.element == el).toList();
  Set<int> get allMaterialIds => weapons.expand((w) => w.materialIds).toSet();

  @override
  List<Object?> get props => [type];
}
