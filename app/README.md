# Flutter 앱 — AI 할루시네이션 검증

## 빠른 실행 (목 데이터, 백엔드 없음)

```bash
cd app
flutter pub get
flutter run                 # 기본: USE_MOCK=true → 백엔드 없이 동작
```

## 실제 백엔드 연결

먼저 [`backend/`](../backend/README.md) 를 띄운 뒤:

```bash
# 안드로이드 에뮬레이터
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://10.0.2.2:8080

# iOS 시뮬레이터 / 데스크톱 / 웹
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://localhost:8080
```

## 폴더 구조

```
lib/
├── main.dart
├── core/theme.dart
├── data/
│   ├── models/models.dart            # Claim, Source, Summary, Span, FactCheckResult
│   └── api/
│       ├── factcheck_api.dart        # dio 기반 실제 API
│       └── mock_api.dart             # 백엔드 없이 시연용
├── state/providers.dart              # Riverpod 컨트롤러
├── features/
│   ├── input/input_screen.dart       # 입력 화면
│   └── result/
│       ├── result_screen.dart        # 색깔 하이라이트 결과
│       └── claim_detail_sheet.dart   # 바텀 시트 상세
└── widgets/highlighted_text.dart     # 색깔 하이라이트 위젯
```

## 다음 작업 (W3~)

- 진행률 화면(extract → search → verify → correct 4단계)
- 검사 기록(SharedPreferences)
- 공유 시트로 받은 텍스트 → 자동 검사
- 클립보드 감지 배너
