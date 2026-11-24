---
name: effective-dart
description: Dart/Flutter 코드를 작성, 수정, 리뷰, 리팩터링할 때 반드시 적용하는 Effective Dart 가이드(https://dart.dev/effective-dart). .dart 파일, Flutter 위젯, pubspec, 상태관리 코드 등 Dart 코드를 다루는 모든 작업에서 사용한다. 적용되면 채팅창에 적용 표시를 남긴다.
---

# Effective Dart 적용 스킬

Dart/Flutter 코드를 작성하거나 고칠 때 아래 규칙을 따른다. 출처: https://dart.dev/effective-dart (style, documentation, usage, design).

## 적용 표시 (필수)

이 스킬을 적용해 Dart 코드를 작성/수정/리뷰했다면, 답변에서 AGENTS.md의 "(이해도 n%)" 바로 다음 줄에 아래 표시를 넣는다.

```
📘 [Effective Dart 적용됨] style · documentation · usage · design
```

- 실제로 참고한 영역만 남겨도 된다. (예: `style · usage`)
- 규칙 때문에 코드를 바꾼 곳이 있으면 답변 끝에 "Effective Dart 반영" 항목으로 한두 줄 요약한다. (예: `late` 대신 생성자 초기화로 변경)
- Dart 코드를 전혀 건드리지 않은 답변에는 표시하지 않는다.
- 규칙을 의도적으로 어겼다면 이유를 같이 적는다.

## 1. Style

### 이름
- 타입/extension은 UpperCamelCase. 패키지/디렉터리/파일/import prefix는 lowercase_with_underscores. 그 외 식별자는 lowerCamelCase.
- 상수도 lowerCamelCase. (SCREAMING_CAPS는 기존 코드와 맞출 때만)
- 두 글자 넘는 약어는 단어처럼 쓴다: `Http`, `Uri`. 두 글자는 `ID`, `UI`처럼 대문자 유지.
- 안 쓰는 콜백 파라미터는 `_` (Dart 3.7+).
- private이 아닌데 `_`로 시작하지 않는다. `kDefaultTimeout` 같은 접두 글자 금지.
- 라이브러리에 이름 붙이지 않는다. (`library;`)

### 순서
- `dart:` → `package:` → 상대 경로 import 순, 그다음 export는 별도 구역. 각 구역은 알파벳순.

### 포맷
- `dart format` 사용. 한 줄 80자 이하 선호.
- 모든 제어문에 중괄호. (else 없는 한 줄 `if`만 예외)

## 2. Documentation

- 주석은 문장처럼: 대문자로 시작하고 마침표로 끝낸다.
- 문서화는 `///` 사용. 문서용으로 `/* */` 블록 주석 금지.
- public API에는 doc 주석을 쓴다. 첫 문장은 한 문장 요약이고 별도 문단으로 분리.
- 주변 문맥과 중복되는 내용은 피한다.
- 부수효과 함수는 3인칭 동사로 시작. 비불리언 변수/프로퍼티는 명사구, 불리언은 "Whether ..."로 시작.
- getter와 setter 둘 다 문서화하지 않는다. 한쪽만.
- 식별자 참조는 `[name]`. 파라미터/반환/예외는 산문으로 설명한다.
- doc 주석은 어노테이션보다 앞에 둔다.
- 마크다운과 HTML은 최소한으로. 코드 블록은 backtick fence.
- 간결하게. 자명하지 않은 약어는 피하고, 멤버 자기 자신은 "the"가 아니라 "this"로 가리킨다.

## 3. Usage

### 라이브러리
- `part of`에는 문자열 경로. 다른 패키지의 `src/` import 금지. import 경로가 `lib` 안팎을 넘나들지 않게 한다. 같은 패키지 안에서는 상대 경로 import 선호.

### Null
- 변수를 `null`로 명시 초기화하지 않는다. 기본값으로 `null`을 명시하지 않는다.
- `== true`/`== false` 비교 금지.
- 초기화 여부를 확인해야 하면 `late`를 피한다. 널러블은 타입 승격이나 null-check 패턴으로 쓴다.

### 문자열
- 리터럴 이어 붙이기는 인접 문자열로. 값 조합은 interpolation 선호. 불필요한 `${}` 중괄호는 피한다.

### 컬렉션
- 컬렉션 리터럴 사용. 비었는지는 `.length`가 아니라 `isEmpty`/`isNotEmpty`.
- `Iterable.forEach()`에 함수 리터럴 쓰지 말고 `for-in`. 
- 타입을 바꿀 목적이 아니면 `List.from()` 금지(`toList()`). 타입 필터는 `whereType()`. `cast()`는 피한다.

### 함수/변수
- 이름 붙은 함수는 함수 선언으로. 람다가 tear-off로 대체되면 tear-off 사용.
- 로컬 변수의 `var`/`final`은 일관된 규칙으로. 계산 가능한 값은 저장하지 않는다.

### 멤버/생성자
- 불필요한 getter/setter 래핑 금지. 읽기 전용은 `final` 필드. 단순 멤버는 `=>`.
- `this.`는 shadowing 회피와 named 생성자 리다이렉트에만. 선언 시점에 필드 초기화 가능하면 거기서.
- 생성자는 initializing formals(`this.x`), 빈 본문은 `;`, 간결한 생성자 문법. `new` 금지. 중복 `const` 금지.
- 생성자 initializer list로 되는 곳에 `late` 쓰지 않는다.

### 에러 처리
- `on` 없는 catch는 피하고, 에러를 삼키지 않는다. `Error` 구현체는 프로그래밍 오류에만 throw, 명시적으로 catch하지 않는다. 재throw는 `rethrow`.

### 비동기
- 원시 Future보다 async/await. 효과 없는 `async` 금지. 스트림 변환은 고차 메서드. `Completer` 직접 사용은 피한다. `FutureOr<Object>`는 `Future<T>`로 판별.

## 4. Design

### 이름
- 용어를 일관되게. 약어 피하기. 가장 설명적인 명사를 마지막에. 읽히는 코드처럼.
- 비불리언 프로퍼티는 명사구. 불리언은 비명령형 동사구이고 긍정형 이름을 쓴다. named 불리언 파라미터는 동사를 생략해도 된다.
- 부수효과 중심 함수는 명령형 동사구. 값 반환이 목적이면 명사구/비명령형 동사구. `get`으로 시작하지 않는다.
- 복사는 `toX()`, 같은 객체를 다른 표현으로 보여주면 `asX()`. 파라미터를 함수 이름에 풀어 쓰지 않는다. 타입 파라미터는 관례(E, K, V, T)를 따른다.

### 라이브러리/클래스
- 선언은 private 우선. 한 라이브러리에 여러 클래스 허용.
- 멤버 하나뿐인 추상 클래스는 함수로. static 멤버만 있는 클래스 금지.
- 상속/구현 의도 없는 클래스를 extend/implement 하지 않는다. 클래스 modifier로 의도를 표시. pure mixin이나 pure class를 mixin class보다 선호.
- 가능하면 생성자를 `const`로.

### 멤버
- 필드와 top-level 변수는 `final` 선호.
- 프로퍼티 접근은 getter, 변경은 setter. getter 없는 setter 금지.
- 런타임 타입 검사로 오버로딩 흉내 금지. initializer 없는 public `late final` 금지.
- 널러블 Future/Stream/컬렉션 반환 금지. 플루언트 용도로만 `this` 반환하지 않는다.

### 타입
- 초기화 없는 변수, 타입이 자명하지 않은 필드/top-level 변수에는 타입 표기. 초기화된 로컬 변수에는 중복 표기하지 않는다.
- 함수 선언의 반환/파라미터 타입은 표기. 함수 표현식의 추론 가능한 파라미터, initializing formal은 표기하지 않는다.
- 추론 안 되는 제네릭 호출은 타입 인자를 쓰고 추론되면 쓰지 않는다. 불완전한 제네릭 타입 금지.
- 추론 실패에 맡기지 말고 `dynamic`을 명시. 정적 검사를 꺼야 할 때만 `dynamic`.
- 함수 타입은 signature 방식. 인라인 함수 타입 선호, 레거시 typedef 금지. setter에 반환 타입 지정 금지.
- 값 없는 비동기 멤버는 `Future<void>`. `FutureOr<T>` 반환은 피한다.

### 파라미터
- positional bool 파라미터 금지. 앞 파라미터를 생략하고 싶을 수 있으면 optional positional 금지.
- "인자 없음"을 뜻하는 특수값을 받는 필수 파라미터 금지.
- 범위는 시작 포함, 끝 미포함.

### 동등성
- `==`를 오버라이드하면 `hashCode`도. `==`는 수학적 동등성 규칙을 지키고, 파라미터는 nullable로 만들지 않는다. 가변 클래스에 커스텀 동등성은 피한다.

## 작업 방식

1. Dart 코드를 쓰기 전에 위 규칙에 걸리는 부분이 있는지 확인한다.
2. 작성 후 가능하면 `dart format`과 `flutter analyze`로 검증한다. (실행하지 못했으면 못 했다고 말한다.)
3. 기존 코드가 규칙과 다르더라도 요청 범위 밖은 건드리지 않는다. 필요하면 제안만 한다.
4. 프로젝트의 `analysis_options.yaml`(flutter_lints 등)이 더 엄격하면 그 설정을 우선한다.
