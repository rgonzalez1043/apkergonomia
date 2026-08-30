import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/router/route_names.dart';
import '../../core/constants/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Inicio', route: RouteNames.home),
    _NavItem(
        icon: Icons.healing_rounded, label: 'Dolor', route: RouteNames.pain),
    _NavItem(
        icon: Icons.air_rounded,
        label: 'Respirar',
        route: RouteNames.breathing),
    _NavItem(
        icon: Icons.emoji_events_rounded,
        label: 'Logros',
        route: RouteNames.achievements),
    _NavItem(
        icon: Icons.settings_rounded,
        label: 'Ajustes',
        route: RouteNames.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => context.go(_items[index].route),
      items: _items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
      selectedItemColor: AppColors.primary,
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem(
      {required this.icon, required this.label, required this.route});
}
