import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/usecases.dart';
import 'monster_event_state.dart';

class MonsterBloc extends Bloc<MonsterEvent, MonsterState> {
  final GetAllMonsters _getAll;
  final GetMonsterDetail _getDetail;
  final SearchMonsters _search;

  MonsterBloc({
    required GetAllMonsters getAll,
    required GetMonsterDetail getDetail,
    required SearchMonsters search,
  }) : _getAll = getAll,
       _getDetail = getDetail,
       _search = search,
       super(const MonsterInitial()) {
    on<MonsterListRequested>(_onList);
    on<MonsterSearchChanged>(_onSearch);
    on<MonsterDetailRequested>(_onDetail);
  }

  Future<void> _onList(
    MonsterListRequested event,
    Emitter<MonsterState> emit,
  ) async {
    emit(const MonsterLoading());
    try {
      final monsters = await _getAll();
      emit(MonsterListLoaded(monsters: monsters, filtered: monsters));
    } catch (e) {
      emit(MonsterError(e.toString()));
    }
  }

  Future<void> _onSearch(
    MonsterSearchChanged event,
    Emitter<MonsterState> emit,
  ) async {
    if (state is! MonsterListLoaded) return;
    final s = state as MonsterListLoaded;

    if (event.query.isEmpty) {
      emit(
        MonsterListLoaded(
          monsters: s.monsters,
          filtered: s.monsters,
          activeQuery: '',
        ),
      );
      return;
    }

    try {
      final filtered = await _search(event.query);
      emit(
        MonsterListLoaded(
          monsters: s.monsters,
          filtered: filtered,
          activeQuery: event.query,
        ),
      );
    } catch (e) {
      emit(MonsterError(e.toString()));
    }
  }

  Future<void> _onDetail(
    MonsterDetailRequested event,
    Emitter<MonsterState> emit,
  ) async {
    emit(const MonsterLoading());
    try {
      final detail = await _getDetail(event.id);
      if (detail != null) {
        emit(MonsterDetailLoaded(detail));
      } else {
        emit(const MonsterError('Monster not found'));
      }
    } catch (e) {
      emit(MonsterError(e.toString()));
    }
  }
}
