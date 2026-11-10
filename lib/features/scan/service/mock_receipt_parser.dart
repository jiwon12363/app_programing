import '../../fridge/model/food_category.dart';
import '../../fridge/model/ingredient.dart';

/// API 없이 시연하기 위한 로컬 영수증 파서.
/// 키워드 사전으로 식재료를 찾고, 수량이 안 보이면 1봉/1단/1팩 등 기본 단위를 쓴다.
class MockReceiptParser {
  const MockReceiptParser();

  // 키워드: (표시 이름, 기본 단위, 유통기한 일수, 보관, 분류)
  static const _dict = <String, (String, String, int, String, String)>{
    '우유': ('우유', '팩', 7, '냉장', FoodCategory.dairy),
    '요거트': ('요거트', '개', 10, '냉장', FoodCategory.dairy),
    '치즈': ('치즈', '봉', 20, '냉장', FoodCategory.dairy),
    '대파': ('대파', '단', 7, '냉장', FoodCategory.vegetable),
    '쪽파': ('쪽파', '단', 5, '냉장', FoodCategory.vegetable),
    '시금치': ('시금치', '봉', 4, '냉장', FoodCategory.vegetable),
    '상추': ('상추', '봉', 5, '냉장', FoodCategory.vegetable),
    '깻잎': ('깻잎', '봉', 5, '냉장', FoodCategory.vegetable),
    '양파': ('양파', '개', 21, '실온', FoodCategory.vegetable),
    '감자': ('감자', '개', 30, '실온', FoodCategory.vegetable),
    '고구마': ('고구마', '개', 30, '실온', FoodCategory.vegetable),
    '당근': ('당근', '개', 14, '냉장', FoodCategory.vegetable),
    '오이': ('오이', '개', 7, '냉장', FoodCategory.vegetable),
    '애호박': ('애호박', '개', 7, '냉장', FoodCategory.vegetable),
    '버섯': ('버섯', '봉', 5, '냉장', FoodCategory.vegetable),
    '마늘': ('마늘', '봉', 30, '냉장', FoodCategory.vegetable),
    '아보카도': ('아보카도', '개', 5, '실온', FoodCategory.fruit),
    '사과': ('사과', '개', 14, '냉장', FoodCategory.fruit),
    '바나나': ('바나나', '송이', 5, '실온', FoodCategory.fruit),
    '토마토': ('토마토', '팩', 7, '냉장', FoodCategory.fruit),
    '삼겹살': ('삼겹살', '팩', 3, '냉장', FoodCategory.meat),
    '돼지고기': ('돼지고기', '팩', 3, '냉장', FoodCategory.meat),
    '소고기': ('소고기', '팩', 3, '냉장', FoodCategory.meat),
    '닭': ('닭고기', '팩', 3, '냉장', FoodCategory.meat),
    '고등어': ('고등어', '마리', 2, '냉장', FoodCategory.seafood),
    '새우': ('새우', '봉', 2, '냉동', FoodCategory.seafood),
    '두부': ('두부', '모', 10, '냉장', FoodCategory.eggTofu),
    '계란': ('계란', '개', 21, '냉장', FoodCategory.eggTofu),
    '달걀': ('계란', '개', 21, '냉장', FoodCategory.eggTofu),
    '김치': ('김치', '봉', 30, '냉장', FoodCategory.processed),
  };

  static final _qty = RegExp(r'(\d+)\s*(개|병|캔|봉|팩|단|모|구|마리|송이)');

  Future<List<Ingredient>> parseReceipt(String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 800)); // 분석 중 연출
    final merged = <String, Ingredient>{};

    for (final line in text.split('\n')) {
      for (final entry in _dict.entries) {
        if (!line.contains(entry.key)) continue;
        final (name, defaultUnit, days, storage, category) = entry.value;
        final m = _qty.firstMatch(line);
        final qty = m != null ? int.parse(m.group(1)!) : 1;
        final unit = m != null ? m.group(2)! : defaultUnit;

        final existing = merged[name];
        if (existing != null) {
          existing.quantity += qty;
        } else {
          merged[name] = Ingredient(
            name: name,
            quantity: qty < 1 ? 1 : qty,
            unit: unit,
            expiryDays: days,
            storage: storage,
            category: category,
          );
        }
        break; // 한 줄에서 하나의 식재료만 인식
      }
    }
    return merged.values.toList();
  }
}
