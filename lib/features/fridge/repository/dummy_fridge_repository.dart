import '../model/food_category.dart';
import '../model/ingredient.dart';
import 'fridge_repository.dart';

/// Keeps ingredients in memory, starting with a few samples.
///
/// Data is lost when the app closes. Replaced by a Firestore repository later.
class DummyFridgeRepository implements FridgeRepository {
  final List<Ingredient> _items = [
    Ingredient(
      name: '당근',
      quantity: 3,
      unit: '개',
      expiryDays: 14,
      category: FoodCategory.vegetable,
    ),
    Ingredient(
      name: '햇감자',
      quantity: 4,
      unit: '개',
      expiryDays: 30,
      storage: '실온',
      category: FoodCategory.vegetable,
    ),
    Ingredient(
      name: '우유',
      quantity: 1,
      unit: 'L',
      expiryDays: 2,
      category: FoodCategory.dairy,
    ),
    Ingredient(
      name: '닭고기',
      quantity: 600,
      unit: 'g',
      expiryDays: 5,
      storage: '냉동',
      category: FoodCategory.meat,
    ),
    Ingredient(
      name: '돼지고기',
      quantity: 1,
      unit: '팩',
      expiryDays: 3,
      category: FoodCategory.meat,
    ),
    Ingredient(
      name: '아보카도',
      quantity: 2,
      unit: '개',
      expiryDays: 21,
      storage: '실온',
      category: FoodCategory.fruit,
    ),
  ];

  @override
  Future<List<Ingredient>> fetchAll() async => List.of(_items);

  @override
  Future<void> add(Ingredient item) async {
    _items.add(item);
  }

  @override
  Future<void> addAll(Iterable<Ingredient> items) async {
    _items.addAll(items);
  }

  @override
  Future<void> remove(Ingredient item) async {
    _items.remove(item);
  }
}
