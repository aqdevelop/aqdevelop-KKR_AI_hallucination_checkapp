# 플러터(Flutter) 완전 입문 가이드

> "아무것도 모르는 사람"을 위한 첫 앱 만들기까지의 길잡이

---

## 0. 플러터가 뭔데?

- **Flutter**는 구글이 만든 앱 개발 프레임워크입니다.
- **한 번 코드를 짜면** Android, iOS, 웹, Windows, Mac, Linux 앱으로 모두 돌릴 수 있어요.
- 사용하는 언어는 **Dart**(다트). 자바스크립트나 자바를 해봤다면 금방 익숙해집니다.

---

## 1. 설치하기 (가장 큰 산)

### 1-1. Flutter SDK 설치

운영체제별로 다릅니다. 공식 사이트가 가장 정확해요.

- 공식 설치 가이드: https://docs.flutter.dev/get-started/install

**macOS / Linux**
```bash
# 원하는 폴더로 이동 후
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```
`~/.zshrc` 또는 `~/.bashrc` 에 PATH를 추가해야 매번 안 쳐도 됩니다.

**Windows**
- 공식 사이트에서 zip 다운로드 → 원하는 폴더에 압축 해제 → 환경변수 PATH 추가.

### 1-2. 설치 확인

```bash
flutter doctor
```

이 명령이 핵심입니다. 부족한 게 있으면 ❌로 알려줍니다. 필요한 것:

- ✅ **Flutter SDK**
- ✅ **Android Studio** (안드로이드 앱 빌드용)
- ✅ **Xcode** (Mac에서 iOS 앱 빌드 시)
- ✅ **VS Code** 또는 **Android Studio** (코드 에디터)

### 1-3. 에디터 추천

처음이면 **VS Code**가 가볍고 좋습니다.
- VS Code 설치 → 확장(Extensions)에서 **Flutter** 검색해서 설치 (Dart도 자동 설치됨).

---

## 2. 첫 프로젝트 만들기

```bash
flutter create my_first_app
cd my_first_app
flutter run
```

- `flutter create`는 기본 템플릿(카운터 앱)을 만들어줍니다.
- `flutter run`은 연결된 기기/시뮬레이터에서 실행해요.
- 시뮬레이터가 없으면 **Chrome**으로 띄울 수도 있습니다: `flutter run -d chrome`

### 핵심 폴더 구조

```
my_first_app/
├── lib/
│   └── main.dart      ← 여기서부터 시작!
├── android/           ← 안드로이드 빌드 설정
├── ios/               ← iOS 빌드 설정
├── pubspec.yaml       ← 패키지(라이브러리) 목록
└── test/              ← 테스트 코드
```

**99%의 시간은 `lib/` 안에서 작업**합니다.

---

## 3. Dart 언어 빛의 속도 입문

```dart
// 변수
var name = '철수';        // 자동 타입 추론
String city = '서울';     // 명시적 타입
int age = 20;
bool isStudent = true;

// 함수
int add(int a, int b) {
  return a + b;
}

// 화살표 함수
int multiply(int a, int b) => a * b;

// 클래스
class Person {
  String name;
  int age;
  Person(this.name, this.age);
}

// 사용
final p = Person('영희', 25);
print(p.name);
```

이 정도만 알면 일단 시작할 수 있어요.

---

## 4. 플러터의 기본 개념 — "모든 것은 위젯(Widget)"

플러터에서 화면에 보이는 모든 것은 **위젯**입니다. 버튼도, 텍스트도, 화면 전체도.

### 가장 자주 쓰는 위젯

| 위젯 | 용도 |
|------|------|
| `Text` | 글자 표시 |
| `Container` | 박스 (CSS의 div 같은 것) |
| `Row` | 가로 배치 |
| `Column` | 세로 배치 |
| `Image` | 이미지 |
| `ElevatedButton` | 버튼 |
| `Scaffold` | 앱 화면의 기본 틀 (앱바, 본문, 하단바 등) |
| `AppBar` | 상단 바 |

