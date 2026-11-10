import 'package:flutter/foundation.dart';

import '../model/food_category.dart';
import '../model/ingredient.dart';

/// 냉장고 식재료 목록을 관리한다.
/// TODO: Firestore 연동 시 이 클래스의 저장/삭제를 Firestore 호출로 교체
class FridgeViewModel extends ChangeNotifier {
  final List<Ingredient> _items = [
    Ingredient(name: '당근', quantity: 3, unit: '개', expiryDays: 14, category: FoodCategory.vegetable),
    Ingredient(name: '햇감자', quantity: 4, unit: '개', expiryDays: 30, storage: '실온', category: FoodCategory.vegetable),
    Ingredient(name: '우유', quantity: 1, unit: 'L', expiryDays: 2, category: FoodCategory.dairy),
    Ingredient(name: '닭고기', quantity: 600, unit: 'g', expiryDays: 5, storage: '냉동', category: FoodCategory.meat),
    Ingredient(name: '돼지고기', quantity: 1, unit: '팩', expiryDays: 3, category: FoodCategory.meat),
    Ingredient(name: '아보카도', quantity: 2, unit: '개', expiryDays: 21, storage: '실온', category: FoodCategory.fruit),
  ];

  List<Ingredient> get items => List.unmodifiable(_items);

  void add(Ingredient item) {
    _items.add(item);
    notifyListeners();
  }

  void addAll(Iterable<Ingredient> items) {
    _items.addAll(items);
    notifyListeners();
  }

  Ingredient removeAt(int index) {
    final removed = _items.removeAt(index);
    notifyListeners();
    return removed;
  }

  void insert(int index, Ingredient item) {
    _items.insert(index.clamp(0, _items.length), item);
    notifyListeners();
  }
}
