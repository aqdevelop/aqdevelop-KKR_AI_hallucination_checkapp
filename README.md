# AI 할루시네이션 검증 앱

> AI가 쓴 글을 붙여넣으면, 사실 주장을 인터넷에서 교차검증해 "할루시네이션
> 의심 구간"을 색칠하고, 진짜 정보로 대체 제안까지 해주는 Flutter 앱.

기획 배경은 [`PLANNING.md`](./PLANNING.md) 참고.

## 구성

```
.
├── PLANNING.md         # 5루프 기획 문서
├── FLUTTER_GUIDE.md    # Flutter 입문 가이드
├── app/                # Flutter 앱 (모바일 우선)
└── backend/            # FastAPI 백엔드 (Cloud Run 배포 가정)
```

## 가장 빠른 시작 (둘 다 목 모드)

```bash
# 1) 백엔드
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --port 8080

# 2) 다른 터미널에서 앱
cd app
flutter pub get
flutter run                 # 기본 USE_MOCK=true → 백엔드 없이도 동작
```

## 실제 모드로 가기

1. `backend/.env`에 `MOCK_MODE=false` + Anthropic + Brave 키 입력
2. 앱은 `--dart-define=USE_MOCK=false --dart-define=API_BASE_URL=...` 로 실행

## 결정된 기술 선택 (기획 결정 5)

| 항목 | 결정 |
|---|---|
| 백엔드 | Python (FastAPI) |
| 검색 | Brave Search 메인, Google CSE 한국어 폴백 |
| 출시 형태 | 모바일 앱 (안드로이드 우선) |
| 수익 모델 | v1 무료, v1.x에서 유료 기능 |
| 인력 | 1인 + AI |

## 현재 진행 상황 (W1~W2)

- ✅ Flutter: 입력 화면, 결과 화면(색깔 하이라이트), 바텀 시트 상세, Riverpod, 목 API
- ✅ Backend: 추출/검색/검증/교정 파이프라인, 신뢰도 가중치, 캐시, 목 모드, Anthropic/Brave 어댑터
- ⏳ 다음 (W3~): 진행률 4단계 화면, 검사 기록 저장, 공유 시트 통합, 한국어 평가셋 200개
