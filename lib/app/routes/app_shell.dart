import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final barTheme = Theme.of(context).bottomNavigationBarTheme;
    final barColor = barTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final unselectedColor =
        barTheme.unselectedItemColor ?? AppColors.muted(context);
    final shadowColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0x40000000)
        : const Color(0x14000000);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                color: barColor,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _navItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'ana sayfa',
                    isSelected: currentIndex == 0,
                    unselectedColor: unselectedColor,
                    onTap: () => onDestinationSelected(0),
                  ),
                  _navItem(
                    icon: Icons.bar_chart_outlined,
                    selectedIcon: Icons.bar_chart,
                    label: 'analiz',
                    isSelected: currentIndex == 2,
                    unselectedColor: unselectedColor,
                    onTap: () => onDestinationSelected(2),
                  ),
                  const Expanded(child: SizedBox()),
                  _navItem(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'profil',
                    isSelected: currentIndex == 3,
                    unselectedColor: unselectedColor,
                    onTap: () => onDestinationSelected(3),
                  ),
                  _navItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: 'ayarlar',
                    isSelected: currentIndex == 4,
                    unselectedColor: unselectedColor,
                    onTap: () => onDestinationSelected(4),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -20,
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.addGift, extra: 0),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: barColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required Color unselectedColor,
    required VoidCallback onTap,
  }) {
    final color = isSelected ? AppColors.primary : unselectedColor;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
