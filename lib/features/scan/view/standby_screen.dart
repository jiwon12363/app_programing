import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../fridge/model/ingredient.dart';
import '../../fridge/viewmodel/fridge_viewmodel.dart';
import '../../main/viewmodel/main_viewmodel.dart';
import '../service/gemini_service.dart';
import '../service/mock_receipt_parser.dart';

/// 영수증 텍스트를 AI로 분석한 뒤, 냉장고에 넣기 전 확인/수정하는 대기 화면.
/// [initialItems]를 주면 AI 호출 없이 바로 표시한다. (테스트/미리보기용)
class StandbyScreen extends StatefulWidget {
  const StandbyScreen({super.key, this.receiptText, this.initialItems})
      : assert(receiptText != null || initialItems != null);

  final String? receiptText;
  final List<Ingredient>? initialItems;

  @override
  State<StandbyScreen> createState() => _StandbyScreenState();
}

class _StandbyScreenState extends State<StandbyScreen> {
  List<Ingredient> _items = [];
  bool _loading = true;
  bool _usingSample = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.initialItems != null) {
      setState(() {
        _items = List.of(widget.initialItems!);
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = GeminiService();
      if (!service.hasApiKey) {
        // API 키가 없으면 데모 모드: 로컬 키워드 파서로 영수증을 분석한다.
        final items =
            await const MockReceiptParser().parseReceipt(widget.receiptText!);
        if (!mounted) return;
        setState(() {
          _usingSample = true;
          _items = items;
          _loading = false;
        });
        return;
      }
      final items = await service.parseReceipt(widget.receiptText!);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _saveToFirestore() {
    // TODO: Firebase 연동 후 실제 Firestore 저장으로 교체
    final data = _items.map((e) => e.toJson()).toList();
    print('Firestore에 저장 완료: $data');
    // 시연용: 메모리의 냉장고 목록에 추가하고 내 냉장고 탭으로 이동한다.
    context.read<FridgeViewModel>().addAll(_items);
    context.read<MainViewModel>().changeTab(0);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).maybePop();
    messenger.showSnackBar(
      SnackBar(content: Text('${_items.length}개 식재료를 냉장고에 넣었어요')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('등록 대기')),
      body: _buildBody(),
      bottomNavigationBar: _items.isEmpty || _loading
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _saveToFirestore,
                child: const Text(
                  '✅ 이대로 내 냉장고에 넣기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI가 영수증을 분석하고 있어요...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('등록할 식재료가 없어요'));
    }
    return Column(
      children: [
        if (_usingSample)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.tertiaryContainer,
            padding: const EdgeInsets.all(12),
            child: const Text(
              '데모 모드: API 없이 기기에서 영수증을 분석했어요.',
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = _items[i];
              return _IngredientTile(
                key: ObjectKey(item),
                item: item,
                onChanged: () => setState(() {}),
                onDelete: () => setState(() => _items.removeAt(i)),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  final Ingredient item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
        child: Row(
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleMedium),
                  Text(
                    '유통기한 ${item.expiryDays}일 남음',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: '수량 감소',
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: item.quantity > 1
                  ? () {
                      item.quantity--;
                      onChanged();
                    }
                  : null,
            ),
            Text(
              '${item.quantity}${item.unit}',
              style: theme.textTheme.titleSmall,
            ),
            IconButton(
              tooltip: '수량 증가',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                item.quantity++;
                onChanged();
              },
            ),
            IconButton(
              tooltip: '삭제',
              icon: const Icon(Icons.close),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