### 예시: "안녕 세상" 앱

`lib/main.dart`를 통째로 다음으로 바꾸세요.

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('내 첫 앱')),
        body: const Center(
          child: Text(
            '안녕, 세상!',
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}
```

저장하면 **핫 리로드(Hot Reload)**로 즉시 반영됩니다 (`r` 키 또는 저장).

---

## 5. 상태(State) 다루기 — 버튼 누르면 숫자 올라가기

화면이 바뀌어야 하면 `StatefulWidget`을 씁니다.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CounterPage());
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카운터')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$count', style: const TextStyle(fontSize: 64)),
            ElevatedButton(
              onPressed: () => setState(() => count++),
              child: const Text('+1'),
            ),
          ],
        ),
      ),
    );
  }
}
```

핵심:
- 화면을 바꾸려면 **`setState(() { ... })`** 안에서 값을 바꿔야 합니다.
- 그래야 플러터가 화면을 다시 그려요.

---

## 6. 패키지(라이브러리) 추가하기

`pubspec.yaml`에 추가하거나 명령어로:

```bash
flutter pub add http     # 네트워크 통신
flutter pub add provider # 상태 관리
```

추천 사이트: https://pub.dev (npm/pip 같은 저장소)

---

## 7. 학습 로드맵 (순서대로)

1. **Dart 기초** — 변수, 함수, 클래스, async/await
2. **위젯 기본기** — Text, Container, Row, Column, Stack
3. **레이아웃** — Padding, Expanded, Flexible, SizedBox
4. **StatefulWidget & setState**
5. **화면 이동** — `Navigator.push`, `Navigator.pop`
6. **사용자 입력** — `TextField`, `Form`
7. **리스트** — `ListView.builder`
8. **네트워크** — `http` 패키지로 API 호출
9. **상태 관리 라이브러리** — Provider → Riverpod 또는 Bloc
10. **로컬 저장소** — `shared_preferences`, `sqflite`
11. **빌드 & 배포** — Play Store, App Store

---

## 8. 막힐 때 보는 곳

- 📘 **공식 문서**: https://docs.flutter.dev
- 🎬 **유튜브**: "Flutter Korea", "코딩셰프", "Flutter 공식 채널"
- 💬 **커뮤니티**: https://flutter-ko.dev (한국 플러터 커뮤니티)
- 🧑‍🍳 **샘플 코드**: https://github.com/flutter/samples
- 🤖 **AI 활용**: 에러 메시지 그대로 복사해서 ChatGPT/Claude한테 물어보기 (진짜 잘 알려줍니다)

---

## 9. 처음에 자주 만나는 에러

| 에러 | 해결 |
|------|------|
| `flutter: command not found` | PATH 설정 안 됨. `flutter doctor` 확인 |
| `No connected devices` | 시뮬레이터 켜거나 `-d chrome` 옵션 사용 |
| `Gradle build failed` | Android Studio에서 SDK 라이선스 동의: `flutter doctor --android-licenses` |
| `setState() called after dispose()` | 화면이 사라진 뒤 setState 호출. `if (mounted)` 체크 추가 |

---

## 10. 첫 주 추천 과제

1. **카운터 앱** 색깔/폰트 바꿔보기
2. **할 일(TODO) 앱** 만들기 — 입력하고 리스트에 추가
3. **계산기 앱** 만들기 — 버튼 그리드 연습
4. **날씨 앱** 만들기 — 무료 날씨 API 호출

이 4개만 직접 쳐보면 감이 옵니다.

---

## 마지막 한 마디

**복붙 → 실행 → 망가뜨려보기 → 고치기**

이 사이클을 반복하는 게 책 한 권 읽는 것보다 빠릅니다.
모르는 단어가 나와도 일단 따라 쳐보고, 실행되면 한 줄씩 바꿔보세요.

화이팅! 🚀
