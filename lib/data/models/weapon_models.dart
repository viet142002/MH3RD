import '../../domain/entities/weapon_entities.dart';

// ─────────────────────────────────────────────
// MaterialRequirementModel
// ─────────────────────────────────────────────
class MaterialRequirementModel extends MaterialRequirement {
  const MaterialRequirementModel({required super.id, required super.count});

  factory MaterialRequirementModel.fromJson(Map<String, dynamic> json) =>
      MaterialRequirementModel(
        id: json['id'] as int,
        count: json['count'] as int,
      );

  Map<String, dynamic> toJson() => {'id': id, 'count': count};
}

// ─────────────────────────────────────────────
// ImproveInfoModel
// ─────────────────────────────────────────────
class ImproveInfoModel extends ImproveInfo {
  const ImproveInfoModel({required super.from, required super.materials});

  factory ImproveInfoModel.fromJson(Map<String, dynamic> json) =>
      ImproveInfoModel(
        from: json['from'] as int,
        materials: (json['materials'] as List<dynamic>)
            .map(
              (e) =>
                  MaterialRequirementModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}

// ─────────────────────────────────────────────
// UpgradeInfoModel
// ─────────────────────────────────────────────
class UpgradeInfoModel extends UpgradeInfo {
  const UpgradeInfoModel({required super.price, required super.materials});

  factory UpgradeInfoModel.fromJson(Map<String, dynamic> json) =>
      UpgradeInfoModel(
        price: json['price'] as int,
        materials: (json['materials'] as List<dynamic>)
            .map(
              (e) =>
                  MaterialRequirementModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}

// ─────────────────────────────────────────────
// WeaponModel
// ─────────────────────────────────────────────
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
    super.phial,
    super.shellingType,
    super.shellingLevel,
  });

  factory WeaponModel.fromJson(
    Map<String, dynamic> json, {
    required int index,
  }) {
    return WeaponModel(
      index: index,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      rarity: json['rarity'] as int,
      attack: json['attack'] as int,
      affinity: json['affinity'] as int? ?? 0,
      slots: json['slots'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      defense: json['defense'] as int?,
      element: WeaponElement.fromString(json['element'] as String?),
      elemAttack: json['elemAttack'] != null
          ? int.tryParse(json['elemAttack'].toString())
          : null,
      sharpness: _parseIntList(json['sharpness']),
      sharpnessp: json['sharpnessp'] != null
          ? _parseIntList(json['sharpnessp'])
          : null,
      create: _parseMaterials(json['create']),
      scraps: _parseMaterials(json['scraps']),
      improve: json['improve'] != null
          ? ImproveInfoModel.fromJson(json['improve'] as Map<String, dynamic>)
          : null,
      upgrade: json['upgrade'] != null
          ? UpgradeInfoModel.fromJson(json['upgrade'] as Map<String, dynamic>)
          : null,
      upgrades: _parseIntList(json['upgrades']),
      path: _parseIntList(json['path']),
      phial: PhialType.fromString(json['phial'] as String?),
      shellingType: ShellingType.fromString(json['shellingType'] as String?),
      shellingLevel: json['shellingLevel'] as int?,
    );
  }

  static List<int> _parseIntList(dynamic raw) {
    if (raw == null) return [];
    return (raw as List<dynamic>).map((e) => e as int).toList();
  }

  static List<MaterialRequirementModel>? _parseMaterials(dynamic raw) {
    if (raw == null) return null;
    return (raw as List<dynamic>)
        .map(
          (e) => MaterialRequirementModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}

// ─────────────────────────────────────────────
// WeaponCategoryModel
// ─────────────────────────────────────────────
class WeaponCategoryModel extends WeaponCategory {
  const WeaponCategoryModel({
    required super.type,
    required super.displayName,
    required super.weapons,
  });

  factory WeaponCategoryModel.fromJson(Map<String, dynamic> json) {
    final short = json['short'] as String;
    final type =
        WeaponType.fromShort(short) ??
        (throw ArgumentError('Unknown weapon short: $short'));

    final rawWeapons = json['weapons'] as List<dynamic>;
    final weapons = rawWeapons.asMap().entries.map((entry) {
      return WeaponModel.fromJson(
        entry.value as Map<String, dynamic>,
        index: entry.key + 1, // 1-based
      );
    }).toList();

    return WeaponCategoryModel(
      type: type,
      displayName: json['name'] as String,
      weapons: weapons,
    );
  }
}
