export interface NavItem {
  title: string;
  href: string;
  description?: string;
  icon?: string;
}

export interface NavSection {
  title: string;
  items: NavItem[];
}

export const navigation: NavSection[] = [
  {
    title: "Primeiros Passos",
    items: [
      { title: "Início", href: "/" },
      { title: "Instalação", href: "/getting-started/installation" },
      { title: "Arquitetura", href: "/getting-started/architecture" },
    ],
  },
  {
    title: "PrismFoundation",
    items: [
      { title: "Visão Geral", href: "/foundation", icon: "🏗️" },
      { title: "Logging", href: "/foundation/logging" },
      { title: "Recursos", href: "/foundation/resources" },
      { title: "Defaults", href: "/foundation/defaults" },
      { title: "Arquivos", href: "/foundation/files" },
      { title: "Entidades", href: "/foundation/entities" },
      { title: "Extensões", href: "/foundation/extensions" },
    ],
  },
  {
    title: "PrismNetwork",
    items: [
      { title: "Visão Geral", href: "/network", icon: "🌐" },
      { title: "Endpoints", href: "/network/endpoints" },
      { title: "Client", href: "/network/client" },
      { title: "Sockets", href: "/network/sockets" },
      { title: "Caching", href: "/network/caching" },
    ],
  },
  {
    title: "PrismArchitecture",
    items: [
      { title: "Visão Geral", href: "/architecture", icon: "🧩" },
      { title: "Store", href: "/architecture/store" },
      { title: "Reducer", href: "/architecture/reducer" },
      { title: "Middleware", href: "/architecture/middleware" },
      { title: "Effects", href: "/architecture/effects" },
      { title: "Router", href: "/architecture/router" },
      { title: "Testes", href: "/architecture/testing" },
      { title: "Padrão Arquitetural", href: "/architecture/pattern" },
    ],
  },
  {
    title: "PrismUI",
    items: [
      { title: "Visão Geral", href: "/ui", icon: "🎨" },
      { title: "Design Tokens", href: "/ui/design-tokens" },
      { title: "Átomos", href: "/ui/atoms" },
      { title: "Moléculas", href: "/ui/molecules" },
      { title: "Modificadores", href: "/ui/modifiers" },
      { title: "Temas", href: "/ui/theming" },
      { title: "Acessibilidade", href: "/ui/accessibility" },
      { title: "UI Adaptativa", href: "/ui/adaptive-ui" },
      { title: "Navegação", href: "/ui/navigation" },
      { title: "Scaffold", href: "/ui/scaffold" },
      { title: "Cores Semânticas", href: "/ui/semantic-colors" },
    ],
  },
  {
    title: "PrismVideo",
    items: [
      { title: "Visão Geral", href: "/video", icon: "🎬" },
      { title: "Download de Vídeo", href: "/video/video-downloader" },
    ],
  },
  {
    title: "PrismIntelligence",
    items: [
      { title: "Visão Geral", href: "/intelligence", icon: "🧠" },
      { title: "Client", href: "/intelligence/client" },
      { title: "Treino Local", href: "/intelligence/local-training" },
      { title: "Inferência Local", href: "/intelligence/local-inference" },
      { title: "Apple Intelligence", href: "/intelligence/apple-intelligence" },
      { title: "Modelos Remotos", href: "/intelligence/remote-models" },
      { title: "Disponibilidade", href: "/intelligence/platform-availability" },
    ],
  },
];

export const modules = [
  {
    title: "PrismFoundation",
    description: "Camada base: entidades, erros, logging, recursos, defaults e extensões Foundation.",
    href: "/foundation",
    icon: "🏗️",
    color: "from-violet-500 to-purple-600",
    bgColor: "bg-violet-50 dark:bg-violet-950/30",
  },
  {
    title: "PrismNetwork",
    description: "Infraestrutura HTTP e WebSocket com endpoints tipados, caching e logging.",
    href: "/network",
    icon: "🌐",
    color: "from-teal-400 to-cyan-500",
    bgColor: "bg-teal-50 dark:bg-teal-950/30",
  },
  {
    title: "PrismArchitecture",
    description: "Arquitetura unidirecional: Store, Reducer, Middleware, Effect e Router.",
    href: "/architecture",
    icon: "🧩",
    color: "from-pink-400 to-rose-500",
    bgColor: "bg-pink-50 dark:bg-pink-950/30",
  },
  {
    title: "PrismUI",
    description: "Design system adaptativo SwiftUI: átomos, moléculas, tokens e temas.",
    href: "/ui",
    icon: "🎨",
    color: "from-emerald-400 to-green-500",
    bgColor: "bg-emerald-50 dark:bg-emerald-950/30",
  },
  {
    title: "PrismVideo",
    description: "Download de vídeo com streaming de progresso em tempo real.",
    href: "/video",
    icon: "🎬",
    color: "from-orange-400 to-red-500",
    bgColor: "bg-orange-50 dark:bg-orange-950/30",
  },
  {
    title: "PrismIntelligence",
    description: "Inteligência multi-backend: treino local, inferência, Apple Intelligence e modelos remotos.",
    href: "/intelligence",
    icon: "🧠",
    color: "from-indigo-400 to-violet-500",
    bgColor: "bg-indigo-50 dark:bg-indigo-950/30",
  },
];