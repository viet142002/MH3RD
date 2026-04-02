import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/weapon_models.dart';

class WeaponLocalDatasource {
  static const _path = 'assets/data/weapons.json';

  List<WeaponCategoryModel>? _cache;

  Future<List<WeaponCategoryModel>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_path);
    final list = json.decode(raw) as List<dynamic>;
    _cache = list
        .map((e) => WeaponCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  void clearCache() => _cache = null;
}
