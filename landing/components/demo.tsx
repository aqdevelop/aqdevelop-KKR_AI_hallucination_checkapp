"use client";

import { useState, useMemo, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  ArrowRight,
  CheckCircle2,
  AlertTriangle,
  HelpCircle,
  Loader2,
  Sparkles,
  RotateCcw,
  ExternalLink,
} from "lucide-react";
import { demoSamples, type DemoClaim, type Verdict } from "@/lib/mock-check";
import { site } from "@/lib/site";
import { cn } from "@/lib/utils";

type Status = "idle" | "checking" | "done";

const verdictColors: Record<
  Verdict,
  { bg: string; text: string; border: string; label: string; icon: typeof CheckCircle2 }
> = {
  supported: {
    bg: "bg-emerald-100",
    text: "text-emerald-800",
    border: "border-emerald-200",
    label: "확인됨",
    icon: CheckCircle2,
  },
  refuted: {
    bg: "bg-rose-100",
    text: "text-rose-800",
    border: "border-rose-200",
    label: "의심",
    icon: AlertTriangle,
  },
  unverifiable: {
    bg: "bg-amber-100",
    text: "text-amber-800",
    border: "border-amber-200",
    label: "불확실",
    icon: HelpCircle,
  },
};

export function Demo() {
  const [sampleKey, setSampleKey] = useState(demoSamples[0].key);
  const [status, setStatus] = useState<Status>("idle");
  const [selectedClaimId, setSelectedClaimId] = useState<string | null>(null);

  const sample = useMemo(
    () => demoSamples.find((s) => s.key === sampleKey) ?? demoSamples[0],
    [sampleKey],
  );

  useEffect(() => {
    setStatus("idle");
    setSelectedClaimId(null);
  }, [sampleKey]);

  const runCheck = () => {
    setStatus("checking");
    setSelectedClaimId(null);
    setTimeout(() => setStatus("done"), 1600);
  };

  const reset = () => {
    setStatus("idle");
    setSelectedClaimId(null);
  };

  const selectedClaim =
    sample.claims.find((c) => c.id === selectedClaimId) ?? null;

  const counts = sample.claims.reduce(
    (acc, c) => ({ ...acc, [c.verdict]: (acc[c.verdict] ?? 0) + 1 }),
    {} as Record<Verdict, number>,
  );

  return (
    <section id="demo" className="relative py-24 sm:py-28">
      <div className="container-page">
        <div className="mx-auto mb-12 max-w-2xl text-center">
          <div className="section-eyebrow">
            <Sparkles className="h-3 w-3" />
            라이브 데모
          </div>
          <h2 className="mt-4 font-display text-3xl font-black tracking-tight text-ink-900 sm:text-4xl">
            먼저 직접 <span className="gradient-text">시험 검사</span>해 보세요
          </h2>
          <p className="mt-4 text-base text-ink-600">
            가입 없이 미리 준비된 예시로 결과 화면을 그대로 체험해볼 수 있어요.
            <br className="hidden sm:block" /> 만족스러우면 그때 시작해도 늦지 않아요.
          </p>
        </div>

        <div className="relative">
          <div className="absolute -inset-x-4 -inset-y-4 -z-10 rounded-[40px] bg-gradient-to-tr from-brand-300/30 via-purple-300/20 to-pink-300/20 blur-3xl" aria-hidden />

          <div className="glass-card overflow-hidden">
            {/* Sample tabs */}
            <div className="border-b border-ink-200/70 bg-ink-50/40 px-4 py-3 sm:px-6">
              <div className="flex flex-wrap items-center gap-2">
                <span className="mr-2 text-xs font-semibold text-ink-500">예시</span>
                {demoSamples.map((s) => (
                  <button
                    key={s.key}
                    onClick={() => setSampleKey(s.key)}
                    className={cn(
                      "rounded-full border px-3 py-1 text-xs font-bold transition",
                      sampleKey === s.key
                        ? "border-brand-500 bg-brand-500 text-white shadow-sm shadow-brand-500/30"
                        : "border-ink-200 bg-white text-ink-700 hover:border-ink-300",
                    )}
                  >
                    {s.label}
                  </button>
                ))}
              </div>
            </div>

            <div className="grid gap-0 md:grid-cols-[1fr_360px]">
              {/* Left: text */}
              <div className="border-b border-ink-200/70 p-6 md:border-b-0 md:border-r">
                <div className="mb-3 flex items-center justify-between">
                  <span className="text-xs font-semibold uppercase tracking-wider text-ink-500">
                    검사 대상 텍스트
                  </span>
                  <span className="text-[11px] text-ink-400">{sample.text.length}자</span>
                </div>

                <div
                  className={cn(
                    "min-h-[200px] rounded-2xl border bg-white p-5 text-[15px] leading-[1.9] text-ink-800 transition",
                    status === "done" ? "border-ink-200" : "border-ink-200/80",
                  )}
                >
                  {status === "done" ? (
                    <HighlightedText
                      text={sample.text}
                      claims={sample.claims}
                      selectedClaimId={selectedClaimId}
                      onSelect={setSelectedClaimId}
                    />
                  ) : (
                    <p className={cn(status === "checking" && "opacity-60")}>{sample.text}</p>
                  )}
                </div>

                <div className="mt-5 flex flex-wrap items-center gap-3">
                  {status === "idle" && (
                    <button onClick={runCheck} className="btn-brand">
                      <Sparkles className="h-4 w-4" />
                      검사 시작
                    </button>
                  )}
                  {status === "checking" && (
                    <button disabled className="btn-brand cursor-not-allowed opacity-80">
                      <Loader2 className="h-4 w-4 animate-spin" />
                      AI가 사실 주장 추출 중…
                    </button>
                  )}
                  {status === "done" && (
                    <>
                      <button onClick={reset} className="btn-ghost">
                        <RotateCcw className="h-4 w-4" />
                        다시 검사
                      </button>
                      <a href={site.appUrl} className="btn-brand">
                        내 글로 검사하기
                        <ArrowRight className="h-4 w-4" />
                      </a>
                    </>
                  )}
                </div>
              </div>

              {/* Right: result panel */}
              <div className="bg-gradient-to-b from-ink-50/40 to-white p-6">
                <AnimatePresence mode="wait">
                  {status === "idle" && <IdlePanel key="idle" />}
                  {status === "checking" && <CheckingPanel key="checking" />}
                  {status === "done" && (
                    <DonePanel
                      key="done"
                      trustScore={sample.trustScore}
                      total={sample.claims.length}
                      counts={counts}
                      selectedClaim={selectedClaim}
                    />
                  )}
                </AnimatePresence>
              </div>
            </div>
          </div>
        </div>

        <p className="mx-auto mt-6 max-w-xl text-center text-xs text-ink-500">
          ※ 데모는 미리 준비된 예시를 보여주는 시연입니다. 실제 검사는 위 버튼으로 앱에서 진행해주세요.
        </p>
      </div>
    </section>
  );
}

