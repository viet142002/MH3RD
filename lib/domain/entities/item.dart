import 'package:equatable/equatable.dart';

class ItemObtain extends Equatable {
  final int? buyPrice;
  const ItemObtain({this.buyPrice});
  @override
  List<Object?> get props => [buyPrice];
}

class ItemUses extends Equatable {
  /// id của decorations có thể craft từ item này
  final List<int>? decorationIds;
  const ItemUses({this.decorationIds});
  @override
  List<Object?> get props => [decorationIds];
}

class Item extends Equatable {
  final int id;
  final String name;
  final int rarity;
  final String? color;
  final String? icon;
  final int? value; // sell price
  final ItemObtain? obtain;
  final ItemUses? uses;

  const Item({
    required this.id,
    required this.name,
    required this.rarity,
    this.color,
    this.icon,
    this.value,
    this.obtain,
    this.uses,
  });

  @override
  List<Object?> get props => [id];
  @override
  String toString() => 'Item(#$id $name)';
}
