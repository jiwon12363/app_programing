import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      context.read<FridgeViewModel>().add(Ingredient(
            name: name.text.trim(),
            quantity: int.tryParse(qty.text) ?? 1,
            unit: unit.text.trim().isEmpty ? '개' : unit.text.trim(),
            expiryDays: int.tryParse(days.text) ?? 7,
            category: category,
          ));
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
    final items = context.watch<FridgeViewModel>().items;
    // 선택한 분류에 항목이 하나도 없어지면(삭제 등) 전체로 되돌린다.
    final filter = items.any((e) => e.category == _filter) ? _filter : _all;
    final visible = filter == _all
        ? items
        : items.where((e) => e.category == filter).toList();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // 상단 타이틀 + 알림
            Row(
              children: [
                Expanded(
                  child: Text(
                    'AI 냉장고 파먹기',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
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
            Text(
              '내 냉장고 현황',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
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
                          onSelected: (_) => setState(() => _filter = c),
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 76,
              ),
              itemBuilder: (_, i) => _IngredientCard(
                item: visible[i],
                // 필터 중에도 전체 목록 기준 위치로 삭제한다.
                onDelete: () => _delete(items.indexOf(visible[i])),
              ),
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
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                    tags: '#당근, #양파 활용',
                    meta: '15분 | 쉬움',
                    icon: Icons.rice_bowl,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _RecipePreviewCard(
                    title: '닭볶음탕',
                    tags: '#닭고기, #감자 활용',
                    meta: '25분 | 보통',
                    icon: Icons.soup_kitchen,
                  ),
                ),
              ],
            ),
          ],
        ),
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

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.item, required this.onDelete});

  final Ingredient item;
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
        border: Border.all(color: color.withValues(alpha: 0.5)),
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
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
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
          if (item.expiryDays <= 3)
            Icon(Icons.error, size: 18, color: color),
          IconButton(
            tooltip: '삭제',
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            icon: const Icon(Icons.close),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _RecipePreviewCard extends StatelessWidget {
  const _RecipePreviewCard({
    required this.title,
    required this.tags,
    required this.meta,
    required this.icon,
  });

  final String title;
  final String tags;
  final String meta;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: double.infinity,
            color: scheme.secondaryContainer,
            child: Icon(icon, size: 40, color: scheme.onSecondaryContainer),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(tags, style: theme.textTheme.bodySmall),
                Text(meta, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