function HighlightedText({
  text,
  claims,
  selectedClaimId,
  onSelect,
}: {
  text: string;
  claims: DemoClaim[];
  selectedClaimId: string | null;
  onSelect: (id: string) => void;
}) {
  const sorted = [...claims].sort((a, b) => a.start - b.start);
  const parts: React.ReactNode[] = [];
  let cursor = 0;

  sorted.forEach((c, idx) => {
    if (c.start > cursor) parts.push(<span key={`t-${idx}`}>{text.slice(cursor, c.start)}</span>);
    const v = verdictColors[c.verdict];
    const isSelected = c.id === selectedClaimId;
    parts.push(
      <mark
        key={c.id}
        onClick={() => onSelect(c.id)}
        style={{ animationDelay: `${idx * 90}ms` }}
        className={cn(
          "animate-fade-in-up cursor-pointer rounded-md px-1.5 py-0.5 transition",
          v.bg,
          v.text,
          isSelected
            ? "ring-2 ring-offset-1 ring-offset-white ring-current"
            : "hover:brightness-95",
        )}
      >
        {text.slice(c.start, c.end)}
      </mark>,
    );
    cursor = c.end;
  });
  if (cursor < text.length) parts.push(<span key="t-last">{text.slice(cursor)}</span>);

  return <p>{parts}</p>;
}

function IdlePanel() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="flex h-full flex-col items-center justify-center text-center"
    >
      <div className="relative">
        <div className="absolute inset-0 -z-10 animate-pulse rounded-full bg-brand-300/30 blur-2xl" />
        <div className="grid h-16 w-16 place-items-center rounded-2xl bg-gradient-to-br from-brand-500 to-purple-500 text-white shadow-lg shadow-brand-500/30">
          <Sparkles className="h-7 w-7" />
        </div>
      </div>
      <p className="mt-4 text-sm font-semibold text-ink-800">검사 준비 완료</p>
      <p className="mt-1 text-xs text-ink-500">
        왼쪽의 <strong>검사 시작</strong> 버튼을 눌러주세요.
      </p>
    </motion.div>
  );
}

function CheckingPanel() {
  const steps = [
    "사실 주장 추출",
    "주장별 검색어 생성",
    "웹에서 근거 수집",
    "신뢰도 평가",
  ];
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="flex h-full flex-col justify-center"
    >
      <p className="text-xs font-semibold uppercase tracking-wider text-ink-500">검사 중</p>
      <p className="mt-1 text-sm font-bold text-ink-800">AI가 사실을 확인하고 있어요</p>
      <div className="mt-5 space-y-3">
        {steps.map((s, i) => (
          <motion.div
            key={s}
            initial={{ opacity: 0, x: -10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: i * 0.3 }}
            className="flex items-center gap-2 text-xs text-ink-700"
          >
            <Loader2 className="h-3.5 w-3.5 animate-spin text-brand-500" />
            {s}
          </motion.div>
        ))}
      </div>
    </motion.div>
  );
}

