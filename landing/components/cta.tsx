"use client";

import { motion } from "framer-motion";
import { ArrowRight, Sparkles } from "lucide-react";
import { site } from "@/lib/site";

export function CTA() {
  return (
    <section className="relative py-24 sm:py-28">
      <div className="container-page">
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="relative overflow-hidden rounded-[36px] bg-gradient-to-br from-ink-900 via-ink-800 to-brand-900 px-8 py-16 text-center sm:px-16 sm:py-20"
        >
          <div className="absolute inset-0 bg-noise opacity-[0.08]" aria-hidden />
          <div className="absolute -right-20 -top-20 h-72 w-72 rounded-full bg-brand-500/30 blur-3xl" aria-hidden />
          <div className="absolute -left-20 -bottom-20 h-72 w-72 rounded-full bg-purple-500/30 blur-3xl" aria-hidden />

          <div className="relative">
            <div className="mx-auto inline-flex items-center gap-1.5 rounded-full border border-white/15 bg-white/10 px-3 py-1 text-[11px] font-semibold uppercase tracking-wider text-white/90 backdrop-blur">
              <Sparkles className="h-3 w-3" />
              지금 시작
            </div>
            <h2 className="mt-6 font-display text-4xl font-black leading-tight tracking-tight text-white sm:text-5xl">
              자신 있는 글만 올리세요.
              <br />
              <span className="bg-gradient-to-r from-brand-300 via-purple-300 to-pink-300 bg-clip-text text-transparent">
                지금 무료로 시작하세요.
              </span>
            </h2>
            <p className="mx-auto mt-5 max-w-xl text-base leading-relaxed text-white/70">
              카드 등록도, 설치도 필요 없어요. 30초 안에 첫 검사 결과를 받아볼 수 있습니다.
            </p>
            <div className="mt-9 flex flex-col items-center justify-center gap-3 sm:flex-row">
              <a
                href={site.appUrl}
                className="inline-flex items-center justify-center gap-1.5 rounded-full bg-white px-6 py-3 text-sm font-bold text-ink-900 shadow-lg shadow-black/20 transition hover:bg-ink-100 active:translate-y-px"
              >
                무료로 시작하기
                <ArrowRight className="h-4 w-4" />
              </a>
              <a
                href="#demo"
                className="inline-flex items-center justify-center gap-1.5 rounded-full border border-white/20 bg-white/10 px-6 py-3 text-sm font-bold text-white backdrop-blur transition hover:bg-white/15 active:translate-y-px"
              >
                먼저 데모 보기
              </a>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
