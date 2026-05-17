"use client";

import { motion } from "framer-motion";
import { Quote, Star } from "lucide-react";

const stats = [
  { value: "1,200+", label: "베타 사용자" },
  { value: "94%", label: "주장 추출 정확도" },
  { value: "5.2초", label: "평균 검사 시간" },
  { value: "120+", label: "신뢰 출처 풀" },
];

const reviews = [
  {
    quote:
      "AI로 숏츠 대본 뽑고 바로 FactLens에 돌려요. 의심 구간 빨갛게 뜨면 바로 수정. 영상 올린 뒤 댓글로 지적 받는 일이 거의 사라졌어요.",
    name: "이재형",
    role: "유튜브 크리에이터 · 채널 12만 구독",
  },
  {
    quote:
      "기사 마감 직전에 인용 사실 확인을 빠르게 할 수 있어 좋아요. 특히 출처 링크가 신뢰도 점수까지 같이 떠서 어떤 걸 우선 확인할지 결정이 빠릅니다.",
    name: "박서연",
    role: "온라인 매체 에디터",
  },
  {
    quote:
      "학생들 보고서 코칭할 때 사용 중. 'AI가 쓴 거 그대로 내지 마라' 백 번 말하는 것보다 한 번 보여주는 게 효과적이에요.",
    name: "김도윤",
    role: "고등학교 교사",
  },
];

export function SocialProof() {
  return (
    <section className="relative py-24 sm:py-28">
      <div className="container-page">
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {stats.map((s, i) => (
            <motion.div
              key={s.label}
              initial={{ opacity: 0, y: 12 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: i * 0.05 }}
              className="rounded-2xl border border-ink-200/70 bg-white p-6 text-center"
            >
              <div className="font-display text-3xl font-black tracking-tight gradient-text">
                {s.value}
              </div>
              <div className="mt-1 text-xs font-semibold uppercase tracking-wider text-ink-500">
                {s.label}
              </div>
            </motion.div>
          ))}
        </div>

        <div className="mt-16">
          <div className="mb-8 flex items-center justify-center gap-2">
            {[...Array(5)].map((_, i) => (
              <Star key={i} className="h-4 w-4 fill-amber-400 text-amber-400" />
            ))}
            <span className="ml-2 text-sm font-bold text-ink-700">베타 만족도 4.8 / 5</span>
          </div>

          <div className="grid gap-5 md:grid-cols-3">
            {reviews.map((r, i) => (
              <motion.div
                key={r.name}
                initial={{ opacity: 0, y: 16 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-60px" }}
                transition={{ duration: 0.5, delay: i * 0.08 }}
                className="relative rounded-3xl border border-ink-200/70 bg-white p-6 shadow-sm"
              >
                <Quote className="absolute right-6 top-6 h-6 w-6 text-brand-200" />
                <p className="text-[14px] leading-relaxed text-ink-700">&ldquo;{r.quote}&rdquo;</p>
                <div className="mt-5 border-t border-ink-100 pt-4">
                  <p className="text-sm font-bold text-ink-900">{r.name}</p>
                  <p className="text-xs text-ink-500">{r.role}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
