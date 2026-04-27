import Link from "next/link";
import { modules } from "@/lib/navigation";

export default function Home() {
  return (
    <main className="min-h-screen">
      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-violet-600 via-purple-600 to-indigo-700" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_50%,rgba(255,255,255,0.1),transparent_60%)]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_70%_80%,rgba(45,212,191,0.2),transparent_50%)]" />

        <div className="relative max-w-6xl mx-auto px-6 py-24 lg:py-32 text-center">
          <h1 className="text-5xl sm:text-6xl lg:text-7xl font-extrabold text-white tracking-tight leading-[1.05] mb-6">
            Prism
          </h1>
          <p className="text-lg sm:text-xl text-white/80 max-w-2xl mx-auto leading-relaxed mb-10">
            Framework Swift moderno para construir aplicativos Apple com fundação compartilhada, rede, arquitetura, UI adaptativa e inteligência.
          </p>
          <div className="flex flex-wrap items-center justify-center gap-4">
            <Link
              href="/foundation"
              className="inline-flex items-center px-7 py-3 rounded-xl bg-white text-violet-700 font-semibold text-base shadow-lg shadow-black/10 hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200"
            >
              Começar agora
              <svg className="ml-2 w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6" />
              </svg>
            </Link>
            <Link
              href="/getting-started/architecture"
              className="inline-flex items-center px-7 py-3 rounded-xl bg-white/10 backdrop-blur-sm border border-white/25 text-white font-semibold text-base hover:bg-white/20 hover:-translate-y-0.5 transition-all duration-200"
            >
              Ver arquitetura
            </Link>
          </div>
        </div>
      </section>

      {/* Modules */}
      <section className="max-w-6xl mx-auto px-6 py-20">
        <h2 className="text-3xl font-bold tracking-tight mb-3">Módulos</h2>
        <p className="text-slate-500 dark:text-slate-400 text-lg mb-12 max-w-2xl">
          Prism é composto por 6 módulos independentes que podem ser usados juntos ou isoladamente.
        </p>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {modules.map((mod) => (
            <Link
              key={mod.href}
              href={mod.href}
              className="group relative rounded-2xl border border-slate-200 dark:border-slate-800 p-6 hover:border-violet-300 dark:hover:border-violet-700 hover:-translate-y-1 hover:shadow-xl hover:shadow-violet-500/5 transition-all duration-200"
            >
              <div className={`w-12 h-12 rounded-xl ${mod.bgColor} flex items-center justify-center text-2xl mb-4`}>
                {mod.icon}
              </div>
              <h3 className="text-lg font-bold tracking-tight mb-1.5 group-hover:text-violet-600 dark:group-hover:text-violet-400 transition-colors duration-150">
                {mod.title}
              </h3>
              <p className="text-sm text-slate-500 dark:text-slate-400 leading-relaxed">
                {mod.description}
              </p>
              <div className={`absolute bottom-0 left-0 right-0 h-0.5 rounded-b-2xl bg-gradient-to-r ${mod.color} opacity-0 group-hover:opacity-100 transition-opacity duration-200`} />
            </Link>
          ))}
        </div>
      </section>

      {/* Features */}
      <section className="max-w-6xl mx-auto px-6 pb-20">
        <h2 className="text-3xl font-bold tracking-tight mb-10">Destaques</h2>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {[
            { title: "Swift 6.3", desc: "Strict concurrency com Swift 6 language mode. Totalmente Sendable.", icon: "⚡" },
            { title: "Multiplataforma", desc: "iOS, macOS, tvOS, watchOS e visionOS com UI adaptativa.", icon: "🍎" },
            { title: "Testável", desc: "PrismTestStore, injeção por protocolo e mocks integrados.", icon: "🧪" },
            { title: "Type-Safe", desc: "Endpoints, rotas e entidades tipados. Erros nunca são genéricos.", icon: "🎯" },
            { title: "Token-Driven", desc: "Design tokens para espaçamento, raio, fontes e animações.", icon: "🎨" },
            { title: "Acessível", desc: "VoiceOver, testIDs e traits integrados em cada componente.", icon: "♿" },
          ].map((f) => (
            <div key={f.title} className="rounded-2xl border border-slate-200 dark:border-slate-800 p-5">
              <div className="text-2xl mb-3">{f.icon}</div>
              <h4 className="font-semibold text-sm mb-1">{f.title}</h4>
              <p className="text-xs text-slate-500 dark:text-slate-400 leading-relaxed">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Install */}
      <section className="max-w-6xl mx-auto px-6 pb-20">
        <h2 className="text-3xl font-bold tracking-tight mb-6">Instalação</h2>
        <div className="rounded-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
          <div className="flex items-center gap-2 px-4 py-3 bg-slate-50 dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800">
            <span className="text-xs font-mono font-medium text-slate-500 dark:text-slate-400">Package.swift</span>
          </div>
          <pre className="p-5 text-sm leading-relaxed overflow-x-auto bg-white dark:bg-slate-950">
            <code>{`dependencies: [
    .package(url: "<repository-url>", branch: "main")
]

targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "Prism", package: "prism")
        ]
    )
]`}</code>
          </pre>
        </div>
        <div className="mt-4 rounded-2xl border border-slate-200 dark:border-slate-800 overflow-hidden">
          <div className="flex items-center gap-2 px-4 py-3 bg-slate-50 dark:bg-slate-900 border-b border-slate-200 dark:border-slate-800">
            <span className="text-xs font-mono font-medium text-slate-500 dark:text-slate-400">Swift</span>
          </div>
          <pre className="p-5 text-sm leading-relaxed bg-white dark:bg-slate-950">
            <code>import Prism</code>
          </pre>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-slate-200 dark:border-slate-800 py-8">
        <div className="max-w-6xl mx-auto px-6 flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-slate-500 dark:text-slate-400">
          <p>Copyright &copy; 2025 Rafael Santos — MIT License</p>
          <a
            href="https://github.com/rafaelesantos/prism"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-slate-900 dark:hover:text-slate-100 transition-colors duration-150"
          >
            GitHub
          </a>
        </div>
      </footer>
    </main>
  );
}