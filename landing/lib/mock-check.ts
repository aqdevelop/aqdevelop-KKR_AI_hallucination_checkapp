export type Verdict = "supported" | "refuted" | "unverifiable";

export type DemoSource = {
  title: string;
  url: string;
  snippet: string;
  trust: number;
};

export type DemoClaim = {
  id: string;
  text: string;
  start: number;
  end: number;
  verdict: Verdict;
  confidence: number;
  explanation: string;
  suggestion?: string;
  sources: DemoSource[];
};

export type DemoSample = {
  key: string;
  label: string;
  tag: string;
  text: string;
  claims: DemoClaim[];
  trustScore: number;
};

export const demoSamples: DemoSample[] = [
  {
    key: "space",
    label: "한국 우주개발",
    tag: "역사",
    trustScore: 32,
    text: "한국의 첫 인공위성 우리별 1호는 1992년 NASA가 발사했습니다. 한국항공우주연구원은 2009년에 설립되었고, 첫 자체 발사체 누리호는 2021년에 첫 비행을 성공적으로 마쳤습니다.",
    claims: [
      {
        id: "c1",
        text: "한국의 첫 인공위성 우리별 1호는 1992년 NASA가 발사했습니다",
        start: 0,
        end: 35,
        verdict: "refuted",
        confidence: 0.93,
        explanation:
          "우리별 1호(KITSAT-1)는 1992년 8월 11일 프랑스령 기아나에서 ESA의 Ariane 4 발사체로 발사되었습니다. NASA가 아닌 유럽 아리안스페이스가 발사를 담당했습니다.",
        suggestion: "1992년 아리안 발사체로 프랑스령 기아나에서 발사",
        sources: [
          {
            title: "KAIST 인공위성연구소 — 우리별 1호 개발 기록",
            url: "https://example.com/kaist-kitsat1",
            snippet: "1992년 8월 11일 Ariane 4 발사체로 성공 발사. 한국 최초의 인공위성.",
            trust: 0.95,
          },
          {
            title: "한국항공우주연구원 발사 기록",
            url: "https://example.com/kari-history",
            snippet: "우리별 1호는 ESA Ariane 발사체로 궤도 진입에 성공.",
            trust: 0.91,
          },
        ],
      },
      {
        id: "c2",
        text: "한국항공우주연구원은 2009년에 설립되었고",
        start: 37,
        end: 60,
        verdict: "refuted",
        confidence: 0.96,
        explanation:
          "한국항공우주연구원(KARI)은 1989년 10월 10일 설립되었습니다. 2009년은 KARI가 나로호(KSLV-I)를 1차 발사한 해입니다.",
        suggestion: "1989년 설립 (2009년은 나로호 1차 발사 시점)",
        sources: [
          {
            title: "한국항공우주연구원 연혁",
            url: "https://example.com/kari-about",
            snippet: "1989년 10월 한국항공우주연구원으로 발족.",
            trust: 0.97,
          },
        ],
      },
      {
        id: "c3",
        text: "첫 자체 발사체 누리호는 2021년에 첫 비행을 성공적으로 마쳤습니다",
        start: 63,
        end: 96,
        verdict: "refuted",
        confidence: 0.88,
        explanation:
          "누리호(KSLV-II)는 2021년 10월 21일 1차 발사를 진행했으나 3단 엔진 조기 종료로 위성 모사체 궤도 진입에 실패했습니다. 성공은 2022년 6월 21일 2차 발사에서 처음 이루어졌습니다.",
        suggestion: "2021년 1차 발사는 부분 실패 — 2022년 2차에서 첫 성공",
        sources: [
          {
            title: "누리호 1차 발사 결과 (과학기술정보통신부)",
            url: "https://example.com/nuri-1st",
            snippet: "위성 모사체 궤도 진입 실패. 3단 엔진 연소 시간 부족.",
            trust: 0.96,
          },
          {
            title: "누리호 2차 발사 성공 보도",
            url: "https://example.com/nuri-2nd",
            snippet: "2022년 6월 21일 누리호 2차 발사 성공, 성능검증위성 분리.",
            trust: 0.93,
          },
        ],
      },
    ],
  },
  {
    key: "history",
    label: "한국사",
    tag: "역사",
    trustScore: 58,
    text: "세종대왕은 1446년에 훈민정음을 반포했고, 이순신 장군은 23전 23승의 완벽한 전적을 거뒀습니다. 임진왜란은 1592년에 시작되어 7년간 지속되었어요.",
    claims: [
      {
        id: "c1",
        text: "세종대왕은 1446년에 훈민정음을 반포했고",
        start: 0,
        end: 23,
        verdict: "supported",
        confidence: 0.98,
        explanation:
          "훈민정음은 1443년(세종 25년) 창제되어 1446년 9월에 반포되었습니다. 반포 시점은 정확합니다.",
        sources: [
          {
            title: "국사편찬위원회 — 훈민정음 해례본",
            url: "https://example.com/hangeul",
            snippet: "1446년 음력 9월 훈민정음 해례본 반포.",
            trust: 0.98,
          },
        ],
      },
      {
        id: "c2",
        text: "이순신 장군은 23전 23승의 완벽한 전적을 거뒀습니다",
        start: 25,
        end: 53,
        verdict: "unverifiable",
        confidence: 0.62,
        explanation:
          "이순신 장군의 '23전 23승'은 널리 인용되지만 역사학계에서 전투 횟수 집계 방식이 일관되지 않습니다. 자료에 따라 26전, 40여 전투 등으로 달라지며 모든 전투에서 결정적 승리를 거두지 않았다는 분석도 있습니다.",
        suggestion: "주요 해전에서 연승 — 정확한 전적은 사료마다 상이",
        sources: [
          {
            title: "해군사관학교 충무공 연구",
            url: "https://example.com/yi-sun-sin",
            snippet: "주요 해전 16회 외에 다수의 소규모 교전 기록이 존재.",
            trust: 0.84,
          },
        ],
      },
      {
        id: "c3",
        text: "임진왜란은 1592년에 시작되어 7년간 지속되었어요",
        start: 55,
        end: 80,
        verdict: "supported",
        confidence: 0.97,
        explanation:
          "임진왜란은 1592년 4월(음력) 시작되어 1598년 11월 노량해전으로 종결되었습니다. 정유재란을 포함해 약 7년간 진행되었습니다.",
        sources: [
          {
            title: "국사편찬위원회 — 임진왜란 연표",
            url: "https://example.com/imjin",
            snippet: "1592년 4월 13일 발발, 1598년 11월 종전.",
            trust: 0.98,
          },
        ],
      },
    ],
  },
  {
    key: "health",
    label: "건강 정보",
    tag: "건강",
    trustScore: 48,
    text: "비타민 C를 하루 3000mg 이상 섭취하면 감기를 예방할 수 있어요. 하루 8잔의 물을 마셔야 건강하다는 것은 모든 의사가 동의하는 사실입니다.",
    claims: [
      {
        id: "c1",
        text: "비타민 C를 하루 3000mg 이상 섭취하면 감기를 예방할 수 있어요",
        start: 0,
        end: 35,
        verdict: "refuted",
        confidence: 0.84,
        explanation:
          "코크란 리뷰 등 대규모 메타분석에 따르면 비타민 C 보충제는 일반 인구의 감기 발병률을 의미 있게 낮추지 못합니다. 또한 성인 상한 섭취량은 2000mg/일이며 그 이상은 위장 부작용 위험이 있습니다.",
        suggestion: "감기 지속 기간을 약간 단축시킬 수 있다는 근거만 존재",
        sources: [
          {
            title: "Cochrane Review: Vitamin C for the common cold",
            url: "https://example.com/cochrane-vitc",
            snippet: "Regular supplementation did not reduce incidence in the general community.",
            trust: 0.97,
          },
          {
            title: "보건복지부 한국인 영양소 섭취기준",
            url: "https://example.com/kdri",
            snippet: "성인 비타민 C 상한섭취량 2,000mg/일.",
            trust: 0.94,
          },
        ],
      },
      {
        id: "c2",
        text: "하루 8잔의 물을 마셔야 건강하다는 것은 모든 의사가 동의하는 사실입니다",
        start: 37,
        end: 75,
        verdict: "refuted",
        confidence: 0.9,
        explanation:
          "'하루 8잔'은 1945년 미국 식품영양위원회 권고가 잘못 전파된 결과로 알려져 있습니다. 필요 수분량은 체격·활동량·환경에 따라 다르며 식품 섭취 수분도 포함됩니다. 의학계에는 단일한 권장량 합의가 없습니다.",
        suggestion: "필요량은 개인차가 큼 — 단일 권장량은 의학적 근거 부족",
        sources: [
          {
            title: "Harvard T.H. Chan School of Public Health — Water",
            url: "https://example.com/harvard-water",
            snippet: "The '8x8' rule is not based on scientific evidence.",
            trust: 0.95,
          },
        ],
      },
    ],
  },
];
