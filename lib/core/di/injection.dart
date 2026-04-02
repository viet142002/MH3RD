import 'package:get_it/get_it.dart';
import '../../data/datasources/weapon_local_datasource.dart';
import '../../data/repositories/weapon_repository_impl.dart';
import '../../domain/repositories/weapon_repository.dart';
import '../../domain/usecases/weapon_usecases.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Datasources
  getIt.registerLazySingleton<WeaponLocalDatasource>(
    () => WeaponLocalDatasource(),
  );

  // Repositories
  getIt.registerLazySingleton<WeaponRepository>(
    () => WeaponRepositoryImpl(getIt<WeaponLocalDatasource>()),
  );

  // Usecases
  getIt.registerLazySingleton(
    () => GetAllWeaponCategories(getIt<WeaponRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetWeaponsByCategory(getIt<WeaponRepository>()),
  );
  getIt.registerLazySingleton(() => GetWeaponDetail(getIt<WeaponRepository>()));
  getIt.registerLazySingleton(() => SearchWeapons(getIt<WeaponRepository>()));
  getIt.registerLazySingleton(() => FilterWeapons(getIt<WeaponRepository>()));
  getIt.registerLazySingleton(
    () => GetWeaponCraftingTree(getIt<WeaponRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetWeaponLineage(getIt<WeaponRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetWeaponMaterialIds(getIt<WeaponRepository>()),
  );
}
