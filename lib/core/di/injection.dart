import 'package:get_it/get_it.dart';
import '../../data/datasources/datasources.dart';
import '../../data/repositories/repository_impls.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/usecases.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Datasources ─────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => WeaponLocalDatasource())
    ..registerLazySingleton(() => ItemLocalDatasource())
    ..registerLazySingleton(() => MonsterLocalDatasource())
    ..registerLazySingleton(() => ArmorLocalDatasource())
    ..registerLazySingleton(() => SkillLocalDatasource())
    ..registerLazySingleton(() => CharmLocalDatasource())
    ..registerLazySingleton(() => GunLocalDatasource())
    ..registerLazySingleton(() => ShotLocalDatasource())
    ..registerLazySingleton(() => QuestLocalDatasource());

  // ── Repositories ─────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<WeaponRepository>(
      () => WeaponRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ItemRepository>(() => ItemRepositoryImpl(getIt()))
    ..registerLazySingleton<MonsterRepository>(
      () => MonsterRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ArmorRepository>(() => ArmorRepositoryImpl(getIt()))
    ..registerLazySingleton<SkillRepository>(() => SkillRepositoryImpl(getIt()))
    ..registerLazySingleton<CharmRepository>(() => CharmRepositoryImpl(getIt()))
    ..registerLazySingleton<GunRepository>(
      () => GunRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<QuestRepository>(
      () => QuestRepositoryImpl(getIt()),
    );

  // ── Weapon usecases ───────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => GetAllWeaponCategories(getIt()))
    ..registerLazySingleton(() => GetWeaponsByCategory(getIt()))
    ..registerLazySingleton(() => GetWeaponDetail(getIt()))
    ..registerLazySingleton(() => SearchWeapons(getIt()))
    ..registerLazySingleton(() => FilterWeapons(getIt()))
    ..registerLazySingleton(() => GetWeaponCraftingTree(getIt()))
    ..registerLazySingleton(() => GetWeaponLineage(getIt()))
    ..registerLazySingleton(() => JoinWeaponMaterials(getIt(), getIt()));

  // ── Item usecases ─────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => GetAllItems(getIt()))
    ..registerLazySingleton(() => GetItemById(getIt()))
    ..registerLazySingleton(() => SearchItems(getIt()));

  // ── Monster usecases ──────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => GetAllMonsters(getIt()))
    ..registerLazySingleton(() => GetMonsterById(getIt()))
    ..registerLazySingleton(() => SearchMonsters(getIt()))
    ..registerLazySingleton(() => GetMonstersByItem(getIt()))
    ..registerLazySingleton(() => GetMonsterDetail(getIt(), getIt()));

  // ── Armor usecases ────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => GetAllArmorCategories(getIt()))
    ..registerLazySingleton(() => GetArmorBySlot(getIt()))
    ..registerLazySingleton(() => SearchArmors(getIt()))
    ..registerLazySingleton(() => FilterArmorsBySkill(getIt(), getIt()));

  // ── Skill usecases ────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => GetAllSkills(getIt()))
    ..registerLazySingleton(() => SearchSkills(getIt()));

  // ── Charm usecases ────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => GetFilteredCharms(getIt()))
    ..registerLazySingleton(() => GetCharmsBySkill(getIt()))
    ..registerLazySingleton(() => GetAllCharmTypes(getIt()));

  // ── Gun usecases ──────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => GetAllGunCategories(getIt()))
    ..registerLazySingleton(() => GetGunsByCategory(getIt()))
    ..registerLazySingleton(() => GetGunDetail(getIt()))
    ..registerLazySingleton(() => SearchGuns(getIt()))
    ..registerLazySingleton(() => GetAllShots(getIt()));

  // ── Quest usecases ────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton(() => GetAllQuests(getIt()))
    ..registerLazySingleton(() => SearchQuests(getIt()))
    ..registerLazySingleton(() => FilterQuests(getIt()));

  // ── Global search ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton(
    () => GlobalSearch(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
}
