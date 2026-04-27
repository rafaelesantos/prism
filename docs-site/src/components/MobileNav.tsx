"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { navigation } from "@/lib/navigation";

export function MobileNav() {
  const [open, setOpen] = useState(false);
  const pathname = usePathname();

  return (
    <>
      <button
        onClick={() => setOpen(!open)}
        className="lg:hidden fixed top-4 left-4 z-50 p-2 rounded-xl bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl border border-slate-200 dark:border-slate-700 shadow-lg"
        aria-label={open ? "Fechar menu" : "Abrir menu"}
      >
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          {open ? (
            <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
          ) : (
            <path strokeLinecap="round" strokeLinejoin="round" d="M4 6h16M4 12h16M4 18h16" />
          )}
        </svg>
      </button>

      {open && (
        <div className="lg:hidden fixed inset-0 z-40 bg-black/50 backdrop-blur-sm" onClick={() => setOpen(false)} />
      )}

      <div
        className={`lg:hidden fixed inset-y-0 left-0 z-40 w-80 bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-700 shadow-2xl transform transition-transform duration-300 ease-in-out ${
          open ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="p-6 border-b border-slate-200 dark:border-slate-800">
          <Link href="/" className="flex items-center gap-3" onClick={() => setOpen(false)}>
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-violet-500 to-teal-400 flex items-center justify-center">
              <svg width="18" height="18" viewBox="0 0 120 120" fill="none">
                <polygon points="60,8 108,96 12,96" fill="white" opacity="0.9" />
              </svg>
            </div>
            <span className="font-bold text-lg tracking-tight">Prism Docs</span>
          </Link>
        </div>

        <nav className="flex-1 p-4 space-y-6 overflow-y-auto max-h-[calc(100vh-5rem)]">
          {navigation.map((section) => (
            <div key={section.title}>
              <p className="text-xs font-semibold uppercase tracking-wider text-slate-500 dark:text-slate-400 mb-2">
                {section.title}
              </p>
              <ul className="space-y-0.5">
                {section.items.map((item) => {
                  const isActive = pathname === item.href;
                  return (
                    <li key={item.href}>
                      <Link
                        href={item.href}
                        onClick={() => setOpen(false)}
                        className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm transition-colors duration-150 ${
                          isActive
                            ? "bg-violet-50 dark:bg-violet-950/40 text-violet-700 dark:text-violet-300 font-medium"
                            : "text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-slate-100 hover:bg-slate-100 dark:hover:bg-slate-800"
                        }`}
                      >
                        {item.icon && <span>{item.icon}</span>}
                        {item.title}
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </div>
          ))}
        </nav>
      </div>
    </>
  );
}