"use client";

import { motion } from "framer-motion";
import {
  Languages,
  Link2,
  History,
  Zap,
  Lock,
  PieChart,
  Highlighter,
  Smartphone,
} from "lucide-react";

const features = [
  {
    icon: Languages,
    title: "한국어 최적화",
    body: "한국 뉴스·정치·역사·연예 컨텍스트를 우선 학습한 모델로 한국어 글에서도 의미를 놓치지 않아요.",
  },
  {
    icon: Highlighter,
    title: "구간 단위 하이라이트",
    body: "어느 문장의 어느 단어가 문제인지 정확히 색칠해, 한눈에 의심 구간을 파악할 수 있어요.",
  },
  {
    icon: Link2,
    title: "출처 링크 제공",
    body: "각 주장마다 신뢰도 평가된 웹 출처를 함께 제공해 직접 원문으로 확인할 수 있어요.",
  },
  {
    icon: PieChart,
    title: "신뢰점수 한 줄 요약",
    body: "0–100점의 직관적인 점수로 글 전체의 사실성을 빠르게 판단할 수 있어요.",
  },
  {
    icon: History,
    title: "검사 기록 자동 저장",
    body: "검사한 모든 결과가 자동으로 보관돼, 언제든 다시 열어보고 비교할 수 있어요.",
  },
  {
    icon: Zap,
    title: "결과까지 평균 5초",
    body: "캐시 + 병렬 검색으로 짧은 문단은 1~2초, 긴 대본도 10초 안에 결과가 나와요.",
  },
  {
    icon: Lock,
    title: "내 글은 내 것",
    body: "검사한 텍스트는 본인 계정에만 저장되며, 학습 데이터로 사용되지 않아요.",
  },
  {
    icon: Smartphone,
    title: "어디서나 사용",
    body: "웹 브라우저, 모바일 어디서나 같은 경험. 별도 설치 없이 바로 시작할 수 있어요.",
  },
];

export function Features() {
  return (
    <section id="features" className="relative py-24 sm:py-28">
      <div className="container-page">
        <div className="mx-auto max-w-2xl text-center">
          <div className="section-eyebrow">기능</div>
          <h2 className="mt-4 font-display text-3xl font-black tracking-tight text-ink-900 sm:text-4xl">
            팩트체크에 필요한 모든 것
          </h2>
          <p className="mt-4 text-base text-ink-600">
            크리에이터, 마케터, 학생, 기자 — 누구나 사실 확인이 필요한 순간에.
          </p>
        </div>

        <div className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {features.map((f, i) => (
            <motion.div
              key={f.title}
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-60px" }}
              transition={{ duration: 0.4, delay: (i % 4) * 0.06 }}
              className="rounded-2xl border border-ink-200/70 bg-white p-5 transition hover:border-brand-200 hover:bg-brand-50/30"
            >
              <div className="mb-3 inline-flex h-10 w-10 items-center justify-center rounded-xl bg-brand-50 text-brand-600">
                <f.icon className="h-5 w-5" />
              </div>
              <h3 className="text-[15px] font-bold text-ink-900">{f.title}</h3>
              <p className="mt-1.5 text-[13px] leading-relaxed text-ink-600">{f.body}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
