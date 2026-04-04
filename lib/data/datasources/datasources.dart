import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

// ── Base ──────────────────────────────────────────────────────────────────────

abstract class _JsonDatasource<T> {
  final String assetPath;
  _JsonDatasource(this.assetPath);
  List<T>? _cache;

  Future<List<T>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final list = json.decode(raw) as List<dynamic>;
    _cache = list.map((e) => parse(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  T parse(Map<String, dynamic> json);
  void clearCache() => _cache = null;
}

// ── Datasources ───────────────────────────────────────────────────────────────

class WeaponLocalDatasource {
  static const _path = 'assets/data/weapons.json';
  List<WeaponCategoryModel>? _cache;

  Future<List<WeaponCategoryModel>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_path);
    final list = json.decode(raw) as List;
    _cache = list
        .map((e) => WeaponCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  void clearCache() => _cache = null;
}

class ItemLocalDatasource extends _JsonDatasource<ItemModel> {
  ItemLocalDatasource() : super('assets/data/items.json');
  @override
  ItemModel parse(Map<String, dynamic> j) => ItemModel.fromJson(j);
}

class MonsterLocalDatasource extends _JsonDatasource<MonsterModel> {
  MonsterLocalDatasource() : super('assets/data/monsters.json');
  @override
  MonsterModel parse(Map<String, dynamic> j) => MonsterModel.fromJson(j);
}

class ArmorLocalDatasource {
  static const _path = 'assets/data/armors.json';
  List<ArmorCategoryModel>? _cache;

  Future<List<ArmorCategoryModel>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_path);
    final list = json.decode(raw) as List;
    _cache = list
        .map((e) => ArmorCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  void clearCache() => _cache = null;
}

class SkillLocalDatasource {
  static const _path = 'assets/data/skills.json';
  List<SkillModel>? _cache;

  Future<List<SkillModel>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_path);
    final list = json.decode(raw) as List;
    _cache = list
        .asMap()
        .entries
        .map(
          (e) => SkillModel.fromJson(
            e.value as Map<String, dynamic>,
            index: e.key,
          ),
        )
        .toList();
    return _cache!;
  }

  void clearCache() => _cache = null;
}

class CharmLocalDatasource {
  static const _pathAll = 'assets/data/charms.json';
  static const _pathFiltered = 'assets/data/charmsFiltered.json';
  List<CharmModel>? _allCache;
  List<CharmModel>? _filteredCache;

  Future<List<CharmModel>> loadAll() async {
    if (_allCache != null) return _allCache!;
    final raw = await rootBundle.loadString(_pathAll);
    final list = json.decode(raw) as List;
    _allCache = list
        .map((e) => CharmModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _allCache!;
  }

  Future<List<CharmModel>> loadFiltered() async {
    if (_filteredCache != null) return _filteredCache!;
    final raw = await rootBundle.loadString(_pathFiltered);
    final list = json.decode(raw) as List;
    _filteredCache = list
        .map((e) => CharmModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _filteredCache!;
  }

  void clearCache() {
    _allCache = null;
    _filteredCache = null;
  }
}

class GunLocalDatasource {
  static const _path = 'assets/data/guns.json';
  List<GunCategoryModel>? _cache;

  Future<List<GunCategoryModel>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_path);
    final list = json.decode(raw) as List;
    _cache = list
        .map((e) => GunCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  void clearCache() => _cache = null;
}

class ShotLocalDatasource extends _JsonDatasource<ShotModel> {
  ShotLocalDatasource() : super('assets/data/shots.json');
  @override
  ShotModel parse(Map<String, dynamic> j) => ShotModel.fromJson(j);
}

class QuestLocalDatasource extends _JsonDatasource<QuestModel> {
  QuestLocalDatasource() : super('assets/data/quests.json');
  @override
  QuestModel parse(Map<String, dynamic> j) => QuestModel.fromJson(j);
}
