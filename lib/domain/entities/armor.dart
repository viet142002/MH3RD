import 'package:equatable/equatable.dart';
import 'shared.dart';

enum ArmorSlot {
  helmet('hlm'),
  plate('plt'),
  gloves('arm'),
  waist('wst'),
  greaves('leg');

  final String short;
  const ArmorSlot(this.short);
  static ArmorSlot? fromShort(String s) {
    for (final v in values) {
      if (v.short == s) return v;
    }
    return null;
  }
}

class ArmorPiece extends Equatable {
  final String name;
  final int rarity;
  final int price;
  final String description;
  final int slots;
  final int defense;
  final bool isBladeArmor;
  final bool isGunnerArmor;
  final int fireRes;
  final int waterRes;
  final int thunderRes;
  final int iceRes;
  final int dragonRes;
  final List<MaterialRequirement> create;
  final List<MaterialRequirement> scraps;
  final List<SkillPoints> skills;

  const ArmorPiece({
    required this.name,
    required this.rarity,
    required this.price,
    required this.description,
    required this.slots,
    required this.defense,
    required this.isBladeArmor,
    required this.isGunnerArmor,
    required this.fireRes,
    required this.waterRes,
    required this.thunderRes,
    required this.iceRes,
    required this.dragonRes,
    required this.create,
    required this.scraps,
    required this.skills,
  });

  Set<int> get materialIds => {
    ...create.map((m) => m.id),
    ...scraps.map((m) => m.id),
  };

  Set<int> get skillIds => skills.map((s) => s.skillId).toSet();

  @override
  List<Object?> get props => [name, rarity];
}

class ArmorCategory extends Equatable {
  final ArmorSlot slot;
  final String displayName;
  final List<ArmorPiece> pieces;

  const ArmorCategory({
    required this.slot,
    required this.displayName,
    required this.pieces,
  });

  @override
  List<Object?> get props => [slot];
}
