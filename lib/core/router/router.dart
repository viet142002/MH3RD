import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mh3rd/core/router/routes.dart';
import 'package:mh3rd/presentation/main_shell.dart';
import '../../domain/entities/weapon.dart';
import '../../presentation/weapons/pages/weapon_category_list_page.dart';
import '../../presentation/weapons/pages/weapon_list_page.dart';
import '../../presentation/weapons/pages/weapon_detail_page.dart';
import '../../presentation/monsters/pages/monster_list_page.dart';
import '../../presentation/monsters/pages/monster_detail_page.dart';
import '../../presentation/quests/pages/quest_list_page.dart';
import '../../presentation/quests/pages/quest_detail_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.monsters,
  redirect: (context, state) {
    final currentPath = state.fullPath;
    if (currentPath == null || currentPath == '/') {
      return AppRoutes.monsters;
    }
    return null;
  },
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.monsters,
          builder: (context, state) => const MonsterListPage(),
        ),
        GoRoute(
          path: AppRoutes.weapons,
          builder: (context, state) => const WeaponCategoryListPage(),
          routes: [
            GoRoute(
              path: ':type',
              name: 'weapon-list',
              builder: (_, state) {
                final short = state.pathParameters['type']!;
                final type =
                    WeaponType.fromShort(short) ?? WeaponType.greatSword;
                return WeaponListPage(type: type);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.armor,
          builder: (context, state) => const WeaponCategoryListPage(),
        ),
        GoRoute(
          path: AppRoutes.items,
          builder: (context, state) => const WeaponCategoryListPage(),
        ),
        GoRoute(
          path: AppRoutes.quests,
          builder: (context, state) => const QuestListPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/weapons/:type/:index',
      name: 'weapon-detail',
      builder: (_, state) {
        final short = state.pathParameters['type']!;
        final index = int.parse(state.pathParameters['index']!);
        final type = WeaponType.fromShort(short) ?? WeaponType.greatSword;
        return WeaponDetailPage(type: type, index: index);
      },
    ),
    GoRoute(
      path: '/monsters/:id',
      name: 'monster-detail',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return MonsterDetailPage(id: id);
      },
    ),
    GoRoute(
      path: '/quests/:id',
      name: 'quest-detail',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return QuestDetailPage(id: id);
      },
    ),
  ],
);
