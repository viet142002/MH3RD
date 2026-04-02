import 'package:equatable/equatable.dart';
import '../../../domain/entities/weapon_entities.dart';

// ─────────────────────────────────────────────
// Events
// ─────────────────────────────────────────────

abstract class WeaponEvent extends Equatable {
  const WeaponEvent();
  @override
  List<Object?> get props => [];
}

class WeaponCategoriesRequested extends WeaponEvent {
  const WeaponCategoriesRequested();
}

class WeaponListRequested extends WeaponEvent {
  final WeaponType type;
  const WeaponListRequested(this.type);
  @override
  List<Object?> get props => [type];
}

class WeaponFilterChanged extends WeaponEvent {
  final WeaponType type;
  final int? rarity;
  final WeaponElement? element;
  final String? nameQuery;

  const WeaponFilterChanged({
    required this.type,
    this.rarity,
    this.element,
    this.nameQuery,
  });

  @override
  List<Object?> get props => [type, rarity, element, nameQuery];
}

class WeaponSortChanged extends WeaponEvent {
  final WeaponSortBy sortBy;
  const WeaponSortChanged(this.sortBy);
  @override
  List<Object?> get props => [sortBy];
}

class WeaponDetailRequested extends WeaponEvent {
  final WeaponType type;
  final int index;
  const WeaponDetailRequested({required this.type, required this.index});
  @override
  List<Object?> get props => [type, index];
}

class WeaponTreeRequested extends WeaponEvent {
  final WeaponType type;
  const WeaponTreeRequested(this.type);
  @override
  List<Object?> get props => [type];
}

enum WeaponSortBy { name, attack, rarity, price }

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────

abstract class WeaponState extends Equatable {
  const WeaponState();
  @override
  List<Object?> get props => [];
}

class WeaponInitial extends WeaponState {
  const WeaponInitial();
}

class WeaponLoading extends WeaponState {
  const WeaponLoading();
}

class WeaponCategoriesLoaded extends WeaponState {
  final List<WeaponCategory> categories;
  const WeaponCategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class WeaponListLoaded extends WeaponState {
  final WeaponType type;
  final List<Weapon> weapons;
  final List<Weapon> filtered;
  final int? activeRarity;
  final WeaponElement? activeElement;
  final String? activeQuery;
  final WeaponSortBy sortBy;

  const WeaponListLoaded({
    required this.type,
    required this.weapons,
    required this.filtered,
    this.activeRarity,
    this.activeElement,
    this.activeQuery,
    this.sortBy = WeaponSortBy.name,
  });

  WeaponListLoaded copyWith({
    List<Weapon>? filtered,
    int? Function()? activeRarity,
    WeaponElement? Function()? activeElement,
    String? Function()? activeQuery,
    WeaponSortBy? sortBy,
  }) => WeaponListLoaded(
    type: type,
    weapons: weapons,
    filtered: filtered ?? this.filtered,
    activeRarity: activeRarity != null ? activeRarity() : this.activeRarity,
    activeElement: activeElement != null ? activeElement() : this.activeElement,
    activeQuery: activeQuery != null ? activeQuery() : this.activeQuery,
    sortBy: sortBy ?? this.sortBy,
  );

  @override
  List<Object?> get props => [
    type,
    weapons,
    filtered,
    activeRarity,
    activeElement,
    activeQuery,
    sortBy,
  ];
}

class WeaponDetailLoaded extends WeaponState {
  final Weapon weapon;
  final WeaponType type;
  final List<Weapon> lineage;
  final List<Weapon> children;

  const WeaponDetailLoaded({
    required this.weapon,
    required this.type,
    required this.lineage,
    required this.children,
  });

  @override
  List<Object?> get props => [weapon, type, lineage, children];
}

class WeaponTreeLoaded extends WeaponState {
  final WeaponType type;
  final List<WeaponTreeNode> roots;

  const WeaponTreeLoaded({required this.type, required this.roots});

  @override
  List<Object?> get props => [type, roots];
}

class WeaponError extends WeaponState {
  final String message;
  const WeaponError(this.message);
  @override
  List<Object?> get props => [message];
}

// Forward declare for state
class WeaponTreeNode {
  final Weapon weapon;
  final List<WeaponTreeNode> children;
  final int depth;
  const WeaponTreeNode({
    required this.weapon,
    required this.children,
    required this.depth,
  });
}
