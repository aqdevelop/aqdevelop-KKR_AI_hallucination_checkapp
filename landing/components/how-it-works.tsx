"use client";

import { motion } from "framer-motion";
import { ClipboardPaste, Network, ShieldCheck } from "lucide-react";

const steps = [
  {
    icon: ClipboardPaste,
    title: "대본을 붙여넣어요",
    body: "AI가 생성한 글이든 직접 쓴 글이든 한 문단 이상 붙여넣기만 하면 시작됩니다.",
    color: "from-brand-500 to-purple-500",
  },
  {
    icon: Network,
    title: "주장 단위로 교차검증",
    body: "글에서 '사실 주장'만 골라 다중 검색엔진과 신뢰도 높은 출처에서 동시에 확인합니다.",
    color: "from-purple-500 to-pink-500",
  },
  {
    icon: ShieldCheck,
    title: "신뢰점수 + 근거 제공",
    body: "0–100점의 신뢰점수와 함께 의심 구간이 색칠되고, 각 주장의 출처를 함께 보여드립니다.",
    color: "from-emerald-500 to-teal-500",
  },
];

export function HowItWorks() {
  return (
    <section id="how" className="relative py-24 sm:py-28">
      <div className="container-page">
        <div className="mx-auto max-w-2xl text-center">
          <div className="section-eyebrow">작동 방식</div>
          <h2 className="mt-4 font-display text-3xl font-black tracking-tight text-ink-900 sm:text-4xl">
            붙여넣기 한 번이면 끝
          </h2>
          <p className="mt-4 text-base text-ink-600">
            3단계로 글의 사실 여부를 확인하고, 근거 출처까지 함께 보여드립니다.
          </p>
        </div>

        <div className="mt-14 grid gap-5 md:grid-cols-3">
          {steps.map((s, i) => (
            <motion.div
              key={s.title}
              initial={{ opacity: 0, y: 16 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-80px" }}
              transition={{ duration: 0.5, delay: i * 0.08 }}
              className="group relative overflow-hidden rounded-3xl border border-ink-200/70 bg-white p-7 shadow-sm transition hover:shadow-lg hover:shadow-brand-500/10"
            >
              <div className="mb-5 inline-flex">
                <div className={`grid h-12 w-12 place-items-center rounded-2xl bg-gradient-to-br ${s.color} text-white shadow-md`}>
                  <s.icon className="h-5 w-5" />
                </div>
              </div>
              <div className="absolute right-5 top-5 font-display text-5xl font-black text-ink-100 transition group-hover:text-brand-100">
                0{i + 1}
              </div>
              <h3 className="font-display text-lg font-bold text-ink-900">{s.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-ink-600">{s.body}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
