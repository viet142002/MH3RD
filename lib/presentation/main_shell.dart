import 'dart:ui' show ImageFilter;
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
    if (location.startsWith(AppRoutes.items)) return 2;
    if (location.startsWith(AppRoutes.quests)) return 3;
    if (location.startsWith(AppRoutes.armor)) return 4;
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
        context.go(AppRoutes.items);
        break;
      case 3:
        context.go(AppRoutes.quests);
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
      MhAssetIcon.item('book_white', size: 24), // Quest icon
      const Icon(Icons.menu, size: 24, color: Colors.white),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
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
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                      transform: Matrix4.identity()
                                        ..scale(isSelected ? 1.2 : 1.0),
                                      transformAlignment: Alignment.center,
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 300),
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
          ),
        ),
      ),
    );
  }
}
