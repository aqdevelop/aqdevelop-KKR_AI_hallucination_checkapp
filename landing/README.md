# FactLens — 랜딩 페이지

FactLens 서비스의 공개 랜딩 페이지. Next.js 14 (App Router) + TypeScript + Tailwind + Framer Motion.

## 빠르게 띄우기

```bash
cd landing
npm install
cp .env.local.example .env.local   # 필요 시 URL 수정
npm run dev
```

브라우저에서 http://localhost:3000 으로 접속.

## 환경변수

`.env.local`:

```
NEXT_PUBLIC_APP_URL=https://app.factlens.com     # 모든 "시작" 버튼이 가리키는 곳
NEXT_PUBLIC_SITE_URL=https://factlens.com        # OG 메타데이터용
```

로컬에서 Flutter 웹앱(`app/`)을 같이 띄워서 테스트하려면:

```
NEXT_PUBLIC_APP_URL=http://localhost:5000
```

## 구조

```
landing/
├── app/
│   ├── layout.tsx        # 폰트 (Noto Sans KR + Inter), 메타데이터
│   ├── page.tsx          # 섹션 조립
│   └── globals.css       # Tailwind + 디자인 토큰
├── components/
│   ├── navbar.tsx        # 고정 헤더, 스크롤 시 블러
│   ├── hero.tsx          # 큰 헤드라인 + 결과화면 모의
│   ├── demo.tsx          # ★ 라이브 데모 (3가지 샘플, 가짜 검사 애니메이션)
│   ├── how-it-works.tsx  # 3단계 카드
│   ├── features.tsx      # 8가지 기능 그리드
│   ├── social-proof.tsx  # 통계 + 리뷰 3개
│   ├── faq.tsx           # 펼침형 FAQ
│   ├── cta.tsx           # 어두운 최종 CTA
│   └── footer.tsx
├── lib/
│   ├── site.ts           # 사이트 메타 + appUrl
│   ├── mock-check.ts     # 데모 샘플 텍스트 + 가짜 검사 결과
│   └── utils.ts          # cn() 헬퍼
└── tailwind.config.ts    # 브랜드 색상, 폰트, 애니메이션
```

## 배포 (Vercel)

1. Vercel에서 새 프로젝트 만들기
2. 이 레포 연결, **Root Directory** 를 `landing` 으로 설정
3. Environment Variables 에 `NEXT_PUBLIC_APP_URL`, `NEXT_PUBLIC_SITE_URL` 추가
4. Deploy

도메인은 Vercel에서 `factlens.com` 연결하고, Flutter 앱은 Firebase Hosting의 `app.factlens.com` 으로 별도 운영.

## 컨텐츠 수정 가이드

- **헤드라인 / 카피**: `components/hero.tsx`, `components/cta.tsx`
- **사이트 메타 (이름·설명·URL)**: `lib/site.ts`
- **데모 샘플 텍스트와 검사 결과**: `lib/mock-check.ts` — `demoSamples` 배열 수정
- **기능 8개**: `components/features.tsx` — `features` 배열
- **FAQ**: `components/faq.tsx` — `faqs` 배열
- **사용자 후기**: `components/social-proof.tsx` — `reviews` 배열

## 알려진 한계

- 데모는 실제 API를 호출하지 않습니다 — 미리 준비된 가짜 결과를 시연합니다. 실제 검사는 CTA를 눌러 앱에서 수행해야 합니다. 진짜 API를 노출하기 시작하면 rate limiting + 익명 사용량 추적이 필요합니다.
- `social-proof.tsx` 의 통계와 후기는 플레이스홀더입니다. 실제 데이터로 교체하세요.