function DonePanel({
  trustScore,
  total,
  counts,
  selectedClaim,
}: {
  trustScore: number;
  total: number;
  counts: Record<Verdict, number>;
  selectedClaim: DemoClaim | null;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0 }}
      className="flex h-full flex-col"
    >
      <div className="flex items-center gap-4">
        <ScoreRing score={trustScore} />
        <div>
          <p className="text-[11px] font-semibold uppercase tracking-wider text-ink-500">신뢰 점수</p>
          <p className="text-sm font-bold text-ink-800">주장 {total}개 분석됨</p>
        </div>
      </div>

      <div className="mt-5 space-y-2">
        <CountRow
          label="확인됨"
          count={counts.supported ?? 0}
          color="emerald"
          icon={CheckCircle2}
        />
        <CountRow
          label="의심"
          count={counts.refuted ?? 0}
          color="rose"
          icon={AlertTriangle}
        />
        <CountRow
          label="불확실"
          count={counts.unverifiable ?? 0}
          color="amber"
          icon={HelpCircle}
        />
      </div>

      <div className="mt-5 border-t border-ink-200/70 pt-4">
        <AnimatePresence mode="wait">
          {selectedClaim ? (
            <ClaimDetail key={selectedClaim.id} claim={selectedClaim} />
          ) : (
            <motion.p
              key="hint"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="text-xs text-ink-500"
            >
              💡 왼쪽에서 <strong className="text-ink-700">색칠된 구간</strong>을 탭하면 근거와 출처를 볼 수 있어요.
            </motion.p>
          )}
        </AnimatePresence>
      </div>
    </motion.div>
  );
}

function ScoreRing({ score }: { score: number }) {
  const color =
    score >= 70 ? "from-emerald-500 to-emerald-400 shadow-emerald-500/30"
    : score >= 40 ? "from-amber-500 to-amber-400 shadow-amber-500/30"
    : "from-rose-500 to-rose-400 shadow-rose-500/30";
  return (
    <motion.div
      initial={{ scale: 0.7, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      transition={{ type: "spring", stiffness: 220, damping: 18 }}
      className={cn(
        "relative grid h-20 w-20 place-items-center rounded-full bg-gradient-to-br text-white shadow-lg",
        color,
      )}
    >
      <CountUp value={score} className="text-2xl font-black leading-none" />
      <span className="absolute bottom-2 text-[9px] opacity-90">/ 100</span>
    </motion.div>
  );
}

function CountUp({ value, className }: { value: number; className?: string }) {
  const [n, setN] = useState(0);
  useEffect(() => {
    let raf = 0;
    const start = performance.now();
    const dur = 900;
    const tick = (t: number) => {
      const p = Math.min(1, (t - start) / dur);
      const eased = 1 - Math.pow(1 - p, 3);
      setN(Math.round(value * eased));
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [value]);
  return <span className={className}>{n}</span>;
}

function CountRow({
  label,
  count,
  color,
  icon: Icon,
}: {
  label: string;
  count: number;
  color: "emerald" | "rose" | "amber";
  icon: typeof CheckCircle2;
}) {
  const map = {
    emerald: { bg: "bg-emerald-50", text: "text-emerald-700", dot: "bg-emerald-500" },
    rose: { bg: "bg-rose-50", text: "text-rose-700", dot: "bg-rose-500" },
    amber: { bg: "bg-amber-50", text: "text-amber-700", dot: "bg-amber-500" },
  } as const;
  const c = map[color];
  return (
    <div
      className={cn(
        "flex items-center justify-between rounded-xl border border-ink-200/60 bg-white px-3 py-2",
      )}
    >
      <span className={cn("flex items-center gap-2 text-xs font-semibold", c.text)}>
        <Icon className="h-3.5 w-3.5" />
        {label}
      </span>
      <span className={cn("text-sm font-black", c.text)}>{count}</span>
    </div>
  );
}

function ClaimDetail({ claim }: { claim: DemoClaim }) {
  const v = verdictColors[claim.verdict];
  const Icon = v.icon;
  return (
    <motion.div
      initial={{ opacity: 0, y: 6 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0 }}
      className="space-y-3"
    >
      <div className={cn("inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[11px] font-bold", v.bg, v.text)}>
        <Icon className="h-3 w-3" />
        {v.label} · {Math.round(claim.confidence * 100)}%
      </div>
      <p className="text-xs leading-relaxed text-ink-700">{claim.explanation}</p>
      {claim.suggestion && (
        <div className="rounded-lg border border-brand-200 bg-brand-50 px-3 py-2 text-xs text-brand-800">
          <span className="font-bold">제안: </span>
          {claim.suggestion}
        </div>
      )}
      <div className="space-y-1.5">
        <p className="text-[10px] font-bold uppercase tracking-wider text-ink-500">출처</p>
        {claim.sources.map((s) => (
          <div
            key={s.url}
            className="group flex items-start gap-2 rounded-lg border border-ink-200/70 bg-white px-2.5 py-2 text-[11px]"
          >
            <ExternalLink className="mt-0.5 h-3 w-3 shrink-0 text-ink-400 transition group-hover:text-brand-600" />
            <div className="min-w-0">
              <p className="truncate font-semibold text-ink-800">{s.title}</p>
              <p className="line-clamp-2 text-ink-500">{s.snippet}</p>
            </div>
          </div>
        ))}
      </div>
    </motion.div>
  );
}
