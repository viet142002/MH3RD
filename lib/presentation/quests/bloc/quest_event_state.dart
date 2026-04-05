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
  final List<Quest> villageQuests;
  final List<Quest> guildQuests;
  final String query;
  final int? star;

  const QuestListLoaded({
    required this.villageQuests,
    required this.guildQuests,
    this.query = '',
    this.star,
  });

  List<Quest> getFiltered(QuestHub hub) {
    final list = hub == QuestHub.village ? villageQuests : guildQuests;
    if (query.isEmpty && star == null) return list;

    return list.where((q) {
      final matchQuery = query.isEmpty ||
          q.name.toLowerCase().contains(query.toLowerCase()) ||
          q.no.toLowerCase().contains(query.toLowerCase());
      final matchStar = star == null || q.star == star;
      return matchQuery && matchStar;
    }).toList();
  }

  QuestListLoaded copyWith({
    List<Quest>? villageQuests,
    List<Quest>? guildQuests,
    String? query,
    int? star,
  }) {
    return QuestListLoaded(
      villageQuests: villageQuests ?? this.villageQuests,
      guildQuests: guildQuests ?? this.guildQuests,
      query: query ?? this.query,
      star: star ?? this.star,
    );
  }

  @override
  List<Object?> get props => [villageQuests, guildQuests, query, star];
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
