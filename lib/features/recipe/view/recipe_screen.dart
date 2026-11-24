import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/food_background.dart';
import '../../fridge/model/ingredient.dart';
import '../../fridge/viewmodel/fridge_viewmodel.dart';
import '../../main/viewmodel/main_viewmodel.dart';

/// 추천 레시피 샘플 데이터.
/// TODO: Gemini 연동 시 냉장고 재료 기반 AI 추천 결과로 교체
class _Recipe {
  const _Recipe(this.title, this.emoji, this.time, this.level, this.needs);

  final String title;
  final String emoji;
  final String time;
  final String level;
  final List<String> needs;
}

const _recipes = <_Recipe>[
  _Recipe('닭볶음탕', '🍲', '25분', '보통', ['닭고기', '감자', '당근', '양파']),
  _Recipe('김치볶음밥', '🍚', '15분', '쉬움', ['김치', '밥', '양파', '달걀']),
  _Recipe('감자 크림수프', '🥣', '20분', '쉬움', ['감자', '우유', '양파']),
  _Recipe('돼지고기 김치찌개', '🍜', '30분', '보통', ['돼지고기', '김치', '두부']),
  _Recipe('아보카도 당근 샐러드', '🥗', '10분', '쉬움', ['아보카도', '당근']),
];

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fridge = context.watch<FridgeViewModel>();
    final items = fridge.items;
    final picked = fridge.selectedItems;
    final have = items.map((e) => e.name).toList();
    final pickedNames = picked.map((e) => e.name).toList();
    bool matches(String need, List<String> names) =>
        names.any((h) => h.contains(need) || need.contains(h));
    bool owns(String need) => matches(need, have);

    // 고른 재료가 많이 들어간 순, 같으면 보유 재료가 많은 순으로 정렬
    int pickedCount(_Recipe r) =>
        r.needs.where((n) => matches(n, pickedNames)).length;
    final sorted = [..._recipes]
      ..sort((a, b) {
        final byPicked = pickedCount(b).compareTo(pickedCount(a));
        return byPicked != 0
            ? byPicked
            : b.needs.where(owns).length.compareTo(a.needs.where(owns).length);
      });
    final urgent = items.where((e) => e.expiryDays <= 3).toList();

    return Scaffold(
      body: FoodBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                'AI 추천 레시피',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // 임박 재료 안내 배너
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [scheme.primaryContainer, scheme.tertiaryContainer],
                  ),
                ),
                child: Row(
                  children: [
                    const Text('👩‍🍳', style: TextStyle(fontSize: 44)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            urgent.isEmpty
                                ? '오늘은 뭘 만들어 볼까요?'
                                : '곧 상할 재료부터 먹어요!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            urgent.isEmpty
                                ? '냉장고 속 재료로 만들 수 있는 요리예요'
                                : urgent
                                      .map((e) => '${e.emoji}${e.name}')
                                      .join('  '),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _PickedIngredients(
                picked: picked,
                onRemove: fridge.toggleSelected,
                onPick: () => context.read<MainViewModel>().changeTab(0),
              ),
              const SizedBox(height: 20),
              Text(
                '내 냉장고로 만들 수 있는 요리',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              for (final r in sorted) ...[
                _RecipeTile(recipe: r, owns: owns),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 냉장고 탭에서 고른 재료를 칩으로 보여 주는 영역.
class _PickedIngredients extends StatelessWidget {
  const _PickedIngredients({
    required this.picked,
    required this.onRemove,
    required this.onPick,
  });

  final List<Ingredient> picked;
  final ValueChanged<Ingredient> onRemove;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '오늘 쓸 재료',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.kitchen_outlined, size: 18),
                  label: Text(picked.isEmpty ? '냉장고에서 고르기' : '다시 고르기'),
                ),
              ],
            ),
            if (picked.isEmpty)
              Text(
                '냉장고 탭의 "재료 선택" 버튼으로 오늘 쓸 재료를 골라 보세요.',
                style: theme.textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final item in picked)
                    InputChip(
                      label: Text('${item.emoji} ${item.name}'),
                      backgroundColor: scheme.primaryContainer,
                      onDeleted: () => onRemove(item),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.recipe, required this.owns});

  final _Recipe recipe;
  final bool Function(String) owns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final haveCount = recipe.needs.where(owns).length;
    final ratio = haveCount / recipe.needs.length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primaryContainer, scheme.tertiaryContainer],
                ),
              ),
              child: Text(recipe.emoji, style: const TextStyle(fontSize: 38)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: scheme.primary),
                      const SizedBox(width: 3),
                      Text(recipe.time, style: theme.textTheme.bodySmall),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.local_fire_department_outlined,
                        size: 14,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(recipe.level, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final n in recipe.needs)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: owns(n)
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            owns(n) ? '✓ $n' : n,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: owns(n)
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant,
                              fontWeight: owns(n)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '재료 $haveCount/${recipe.needs.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
