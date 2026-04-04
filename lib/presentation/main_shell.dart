import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mh3rd/core/router/routes.dart';
import 'package:mh3rd/core/widgets/icon_widget.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    final icons = [
      MhAssetIcon.monster('Black_Diablos', size: 24),
      MhAssetIcon.equipment('gs', size: 24),
      MhAssetIcon.item('scraps_gray', size: 24),
      Icon(Icons.menu, size: 24),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(24),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / icons.length;
              return Stack(
                children: [
                  // Animated Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    left: currentIndex * tabWidth,
                    bottom: 8,
                    width: tabWidth,
                    height: 4,
                    child: Center(
                      child: Container(
                        width: 16,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(icons.length, (index) {
                      final isSelected = index == currentIndex;
                      return SizedBox(
                        width: tabWidth,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _onTap(context, index),
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                transform: Matrix4.identity()
                                  ..scale(isSelected ? 1.2 : 1.0),
                                transformAlignment: Alignment.center,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isSelected ? 1.0 : 0.5,
                                  child: icons[index],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
