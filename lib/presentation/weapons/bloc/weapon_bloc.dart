import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/weapon.dart';
import '../../../domain/usecases/usecases.dart';
import 'weapon_event_state.dart';

class WeaponBloc extends Bloc<WeaponEvent, WeaponState> {
  final GetAllWeaponCategories _getAllCategories;
  final GetWeaponsByCategory _getByCategory;
  final GetWeaponDetail _getDetail;
  final FilterWeapons _filterWeapons;
  // final GetWeaponCraftingTree _getTree;
  final GetWeaponLineage _getLineage;

  WeaponBloc({
    required GetAllWeaponCategories getAllCategories,
    required GetWeaponsByCategory getByCategory,
    required GetWeaponDetail getDetail,
    required FilterWeapons filterWeapons,
    required GetWeaponCraftingTree getTree,
    required GetWeaponLineage getLineage,
  }) : _getAllCategories = getAllCategories,
       _getByCategory = getByCategory,
       _getDetail = getDetail,
       _filterWeapons = filterWeapons,
       // _getTree = getTree,
       _getLineage = getLineage,
       super(const WeaponInitial()) {
    on<WeaponCategoriesRequested>(_onCategories);
    on<WeaponListRequested>(_onList);
    on<WeaponFilterChanged>(_onFilter);
    on<WeaponSortChanged>(_onSort);
    on<WeaponDetailRequested>(_onDetail);
    // on<WeaponTreeRequested>(_onTree);
  }

  Future<void> _onCategories(
    WeaponCategoriesRequested _,
    Emitter<WeaponState> emit,
  ) async {
    emit(const WeaponLoading());
    try {
      emit(WeaponCategoriesLoaded(await _getAllCategories()));
    } catch (e) {
      emit(WeaponError(e.toString()));
    }
  }

  Future<void> _onList(
    WeaponListRequested event,
    Emitter<WeaponState> emit,
  ) async {
    emit(const WeaponLoading());
    try {
      final weapons = await _getByCategory(event.type);
      emit(
        WeaponListLoaded(
          type: event.type,
          weapons: weapons,
          filtered: _sort(weapons, WeaponSortBy.name),
        ),
      );
    } catch (e) {
      emit(WeaponError(e.toString()));
    }
  }

  Future<void> _onFilter(
    WeaponFilterChanged event,
    Emitter<WeaponState> emit,
  ) async {
    final prevSort = state is WeaponListLoaded
        ? (state as WeaponListLoaded).sortBy
        : WeaponSortBy.name;
    emit(const WeaponLoading());
    try {
      final all = await _getByCategory(event.type);
      final filtered = await _filterWeapons(
        type: event.type,
        rarity: event.rarity,
        element: event.element,
        query: event.nameQuery,
      );
      emit(
        WeaponListLoaded(
          type: event.type,
          weapons: all,
          filtered: _sort(filtered, prevSort),
          activeRarity: event.rarity,
          activeElement: event.element,
          activeQuery: event.nameQuery,
          sortBy: prevSort,
        ),
      );
    } catch (e) {
      emit(WeaponError(e.toString()));
    }
  }

  void _onSort(WeaponSortChanged event, Emitter<WeaponState> emit) {
    if (state is! WeaponListLoaded) return;
    final s = state as WeaponListLoaded;
    emit(
      s.copyWith(
        filtered: _sort(s.filtered, event.sortBy),
        sortBy: event.sortBy,
      ),
    );
  }

  Future<void> _onDetail(
    WeaponDetailRequested event,
    Emitter<WeaponState> emit,
  ) async {
    emit(const WeaponLoading());
    try {
      final weapon = await _getDetail(type: event.type, index: event.index);
      if (weapon == null) {
        emit(const WeaponError('Weapon not found'));
        return;
      }
      final lineage = await _getLineage(type: event.type, index: event.index);
      final all = await _getByCategory(event.type);
      final children =
          weapon.upgrades
              ?.map((idx) {
                try {
                  return all.firstWhere((w) => w.index == idx);
                } catch (_) {
                  return null;
                }
              })
              .whereType<Weapon>()
              .toList() ??
          [];
      emit(
        WeaponDetailLoaded(
          weapon: weapon,
          type: event.type,
          lineage: lineage,
          children: children,
        ),
      );
    } catch (e) {
      emit(WeaponError(e.toString()));
    }
  }

  // Future<void> _onTree(
  //   WeaponTreeRequested event,
  //   Emitter<WeaponState> emit,
  // ) async {
  //   emit(const WeaponLoading());
  //   try {
  //     final usecaseNodes = await _getTree(event.type);
  //     emit(
  //       WeaponTreeLoaded(type: event.type, roots: _toStateNodes(usecaseNodes)),
  //     );
  //   } catch (e) {
  //     emit(WeaponError(e.toString()));
  //   }
  // }

  List<Weapon> _sort(List<Weapon> list, WeaponSortBy by) {
    final s = [...list];
    switch (by) {
      case WeaponSortBy.name:
        s.sort((a, b) => a.name.compareTo(b.name));
      case WeaponSortBy.attack:
        s.sort((a, b) => b.attack.compareTo(a.attack));
      case WeaponSortBy.rarity:
        s.sort((a, b) => b.rarity.compareTo(a.rarity));
      case WeaponSortBy.price:
        s.sort((a, b) => b.price.compareTo(a.price));
    }
    return s;
  }

  // List<WeaponTreeNode> _toStateNodes(List<WeaponTreeNodeUsecase> nodes) => nodes
  //     .map(
  //       (n) => WeaponTreeNode(
  //         weapon: n.weapon,
  //         depth: n.depth,
  //         children: _toStateNodes(n.children),
  //       ),
  //     )
  //     .toList();
}

// typedef WeaponTreeNodeUsecase = WeaponTreeNode;
