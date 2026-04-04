import 'package:equatable/equatable.dart';
import 'shared.dart';

enum Rank { low, high, baby }

class CarveGroup extends Equatable {
  final String partName; // Body, Tail, v.v.
  final List<DropEntry> low;
  final List<DropEntry> high;
  final List<DropEntry> baby;
  const CarveGroup({
    required this.partName,
    required this.low,
    required this.high,
    required this.baby,
  });
  @override
  List<Object?> get props => [partName];

  List<DropEntry> forRank(Rank rank) => switch (rank) {
    Rank.low => low,
    Rank.high => high,
    Rank.baby => baby,
  };
}

class ShinyGroup extends Equatable {
  final String action; // tên hành động kích hoạt shiny
  final List<DropEntry> low;
  final List<DropEntry> high;
  final List<DropEntry> baby;
  const ShinyGroup({
    required this.action,
    required this.low,
    required this.high,
    required this.baby,
  });
  @override
  List<Object?> get props => [action];
}

class Monster extends Equatable {
  final int id;
  final String name;
  final List<CarveGroup> carves;
  final List<ShinyGroup> shinies;

  const Monster({
    required this.id,
    required this.name,
    required this.carves,
    required this.shinies,
  });

  bool get hasCarves => carves.isNotEmpty;
  bool get hasShinies => shinies.isNotEmpty;

  /// Tất cả item id có thể drop từ monster
  Set<int> get allItemIds {
    final ids = <int>{};
    for (final c in carves) {
      for (final e in [...c.low, ...c.high, ...c.baby]) {
        ids.add(e.itemId);
      }
    }
    for (final s in shinies) {
      for (final e in [...s.low, ...s.high, ...s.baby]) {
        ids.add(e.itemId);
      }
    }
    return ids;
  }

  @override
  List<Object?> get props => [id];
  @override
  String toString() => 'Monster(#$id $name)';
}
