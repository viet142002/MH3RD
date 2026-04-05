import 'package:equatable/equatable.dart';
import '../../../domain/entities/others.dart';
import '../../../domain/usecases/usecases.dart';

abstract class QuestEvent extends Equatable {
  const QuestEvent();
  @override
  List<Object?> get props => [];
}

class QuestListRequested extends QuestEvent {
  final QuestHub? hub;
  final int? star;
  const QuestListRequested({this.hub, this.star});
  @override
  List<Object?> get props => [hub, star];
}

class QuestSearchChanged extends QuestEvent {
  final String query;
  const QuestSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class QuestDetailRequested extends QuestEvent {
  final int id;
  const QuestDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class QuestState extends Equatable {
  const QuestState();
  @override
  List<Object?> get props => [];
}

class QuestInitial extends QuestState {
  const QuestInitial();
}

class QuestLoading extends QuestState {
  const QuestLoading();
}

class QuestListLoaded extends QuestState {
  final List<Quest> quests;
  final List<Quest> filtered;
  final String query;
  final QuestHub? hub;
  final int? star;

  const QuestListLoaded({
    required this.quests,
    required this.filtered,
    this.query = '',
    this.hub,
    this.star,
  });

  QuestListLoaded copyWith({
    List<Quest>? quests,
    List<Quest>? filtered,
    String? query,
    QuestHub? hub,
    int? star,
  }) {
    return QuestListLoaded(
      quests: quests ?? this.quests,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
      hub: hub ?? this.hub,
      star: star ?? this.star,
    );
  }

  @override
  List<Object?> get props => [quests, filtered, query, hub, star];
}

class QuestDetailLoaded extends QuestState {
  final QuestDetailData detail;
  const QuestDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class QuestError extends QuestState {
  final String message;
  const QuestError(this.message);
  @override
  List<Object?> get props => [message];
}
