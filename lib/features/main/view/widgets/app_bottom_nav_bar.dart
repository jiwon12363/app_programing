import 'package:flutter/material.dart';

/// 가운데 스캔 버튼(FAB)이 파고드는 형태의 하단 바.
/// 탭 인덱스: 0 내 냉장고, 1 영수증 스캔(FAB), 2 AI 레시피
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      height: 68,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.kitchen_outlined,
              selectedIcon: Icons.kitchen,
              label: '내 냉장고',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '스캔',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: currentIndex == 1
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.restaurant_menu_outlined,
              selectedIcon: Icons.restaurant_menu,
              label: 'AI 레시피',
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color, fontWeight: selected ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }
}
