// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/weapon_entities.dart';
import '../../presentation/weapons/pages/weapon_category_list_page.dart';
import '../../presentation/weapons/pages/weapon_list_page.dart';
import '../../presentation/weapons/pages/weapon_detail_page.dart';
// import '../../presentation/weapons/pages/weapon_tree_page.dart';

final router = GoRouter(
  initialLocation: '/weapons',
  routes: [
    GoRoute(
      path: '/weapons',
      name: 'weapon-categories',
      builder: (_, __) => const WeaponCategoryListPage(),
      routes: [
        GoRoute(
          path: ':type',
          name: 'weapon-list',
          builder: (_, state) {
            final short = state.pathParameters['type']!;
            final type = WeaponType.fromShort(short) ?? WeaponType.greatSword;
            return WeaponListPage(type: type);
          },
          routes: [
            GoRoute(
              path: ':index',
              name: 'weapon-detail',
              builder: (_, state) {
                final short = state.pathParameters['type']!;
                final index = int.parse(state.pathParameters['index']!);
                final type =
                    WeaponType.fromShort(short) ?? WeaponType.greatSword;
                return WeaponDetailPage(type: type, index: index);
              },
            ),
          ],
        ),
        // GoRoute(
        //   path: ':type/tree',
        //   name: 'weapon-tree',
        //   builder: (_, state) {
        //     final short = state.pathParameters['type']!;
        //     final type = WeaponType.fromShort(short) ?? WeaponType.greatSword;
        //     return WeaponTreePage(type: type);
        //   },
        // ),
      ],
    ),
  ],
);
