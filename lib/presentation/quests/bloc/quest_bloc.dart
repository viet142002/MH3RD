import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/others.dart';
import '../../../domain/usecases/usecases.dart';
import 'quest_event_state.dart';

class QuestBloc extends Bloc<QuestEvent, QuestState> {
  final FilterQuests _filter;
  final GetQuestDetail _getDetail;

  QuestBloc({
    required FilterQuests filter,
    required SearchQuests search,
    required GetQuestDetail getDetail,
  }) : _filter = filter,
       _getDetail = getDetail,
       super(const QuestInitial()) {
    on<QuestListRequested>(_onList);
    on<QuestSearchChanged>(_onSearch);
    on<QuestDetailRequested>(_onDetail);
  }

  Future<void> _onList(
    QuestListRequested event,
    Emitter<QuestState> emit,
  ) async {
    final currentQuery =
        (state is QuestListLoaded) ? (state as QuestListLoaded).query : '';
    emit(const QuestLoading());
    try {
      final quests = await _filter(hub: event.hub, star: event.star);

      // Re-apply query if any
      List<Quest> filteredList = quests;
      if (currentQuery.isNotEmpty) {
        final q = currentQuery.toLowerCase();
        filteredList =
            quests
                .where(
                  (qu) =>
                      qu.name.toLowerCase().contains(q) ||
                      qu.no.toLowerCase().contains(q),
                )
                .toList();
      }

      emit(
        QuestListLoaded(
          quests: quests,
          filtered: filteredList,
          query: currentQuery,
          hub: event.hub,
          star: event.star,
        ),
      );
    } catch (e) {
      emit(QuestError(e.toString()));
    }
  }

  Future<void> _onSearch(
    QuestSearchChanged event,
    Emitter<QuestState> emit,
  ) async {
    if (state is! QuestListLoaded) return;
    final s = state as QuestListLoaded;

    if (event.query.isEmpty) {
      emit(s.copyWith(filtered: s.quests, query: ''));
      return;
    }

    final q = event.query.toLowerCase();
    final filtered =
        s.quests
            .where(
              (qu) =>
                  qu.name.toLowerCase().contains(q) ||
                  qu.no.toLowerCase().contains(q),
            )
            .toList();

    emit(s.copyWith(filtered: filtered, query: event.query));
  }

  Future<void> _onDetail(
    QuestDetailRequested event,
    Emitter<QuestState> emit,
  ) async {
    emit(const QuestLoading());
    try {
      final detail = await _getDetail(event.id);
      if (detail != null) {
        emit(QuestDetailLoaded(detail));
      } else {
        emit(const QuestError('Quest not found'));
      }
    } catch (e) {
      emit(QuestError(e.toString()));
    }
  }
}
