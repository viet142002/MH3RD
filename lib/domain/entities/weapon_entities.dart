import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────
// Enums
// ─────────────────────────────────────────────

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

  static WeaponType? fromShort(String short) {
    for (final t in values) {
      if (t.short == short) return t;
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

  String get displayName => switch (this) {
    WeaponElement.fire => 'Fire',
    WeaponElement.water => 'Water',
    WeaponElement.thunder => 'Thunder',
    WeaponElement.ice => 'Ice',
    WeaponElement.dragon => 'Dragon',
    WeaponElement.poison => 'Poison',
    WeaponElement.paralyze => 'Paralyze',
    WeaponElement.sleep => 'Sleep',
    WeaponElement.blast => 'Blast',
  };
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

// ─────────────────────────────────────────────
// Value objects
// ─────────────────────────────────────────────

class MaterialRequirement extends Equatable {
  final int id;
  final int count;

  const MaterialRequirement({required this.id, required this.count});

  @override
  List<Object?> get props => [id, count];
}

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

// ─────────────────────────────────────────────
// Weapon entity
// ─────────────────────────────────────────────

class Weapon extends Equatable {
  /// 1-based index — khớp với giá trị trong upgrades/path/improve.from.
  final int index;
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

  /// Độ sắc bén cơ bản [red, orange, yellow, green, blue, white, purple].
  final List<int> sharpness;

  /// Độ sắc bén khi có Sharpness+1.
  final List<int>? sharpnessp;

  final List<MaterialRequirement>? create;
  final List<MaterialRequirement>? scraps;
  final ImproveInfo? improve;
  final UpgradeInfo? upgrade;

  /// Index các vũ khí có thể nâng cấp tiếp.
  final List<int>? upgrades;

  /// Cây phả hệ từ gốc đến vũ khí cha.
  final List<int>? path;

  // Đặc thù theo loại
  final PhialType? phial;
  final ShellingType? shellingType;
  final int? shellingLevel;

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
    this.phial,
    this.shellingType,
    this.shellingLevel,
  });

  bool get isRootWeapon => improve == null;
  bool get hasElement => element != null;
  bool get hasDefenseBonus => defense != null && defense! > 0;
  bool get canUpgrade => upgrades != null && upgrades!.isNotEmpty;
  bool get hasSharpenedVariant => sharpnessp != null;

  Set<int> get allMaterialIds {
    final ids = <int>{};
    create?.forEach((m) => ids.add(m.id));
    scraps?.forEach((m) => ids.add(m.id));
    improve?.materials.forEach((m) => ids.add(m.id));
    upgrade?.materials.forEach((m) => ids.add(m.id));
    return ids;
  }

  @override
  List<Object?> get props => [index, name, rarity];

  @override
  String toString() => 'Weapon(#$index $name r$rarity atk$attack)';
}

// ─────────────────────────────────────────────
// WeaponCategory entity
// ─────────────────────────────────────────────

class WeaponCategory extends Equatable {
  final WeaponType type;
  final String displayName;
  final List<Weapon> weapons;

  const WeaponCategory({
    required this.type,
    required this.displayName,
    required this.weapons,
  });

  Weapon? getByIndex(int index) {
    try {
      return weapons.firstWhere((w) => w.index == index);
    } catch (_) {
      return null;
    }
  }

  List<Weapon> get rootWeapons => weapons.where((w) => w.isRootWeapon).toList();

  List<Weapon> byRarity(int rarity) =>
      weapons.where((w) => w.rarity == rarity).toList();

  List<Weapon> byElement(WeaponElement el) =>
      weapons.where((w) => w.element == el).toList();

  Set<int> get allMaterialIds {
    final ids = <int>{};
    for (final w in weapons) {
      ids.addAll(w.allMaterialIds);
    }
    return ids;
  }

  @override
  List<Object?> get props => [type];
}
