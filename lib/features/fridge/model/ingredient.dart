import 'food_category.dart';

class Ingredient {
  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.expiryDays,
    this.storage = '냉장',
    this.category = FoodCategory.etc,
  });

  final String name;

  /// 보관 방식: 냉장 / 냉동 / 실온
  final String storage;

  /// 분류: [FoodCategory.all] 중 하나
  final String category;
  int quantity;
  final String unit;

  /// 등록일 기준 남은 유통기한(일)
  final int expiryDays;

  /// 카드에 보여줄 이모지 (분류별로 통일)
  String get emoji => FoodCategory.emojiOf(category);

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    int toInt(Object? v, int fallback) =>
        v is num ? v.round() : int.tryParse('$v') ?? fallback;

    final qty = toInt(json['quantity'], 1);
    return Ingredient(
      name: (json['name'] ?? '').toString().trim(),
      quantity: qty < 1 ? 1 : qty,
      unit: (json['unit'] ?? '개').toString().trim(),
      expiryDays: toInt(json['expiry_days'], 7),
      category: FoodCategory.normalize(json['category']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'expiry_days': expiryDays,
        'storage': storage,
        'category': category,
      };
}
