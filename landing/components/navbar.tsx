"use client";

import { useEffect, useState } from "react";
import { ArrowRight, ScanText } from "lucide-react";
import { site } from "@/lib/site";
import { cn } from "@/lib/utils";

const links = [
  { label: "기능", href: "#features" },
  { label: "데모", href: "#demo" },
  { label: "작동 방식", href: "#how" },
  { label: "FAQ", href: "#faq" },
];

export function Navbar() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <header
      className={cn(
        "fixed inset-x-0 top-0 z-50 transition-all duration-300",
        scrolled ? "bg-white/80 backdrop-blur-xl border-b border-ink-200/60" : "bg-transparent",
      )}
    >
      <div className="container-page flex h-16 items-center justify-between">
        <a href="#top" className="flex items-center gap-2 font-bold tracking-tight">
          <span className="grid h-8 w-8 place-items-center rounded-lg bg-gradient-to-br from-brand-500 to-purple-500 text-white shadow-md shadow-brand-500/30">
            <ScanText className="h-4 w-4" />
          </span>
          <span className="text-base">{site.name}</span>
        </a>

        <nav className="hidden items-center gap-1 md:flex">
          {links.map((l) => (
            <a
              key={l.href}
              href={l.href}
              className="rounded-full px-3 py-1.5 text-sm font-medium text-ink-600 transition hover:bg-ink-100 hover:text-ink-900"
            >
              {l.label}
            </a>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <a
            href={site.appUrl}
            className="hidden text-sm font-semibold text-ink-700 hover:text-ink-900 sm:inline"
          >
            로그인
          </a>
          <a href={site.appUrl} className="btn-brand !py-2 !px-4 text-xs sm:text-sm">
            무료로 시작
            <ArrowRight className="h-3.5 w-3.5" />
          </a>
        </div>
      </div>
    </header>
  );
}
