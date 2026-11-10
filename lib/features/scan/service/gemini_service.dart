import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../fridge/model/ingredient.dart';

class GeminiException implements Exception {
  GeminiException(this.message);
  final String message;

  @override
  String toString() => 'GeminiException: $message';
}

class GeminiService {
  GeminiService({String? apiKey, http.Client? client})
      : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
        _client = client ?? http.Client();

  // 실행 시: flutter run -d chrome --dart-define=GEMINI_API_KEY=AIza...
  // (키를 소스코드에 직접 넣거나 커밋하지 마세요)
  final String _apiKey;
  final http.Client _client;

  bool get hasApiKey => _apiKey.isNotEmpty;

  static const _model = 'gemini-3.8-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const systemPrompt = '''
너는 한국 마트 영수증 텍스트에서 "식재료"만 추출하는 파서다.

[출력 형식]
반드시 아래 JSON 객체 하나만 출력한다. 설명, 마크다운, 코드블록은 절대 포함하지 않는다.
{"items":[{"name":"식재료명","quantity":정수,"unit":"단위","expiry_days":정수,"category":"분류"}]}

[규칙]
1. 식재료(채소, 과일, 육류, 수산물, 유제품, 계란, 두부, 가공식품 등)만 포함한다. 봉투, 할인, 포인트, 세금, 합계, 비식품(세제, 휴지 등)은 제외한다.
2. name은 브랜드·용량·행사 표기를 제거한 일반적인 식재료명으로 정규화한다. (예: "CJ 햇반 210g*3" -> "햇반")
3. [중요] 수량이 명확하지 않은 식재료는 1봉, 1단, 1팩 등으로 유연하게 단위를 지정할 것. (예: 대파 -> 1단, 시금치 -> 1봉, 삼겹살 -> 1팩). 수량이 명확하면 그 값을 쓰고 개, 병, 캔, 마리, 모 등 적절한 단위를 쓴다.
4. quantity는 1 이상의 정수다.
5. expiry_days는 구매일 기준 냉장 보관 시 일반적인 남은 유통기한을 일 단위 정수로 추정한다. (예: 우유 7, 두부 10, 상추 5, 계란 21)
6. 같은 식재료가 중복되면 수량을 합친다.
7. category는 반드시 다음 중 하나만 쓴다: 채소, 과일, 육류, 수산물, 유제품, 달걀·두부, 가공식품, 기타. 애매하면 기타.
8. 식재료가 없으면 {"items":[]}을 출력한다.
''';

  /// 영수증 원본 텍스트 -> Ingredient 리스트
  Future<List<Ingredient>> parseReceipt(String receiptText) async {
    if (_apiKey.isEmpty) {
      throw GeminiException(
        'GEMINI_API_KEY가 설정되지 않았습니다. '
        '--dart-define=GEMINI_API_KEY=... 로 실행하세요.',
      );
    }

    final requestBody = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': receiptText},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0,
        'responseMimeType': 'application/json',
      },
    });

    // 서버가 일시적으로 바쁠 때(503)나 한도 초과(429)는 잠시 후 재시도한다.
    const maxAttempts = 3;
    late http.Response res;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        res = await _client
            .post(
              Uri.parse(_endpoint),
              headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'x-goog-api-key': _apiKey,
              },
              body: requestBody,
            )
            .timeout(const Duration(seconds: 60));
      } on TimeoutException {
        if (attempt == maxAttempts) {
          throw GeminiException('응답 시간 초과: 서버가 바쁜 것 같아요. 잠시 후 다시 시도해 주세요.');
        }
        continue;
      } catch (e) {
        throw GeminiException('네트워크 오류: $e');
      }
      // 429(한도 초과)는 재시도해도 한도만 더 소모하므로 503만 재시도한다.
      final retryable = res.statusCode == 503;
      if (!retryable || attempt == maxAttempts) break;
      await Future<void>.delayed(Duration(seconds: 2 * attempt));
    }

    final body = utf8.decode(res.bodyBytes);
    if (res.statusCode != 200) {
      if (res.statusCode == 429) {
        throw GeminiException(
          'AI 무료 사용량을 모두 썼어요. 잠시 후(최대 하루) 다시 시도하거나, '
          '다른 모델/API 키를 사용해 주세요.',
        );
      }
      throw GeminiException('API 오류 (${res.statusCode}): $body');
    }

    try {
      final content = jsonDecode(body)['candidates'][0]['content']['parts'][0]
          ['text'] as String;
      final parsed = jsonDecode(content);
      final list = (parsed is Map ? parsed['items'] : parsed) as List;
      return list
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .where((i) => i.name.isNotEmpty)
          .toList();
    } catch (e) {
      throw GeminiException('응답 파싱 실패: $e');
    }
  }
}
