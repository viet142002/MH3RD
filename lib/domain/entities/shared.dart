import 'package:equatable/equatable.dart';

// ─── Shared value objects ────────────────────────────────────────────────────

class MaterialRequirement extends Equatable {
  final int id;
  final int count;
  const MaterialRequirement({required this.id, required this.count});
  @override
  List<Object?> get props => [id, count];
}

class DropEntry extends Equatable {
  final int itemId;
  final int count;
  final int chance;
  const DropEntry({
    required this.itemId,
    required this.count,
    required this.chance,
  });
  @override
  List<Object?> get props => [itemId, count, chance];
}

class SkillPoints extends Equatable {
  final int skillId;
  final int points;
  const SkillPoints({required this.skillId, required this.points});
  @override
  List<Object?> get props => [skillId, points];
}
