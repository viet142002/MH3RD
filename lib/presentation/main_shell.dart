import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mh3rd/core/router/routes.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.monsters)) return 0;
    if (location.startsWith(AppRoutes.weapons)) return 1;
    if (location.startsWith(AppRoutes.armor)) return 2;
    if (location.startsWith(AppRoutes.items)) return 3;
    if (location.startsWith(AppRoutes.quests)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.monsters);
        break;
      case 1:
        context.go(AppRoutes.weapons);
        break;
      case 2:
        context.go(AppRoutes.armor);
        break;
      case 3:
        context.go(AppRoutes.items);
        break;
      case 4:
        context.go(AppRoutes.quests);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon),
            label: 'Monsters',
            activeIcon: Icon(Icons.catching_pokemon, color: Colors.blue),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.architecture),
            label: 'Weapons',
            activeIcon: Icon(Icons.architecture, color: Colors.blue),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Armor'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Items',
            activeIcon: Icon(Icons.inventory_2, color: Colors.blue),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Quests',
            activeIcon: Icon(Icons.assignment, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
