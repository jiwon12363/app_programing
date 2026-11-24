import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/food_background.dart';
import '../../main/viewmodel/main_viewmodel.dart';
import '../model/food_category.dart';
import '../model/ingredient.dart';
import '../viewmodel/fridge_viewmodel.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  static const _all = '전체';
  String _filter = _all;

  Future<void> _showAddDialog() async {
    final name = TextEditingController();
    final qty = TextEditingController(text: '1');
    final unit = TextEditingController(text: '개');
    final days = TextEditingController(text: '7');
    var category = FoodCategory.etc;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('식재료 수동 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qty,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '수량'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: unit,
                      decoration: const InputDecoration(labelText: '단위'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: days,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '남은 유통기한(일)'),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (ctx, setLocal) => DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: '분류'),
                  items: [
                    for (final c in FoodCategory.all)
                      DropdownMenuItem(
                        value: c,
                        child: Text('${FoodCategory.emojiOf(c)} $c'),
                      ),
                  ],
                  onChanged: (v) => setLocal(() => category = v ?? category),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (ok == true && name.text.trim().isNotEmpty && mounted) {
      context.read<FridgeViewModel>().add(
        Ingredient(
          name: name.text.trim(),
          quantity: int.tryParse(qty.text) ?? 1,
          unit: unit.text.trim().isEmpty ? '개' : unit.text.trim(),
          expiryDays: int.tryParse(days.text) ?? 7,
          category: category,
        ),
      );
    }
    name.dispose();
    qty.dispose();
    unit.dispose();
    days.dispose();
  }

  void _delete(int index) {
    final fridge = context.read<FridgeViewModel>();
    final removed = fridge.removeAt(index);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // 최신 Flutter는 action이 있는 스낵바를 자동으로 닫지 않으므로 persist: false 필요
          persist: false,
          duration: const Duration(seconds: 3),
          content: Text('${removed.name}을(를) 삭제했어요'),
          action: SnackBarAction(
            label: '실행 취소',
            onPressed: () => fridge.insert(index, removed),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<MainViewModel>();
    final fridge = context.watch<FridgeViewModel>();
    final items = fridge.items;
    // 선택한 분류에 항목이 하나도 없어지면(삭제 등) 전체로 되돌린다.
    final filter = items.any((e) => e.category == _filter) ? _filter : _all;
    final visible = filter == _all
        ? items
        : items.where((e) => e.category == filter).toList();
    final theme = Theme.of(context);

    return Scaffold(
      body: FoodBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 재료 선택 모드일 때만 위에 고정되는 안내 바
              if (fridge.isSelecting)
                _SelectionBar(
                  count: fridge.selectedItems.length,
                  onCancel: fridge.clearSelection,
                  onConfirm: () {
                    fridge.finishSelecting();
                    vm.changeTab(2);
                  },
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    // 상단 타이틀 + 알림
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'AI 냉장고 파먹기',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ScanBanner(onScan: () => vm.changeTab(1)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '내 냉장고 현황',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!fridge.isSelecting)
                          FilledButton.tonalIcon(
                            onPressed: items.isEmpty
                                ? null
                                : fridge.startSelecting,
                            icon: const Icon(Icons.checklist, size: 18),
                            label: const Text('재료 선택'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final c in [_all, ...FoodCategory.all])
                            if (c == _all || items.any((e) => e.category == c))
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    c == _all
                                        ? '전체 ${items.length}'
                                        : '${FoodCategory.emojiOf(c)} $c '
                                              '${items.where((e) => e.category == c).length}',
                                  ),
                                  selected: _filter == c,
                                  onSelected: (_) =>
                                      setState(() => _filter = c),
                                ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('이 분류에 식재료가 없어요')),
                      ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visible.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 76,
                          ),
                      itemBuilder: (_, i) {
                        final item = visible[i];
                        // 필터 중에도 전체 목록 기준 위치로 삭제한다.
                        void onDelete() => _delete(items.indexOf(item));
                        // 카드를 옆으로 밀어서도 소진(삭제) 처리할 수 있다.
                        // 선택 모드에서는 실수로 지워지지 않도록 스와이프를 끈다.
                        return Dismissible(
                          key: ObjectKey(item),
                          direction: fridge.isSelecting
                              ? DismissDirection.none
                              : DismissDirection.horizontal,
                          onDismissed: (_) => onDelete(),
                          background: const _SwipeBackground(
                            Alignment.centerLeft,
                          ),
                          secondaryBackground: const _SwipeBackground(
                            Alignment.centerRight,
                          ),
                          child: GestureDetector(
                            onTap: fridge.isSelecting
                                ? () => fridge.toggleSelected(item)
                                : null,
                            child: _IngredientCard(
                              item: item,
                              selecting: fridge.isSelecting,
                              selected: fridge.isSelected(item),
                              onDelete: onDelete,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('식재료 수동 추가'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () => vm.changeTab(2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '남은 재료로 AI 추천 레시피',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(
                          child: _RecipePreviewCard(
                            title: '김치볶음밥',
                            emoji: '🍚',
                            deco: ['🥕', '🧅', '🥚'],
                            ingredients: ['당근', '양파'],
                            time: '15분',
                            level: '쉬움',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _RecipePreviewCard(
                            title: '닭볶음탕',
                            emoji: '🍲',
                            deco: ['🍗', '🥔', '🌶️'],
                            ingredients: ['닭고기', '감자'],
                            time: '25분',
                            level: '보통',
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
      ),
    );
  }
}

/// 재료 선택 모드에서 위에 보이는 "N개 선택됨" 바.
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.count,
    required this.onCancel,
    required this.onConfirm,
  });

  final int count;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count개 선택됨',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          TextButton(onPressed: onCancel, child: const Text('취소')),
          FilledButton(
            onPressed: count == 0 ? null : onConfirm,
            child: const Text('AI 레시피 만들기'),
          ),
        ],
      ),
    );
  }
}

