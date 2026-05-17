import { ScanText, Mail, Github } from "lucide-react";
import { site } from "@/lib/site";

export function Footer() {
  return (
    <footer className="border-t border-ink-200/70 bg-white">
      <div className="container-page py-14">
        <div className="grid gap-10 md:grid-cols-[2fr_1fr_1fr_1fr]">
          <div>
            <div className="flex items-center gap-2 font-bold">
              <span className="grid h-8 w-8 place-items-center rounded-lg bg-gradient-to-br from-brand-500 to-purple-500 text-white">
                <ScanText className="h-4 w-4" />
              </span>
              <span>{site.name}</span>
            </div>
            <p className="mt-3 max-w-xs text-sm text-ink-600">{site.description}</p>
            <div className="mt-5 flex items-center gap-2">
              <a
                href="mailto:hello@factlens.com"
                className="grid h-9 w-9 place-items-center rounded-full border border-ink-200 text-ink-500 transition hover:border-ink-300 hover:text-ink-800"
                aria-label="이메일"
              >
                <Mail className="h-4 w-4" />
              </a>
              <a
                href="https://github.com"
                className="grid h-9 w-9 place-items-center rounded-full border border-ink-200 text-ink-500 transition hover:border-ink-300 hover:text-ink-800"
                aria-label="GitHub"
              >
                <Github className="h-4 w-4" />
              </a>
            </div>
          </div>

          <FooterColumn
            title="제품"
            items={[
              { label: "기능", href: "#features" },
              { label: "데모", href: "#demo" },
              { label: "작동 방식", href: "#how" },
              { label: "앱 시작하기", href: site.appUrl },
            ]}
          />
          <FooterColumn
            title="회사"
            items={[
              { label: "소개", href: "#" },
              { label: "블로그", href: "#" },
              { label: "문의", href: "mailto:hello@factlens.com" },
            ]}
          />
          <FooterColumn
            title="법적 고지"
            items={[
              { label: "이용약관", href: "#" },
              { label: "개인정보처리방침", href: "#" },
              { label: "쿠키 정책", href: "#" },
            ]}
          />
        </div>

        <div className="mt-12 flex flex-col items-center justify-between gap-3 border-t border-ink-100 pt-6 text-xs text-ink-500 sm:flex-row">
          <p>© {new Date().getFullYear()} {site.name}. All rights reserved.</p>
          <p>Made with care in Seoul · 결과는 참고용이며 100% 정확하지 않습니다.</p>
        </div>
      </div>
    </footer>
  );
}

function FooterColumn({
  title,
  items,
}: {
  title: string;
  items: { label: string; href: string }[];
}) {
  return (
    <div>
      <h3 className="text-xs font-bold uppercase tracking-wider text-ink-500">{title}</h3>
      <ul className="mt-4 space-y-2.5">
        {items.map((it) => (
          <li key={it.label}>
            <a
              href={it.href}
              className="text-sm text-ink-700 transition hover:text-ink-900"
            >
              {it.label}
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
}
