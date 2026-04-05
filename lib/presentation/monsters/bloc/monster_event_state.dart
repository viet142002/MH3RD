import 'package:equatable/equatable.dart';
import '../../../domain/entities/monster.dart';
import '../../../domain/usecases/usecases.dart';

// ─────────────────────────────────────────────
// Events
// ─────────────────────────────────────────────

abstract class MonsterEvent extends Equatable {
  const MonsterEvent();
  @override
  List<Object?> get props => [];
}

class MonsterListRequested extends MonsterEvent {
  const MonsterListRequested();
}

class MonsterSearchChanged extends MonsterEvent {
  final String query;
  const MonsterSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class MonsterDetailRequested extends MonsterEvent {
  final int id;
  const MonsterDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────

abstract class MonsterState extends Equatable {
  const MonsterState();
  @override
  List<Object?> get props => [];
}

class MonsterInitial extends MonsterState {
  const MonsterInitial();
}

class MonsterLoading extends MonsterState {
  const MonsterLoading();
}

class MonsterListLoaded extends MonsterState {
  final List<Monster> monsters;
  final List<Monster> filtered;
  final String activeQuery;

  const MonsterListLoaded({
    required this.monsters,
    required this.filtered,
    this.activeQuery = '',
  });

  @override
  List<Object?> get props => [monsters, filtered, activeQuery];
}

class MonsterDetailLoaded extends MonsterState {
  final MonsterDetail detail;
  const MonsterDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class MonsterError extends MonsterState {
  final String message;
  const MonsterError(this.message);
  @override
  List<Object?> get props => [message];
}
