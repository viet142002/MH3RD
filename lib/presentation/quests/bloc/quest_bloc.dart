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
    final s = (state is QuestListLoaded) ? (state as QuestListLoaded) : null;
    
    // If we already have something but want to update stars
    if (s != null && event.star != s.star) {
      emit(s.copyWith(star: event.star));
      return;
    }

    if (s == null) {
      emit(const QuestLoading());
      try {
        final village = await _filter(hub: QuestHub.village);
        final guild = await _filter(hub: QuestHub.guild);
        emit(QuestListLoaded(
          villageQuests: village,
          guildQuests: guild,
        ));
      } catch (e) {
        emit(QuestError(e.toString()));
      }
    }
  }

  Future<void> _onSearch(
    QuestSearchChanged event,
    Emitter<QuestState> emit,
  ) async {
    if (state is! QuestListLoaded) return;
    final s = state as QuestListLoaded;
    emit(s.copyWith(query: event.query));
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
