"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { navigation } from "@/lib/navigation";
import { useState } from "react";

export function Sidebar() {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});

  const toggle = (title: string) =>
    setCollapsed((prev) => ({ ...prev, [title]: !prev[title] }));

  return (
    <aside className="hidden lg:flex flex-col w-72 shrink-0 border-r border-slate-200 dark:border-slate-800 bg-[var(--sidebar-bg)] h-screen sticky top-0 overflow-y-auto">
      <div className="p-6 border-b border-slate-200 dark:border-slate-800">
        <Link href="/" className="flex items-center gap-3 group">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-violet-500 to-teal-400 flex items-center justify-center shadow-lg shadow-violet-500/25 group-hover:shadow-violet-500/40 transition-shadow duration-300">
            <svg width="18" height="18" viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg">
              <polygon points="60,8 108,96 12,96" fill="white" opacity="0.9" />
            </svg>
          </div>
          <div>
            <span className="font-bold text-lg tracking-tight">Prism</span>
            <span className="block text-xs text-slate-500 dark:text-slate-400 -mt-0.5">Docs</span>
          </div>
        </Link>
      </div>

      <nav className="flex-1 p-4 space-y-6" aria-label="Navegação principal">
        {navigation.map((section) => (
          <div key={section.title}>
            <button
              onClick={() => toggle(section.title)}
              className="flex items-center justify-between w-full text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 transition-colors duration-150 mb-2"
            >
              {section.title}
              <svg
                className={`w-3.5 h-3.5 transition-transform duration-200 ${collapsed[section.title] ? "-rotate-90" : ""}`}
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
              >
                <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            {!collapsed[section.title] && (
              <ul className="space-y-0.5">
                {section.items.map((item) => {
                  const isActive = pathname === item.href;
                  return (
                    <li key={item.href}>
                      <Link
                        href={item.href}
                        className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm transition-all duration-150 ${
                          isActive
                            ? "bg-violet-50 dark:bg-violet-950/40 text-violet-700 dark:text-violet-300 font-medium"
                            : "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 hover:bg-slate-100 dark:hover:bg-slate-800"
                        }`}
                        aria-current={isActive ? "page" : undefined}
                      >
                        {item.icon && <span className="text-base">{item.icon}</span>}
                        {item.title}
                      </Link>
                    </li>
                  );
                })}
              </ul>
            )}
          </div>
        ))}
      </nav>

      <div className="p-4 border-t border-slate-200 dark:border-slate-800">
        <a
          href="https://github.com/rafaelesantos/prism"
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-2 text-sm text-slate-500 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 transition-colors duration-150"
        >
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.747.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
          </svg>
          GitHub
        </a>
      </div>
    </aside>
  );
}