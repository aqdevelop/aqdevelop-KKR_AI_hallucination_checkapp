"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Plus } from "lucide-react";
import { cn } from "@/lib/utils";

const faqs = [
  {
    q: "검사 결과는 얼마나 정확한가요?",
    a: "주장 추출 정확도는 약 94%, 검증 정확도는 출처 가용성에 따라 75–88%입니다. 결과는 참고용이며 중요한 결정은 직접 출처를 확인하시길 권장해요. 의심 구간이 표시되면 우선 점검할 부분이 명확해진다는 게 핵심 가치입니다.",
  },
  {
    q: "한국어 외에 다른 언어도 되나요?",
    a: "현재는 한국어를 최우선 지원하며, 영어 텍스트도 처리 가능합니다. 일본어·중국어는 베타 단계로 제한적으로 지원합니다.",
  },
  {
    q: "내 글이 학습 데이터로 쓰이지 않나요?",
    a: "검사한 텍스트는 본인 계정에만 저장되며, 모델 학습에 사용되지 않습니다. 계정 삭제 시 모든 검사 기록도 함께 삭제됩니다.",
  },
  {
    q: "얼마나 긴 글까지 검사할 수 있나요?",
    a: "한 번에 약 5,000자(원고지 25매)까지 검사 가능합니다. 그 이상은 자동으로 단락을 나눠 순차 처리합니다.",
  },
  {
    q: "지금 가격은 어떻게 되나요?",
    a: "베타 기간 중에는 무료입니다. 하루 검사 회수 제한이 있을 수 있으며, 정식 출시 시 무료 플랜은 유지됩니다.",
  },
  {
    q: "API로 우리 서비스에 연동할 수 있나요?",
    a: "B2B API는 비공개 베타 진행 중입니다. 사용 케이스가 있다면 푸터의 이메일로 문의해주세요.",
  },
];

export function FAQ() {
  const [open, setOpen] = useState<number | null>(0);
  return (
    <section id="faq" className="relative py-24 sm:py-28">
      <div className="container-page max-w-3xl">
        <div className="mb-12 text-center">
          <div className="section-eyebrow">자주 묻는 질문</div>
          <h2 className="mt-4 font-display text-3xl font-black tracking-tight text-ink-900 sm:text-4xl">
            궁금한 점이 있나요?
          </h2>
        </div>

        <div className="space-y-2">
          {faqs.map((f, i) => {
            const isOpen = open === i;
            return (
              <motion.div
                key={f.q}
                initial={{ opacity: 0, y: 8 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.3, delay: i * 0.04 }}
                className={cn(
                  "overflow-hidden rounded-2xl border bg-white transition",
                  isOpen ? "border-brand-300 shadow-md shadow-brand-500/5" : "border-ink-200/70",
                )}
              >
                <button
                  onClick={() => setOpen(isOpen ? null : i)}
                  className="flex w-full items-center justify-between gap-4 px-5 py-4 text-left"
                >
                  <span className="text-[15px] font-bold text-ink-900">{f.q}</span>
                  <span
                    className={cn(
                      "grid h-7 w-7 shrink-0 place-items-center rounded-full border transition",
                      isOpen
                        ? "border-brand-500 bg-brand-500 text-white rotate-45"
                        : "border-ink-200 text-ink-500",
                    )}
                  >
                    <Plus className="h-3.5 w-3.5" />
                  </span>
                </button>
                <AnimatePresence initial={false}>
                  {isOpen && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: "auto", opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.25, ease: "easeOut" }}
                      className="overflow-hidden"
                    >
                      <p className="px-5 pb-5 text-sm leading-relaxed text-ink-600">{f.a}</p>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
