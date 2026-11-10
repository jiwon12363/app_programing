/// 식재료 분류. 이름별 이모지가 없을 때 분류 이모지를 대신 보여준다.
class FoodCategory {
  FoodCategory._();

  static const vegetable = '채소';
  static const fruit = '과일';
  static const meat = '육류';
  static const seafood = '수산물';
  static const dairy = '유제품';
  static const eggTofu = '달걀·두부';
  static const processed = '가공식품';
  static const etc = '기타';

  static const all = [
    vegetable,
    fruit,
    meat,
    seafood,
    dairy,
    eggTofu,
    processed,
    etc,
  ];

  static const _categoryEmoji = {
    vegetable: '🥬',
    fruit: '🍎',
    meat: '🥩',
    seafood: '🐟',
    dairy: '🥛',
    eggTofu: '🥚',
    processed: '🥫',
    etc: '🍽️',
  };

  /// 알 수 없는 분류(AI가 엉뚱한 값을 줄 때)는 '기타'로 정리한다.
  static String normalize(String? value) {
    final v = value?.trim() ?? '';
    return all.contains(v) ? v : etc;
  }

  /// 분류별 대표 이모지. 같은 분류는 항상 같은 이모지를 쓴다.
  static String emojiOf(String category) =>
      _categoryEmoji[category] ?? _categoryEmoji[etc]!;
}
