"use client";

import { motion } from "framer-motion";
import { ArrowRight, Sparkles, ShieldCheck, ScanSearch, CheckCircle2, AlertTriangle, HelpCircle } from "lucide-react";
import { site } from "@/lib/site";

export function Hero() {
  return (
    <section id="top" className="relative overflow-hidden pt-28 pb-24 sm:pt-36 sm:pb-32">
      <div className="absolute inset-0 grid-bg" aria-hidden />
      <div className="absolute left-1/2 top-0 -z-10 h-[520px] w-[860px] -translate-x-1/2 rounded-full bg-gradient-to-tr from-brand-400/20 via-purple-300/20 to-transparent blur-3xl" aria-hidden />

      <div className="container-page relative">
        <div className="mx-auto flex max-w-3xl flex-col items-center text-center">
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
            className="section-eyebrow"
          >
            <Sparkles className="h-3 w-3" />
            AI 할루시네이션, 이제 그만
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.05 }}
            className="mt-5 font-display text-4xl font-black leading-[1.1] tracking-tight text-ink-900 sm:text-6xl"
          >
            AI가 써준 글,
            <br />
            <span className="gradient-text">올리기 전에 검증하세요.</span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.12 }}
            className="mt-6 max-w-2xl text-base leading-relaxed text-ink-600 sm:text-lg"
          >
            {site.name}는 AI가 생성한 대본·기사·게시물을 <strong className="font-semibold text-ink-800">사실 주장 단위</strong>로 쪼개,
            웹에서 교차검증하고 의심 가는 구간을 색칠해 보여드립니다.
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="mt-9 flex flex-col items-center gap-3 sm:flex-row"
          >
            <a href={site.appUrl} className="btn-brand">
              무료로 시작하기
              <ArrowRight className="h-4 w-4" />
            </a>
            <a href="#demo" className="btn-ghost">
              <ScanSearch className="h-4 w-4" />
              먼저 시험 검사 해보기
            </a>
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.32 }}
            className="mt-6 flex items-center gap-2 text-xs text-ink-500"
          >
            <ShieldCheck className="h-3.5 w-3.5" />
            카드 등록 없이 시작 · 한국어 최적화 · 출처 링크 제공
          </motion.div>
        </div>

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.35 }}
          className="relative mx-auto mt-16 max-w-4xl"
        >
          <HeroMock />
        </motion.div>
      </div>
    </section>
  );
}

function HeroMock() {
  return (
    <div className="relative">
      <div className="absolute -inset-x-6 -inset-y-6 -z-10 rounded-[36px] bg-gradient-to-tr from-brand-400/30 via-purple-400/20 to-pink-300/20 blur-2xl" aria-hidden />
      <div className="glass-card overflow-hidden">
        <div className="flex items-center gap-1.5 border-b border-ink-200/70 bg-ink-50/60 px-4 py-3">
          <span className="h-2.5 w-2.5 rounded-full bg-[#FF5F57]" />
          <span className="h-2.5 w-2.5 rounded-full bg-[#FEBC2E]" />
          <span className="h-2.5 w-2.5 rounded-full bg-[#28C840]" />
          <span className="ml-3 text-[11px] font-medium text-ink-500">factlens.app — 검사 결과</span>
        </div>
        <div className="grid gap-6 p-6 md:grid-cols-[1fr_280px]">
          <div className="space-y-4">
            <div className="flex flex-wrap gap-2">
              <span className="inline-flex items-center gap-1 rounded-md bg-emerald-50 px-1.5 py-0.5 text-[11px] font-bold text-emerald-700">
                <CheckCircle2 className="h-3 w-3" /> 확인
              </span>
              <span className="inline-flex items-center gap-1 rounded-md bg-rose-50 px-1.5 py-0.5 text-[11px] font-bold text-rose-700">
                <AlertTriangle className="h-3 w-3" /> 의심
              </span>
              <span className="inline-flex items-center gap-1 rounded-md bg-amber-50 px-1.5 py-0.5 text-[11px] font-bold text-amber-700">
                <HelpCircle className="h-3 w-3" /> 불확실
              </span>
            </div>
            <p className="text-[15px] leading-[1.9] text-ink-800">
              한국의 첫 인공위성 우리별 1호는{" "}
              <mark className="rounded-md bg-rose-100 px-1.5 py-0.5 text-rose-800 decoration-rose-300">
                1992년 NASA가 발사했습니다
              </mark>
              . 한국항공우주연구원은{" "}
              <mark className="rounded-md bg-rose-100 px-1.5 py-0.5 text-rose-800">
                2009년에 설립
              </mark>
              되었고, 첫 자체 발사체 누리호는{" "}
              <mark className="rounded-md bg-amber-100 px-1.5 py-0.5 text-amber-800">
                2021년에 첫 비행을 성공적으로 마쳤습니다
              </mark>
              .
            </p>
          </div>
          <ScoreCardMock />
        </div>
      </div>
    </div>
  );
}

function ScoreCardMock() {
  return (
    <div className="flex flex-col gap-3 rounded-2xl border border-ink-200 bg-white p-4">
      <div className="flex items-center gap-3">
        <div className="relative grid h-16 w-16 place-items-center rounded-full bg-gradient-to-br from-rose-500 to-rose-400 text-white shadow-md shadow-rose-500/30">
          <span className="text-xl font-black leading-none">32</span>
          <span className="absolute -bottom-0.5 text-[8px] opacity-80">/100</span>
        </div>
        <div>
          <div className="text-[11px] font-semibold uppercase tracking-wider text-ink-500">신뢰 점수</div>
          <div className="text-sm font-bold text-ink-800">주장 3개 분석됨</div>
        </div>
      </div>
      <div className="space-y-1.5 pt-1">
        <Row label="확인" count={0} color="emerald" />
        <Row label="의심" count={2} color="rose" />
        <Row label="불확실" count={1} color="amber" />
      </div>
    </div>
  );
}

function Row({
  label,
  count,
  color,
}: {
  label: string;
  count: number;
  color: "emerald" | "rose" | "amber";
}) {
  const colorMap = {
    emerald: "bg-emerald-500",
    rose: "bg-rose-500",
    amber: "bg-amber-500",
  } as const;
  return (
    <div className="flex items-center justify-between text-xs">
      <span className="flex items-center gap-1.5 text-ink-600">
        <span className={`h-1.5 w-1.5 rounded-full ${colorMap[color]}`} />
        {label}
      </span>
      <span className="font-bold text-ink-800">{count}</span>
    </div>
  );
}
