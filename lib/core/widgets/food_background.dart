import 'package:flutter/material.dart';

/// 따뜻한 크림색 그라데이션 위에 음식 이모지가 은은하게 깔린 배경.
class FoodBackground extends StatelessWidget {
  const FoodBackground({super.key, required this.child});

  final Widget child;

  // (이모지, 가로 비율, 세로 비율, 크기, 회전)
  static const _doodles = <(String, double, double, double, double)>[
    ('🥕', 0.06, 0.05, 40, -0.3),
    ('🍅', 0.82, 0.09, 36, 0.4),
    ('🥬', 0.50, 0.20, 32, 0.2),
    ('🍳', 0.90, 0.32, 38, -0.2),
    ('🧅', 0.08, 0.38, 34, 0.3),
    ('🥛', 0.70, 0.50, 36, -0.4),
    ('🍞', 0.15, 0.62, 40, 0.25),
    ('🧀', 0.85, 0.70, 34, -0.3),
    ('🍎', 0.45, 0.80, 36, 0.35),
    ('🥚', 0.10, 0.90, 32, -0.2),
    ('🍗', 0.78, 0.92, 38, 0.3),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = dark
        ? const [Color(0xFF2B2119), Color(0xFF241B15)]
        : const [Color(0xFFFFF6E5), Color(0xFFFFEBD2)];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, c) => Stack(
                  children: [
                    for (final (emoji, x, y, size, angle) in _doodles)
                      Positioned(
                        left: c.maxWidth * x - size / 2,
                        top: c.maxHeight * y - size / 2,
                        child: Opacity(
                          opacity: dark ? 0.08 : 0.16,
                          child: Transform.rotate(
                            angle: angle,
                            child: Text(
                              emoji,
                              style: TextStyle(fontSize: size),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