class _ScanBanner extends StatelessWidget {
  const _ScanBanner({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '영수증 한 장으로 끝내는\n냉장고 관리!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onScan,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('영수증 스캔'),
                ),
              ],
            ),
          ),
          Icon(
            Icons.receipt_long,
            size: 64,
            color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

/// 카드를 밀 때 뒤에 보이는 삭제 배경.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground(this.alignment);

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({
    required this.item,
    required this.selecting,
    required this.selected,
    required this.onDelete,
  });

  final Ingredient item;

  /// Whether the fridge is in picking mode, which swaps the delete button
  /// for a check mark.
  final bool selecting;

  /// Whether [item] is picked for a recipe.
  final bool selected;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // 임박도에 따라 색을 구분한다: 3일 이하 빨강, 7일 이하 주황, 그 외 초록
    final Color color = item.expiryDays <= 3
        ? Colors.red
        : item.expiryDays <= 7
        ? Colors.orange
        : Colors.green;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: selected
            ? Border.all(color: theme.colorScheme.primary, width: 2.5)
            : Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.name} (${item.quantity}${item.unit})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: '${item.storage} - ',
                    children: [
                      TextSpan(
                        text: 'D-${item.expiryDays}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (selecting)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: theme.colorScheme.primary,
              ),
            )
          else ...[
            if (item.expiryDays <= 3) Icon(Icons.error, size: 18, color: color),
            IconButton(
              tooltip: '삭제',
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              icon: const Icon(Icons.close),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipePreviewCard extends StatelessWidget {
  const _RecipePreviewCard({
    required this.title,
    required this.emoji,
    required this.deco,
    required this.ingredients,
    required this.time,
    required this.level,
  });

  final String title;
  final String emoji;
  final List<String> deco; // 배경에 흩뿌릴 재료 이모지 3개
  final List<String> ingredients;
  final String time;
  final String level;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    Widget badge(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.primary),
        const SizedBox(width: 3),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primaryContainer, scheme.tertiaryContainer],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 12,
                  top: 8,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Opacity(
                      opacity: 0.5,
                      child: Text(
                        deco[0],
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 12,
                  child: Transform.rotate(
                    angle: 0.35,
                    child: Opacity(
                      opacity: 0.5,
                      child: Text(
                        deco[1],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 6,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Opacity(
                      opacity: 0.5,
                      child: Text(
                        deco[2],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Text(emoji, style: const TextStyle(fontSize: 52)),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '✨ AI 추천',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final i in ingredients)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(i, style: theme.textTheme.labelSmall),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    badge(Icons.schedule, time),
                    const SizedBox(width: 10),
                    badge(Icons.local_fire_department_outlined, level),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
